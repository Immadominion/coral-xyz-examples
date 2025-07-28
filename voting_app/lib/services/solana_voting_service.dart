import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:coral_xyz/coral_xyz_anchor.dart';
import 'package:bs58/bs58.dart' as bs58;
import '../models/poll.dart';
import '../models/poll_option.dart';
import '../private.dart';

class SolanaVotingService extends ChangeNotifier {
  Program? _program;
  Poll? _currentPoll;
  List<Poll> _createdPolls = [];
  bool _isLoading = false;
  String? _error;
  PublicKey? _currentPollAddress;
  List<PublicKey> _createdPollAddresses = [];

  Program? get program => _program;
  Poll? get currentPoll => _currentPoll;
  List<Poll> get createdPolls => List.unmodifiable(_createdPolls);
  bool get isLoading => _isLoading;
  String? get error => _error;
  dynamic get wallet =>
      _program?.provider.wallet; // For compatibility with existing UI
  String? get walletAddress => _program?.provider.wallet?.publicKey.toBase58();
  PublicKey? get currentPollAddress => _currentPollAddress;
  List<PublicKey> get createdPollAddresses =>
      List.unmodifiable(_createdPollAddresses);

  SolanaVotingService() {
    _setupClient();
  }

  Future<void> _setupClient() async {
    try {
      // 1. Load IDL from bundled asset
      final idlJson = await rootBundle.loadString('assets/idl.json');
      final idlMap = jsonDecode(idlJson) as Map<String, dynamic>;
      idlMap['address'] = PROGRAM_ID;
      final idl = Idl.fromJson(idlMap);

      // 2. Setup connection and wallet
      final connection = Connection('https://api.devnet.solana.com');

      // Decode full secret key and extract 32-byte seed
      final secretKeyFull = bs58.base58.decode(PRIVATE_KEY);
      final seed = secretKeyFull.sublist(0, 32);

      // Create a Coral Keypair from seed
      final keypair = await Keypair.fromSeed(seed);
      final wallet = KeypairWallet(keypair);
      final provider = AnchorProvider(connection, wallet);

      // 3. Create program
      _program = Program.withProgramId(
        idl,
        PublicKey.fromBase58(PROGRAM_ID),
        provider: provider,
      );

      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize: ${e.toString()}');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }

  /// Creates a new poll on-chain
  Future<String?> createPoll({
    required String name,
    required String description,
    required List<String> options,
  }) async {
    if (_program?.provider.wallet == null) {
      _setError('No wallet connected');
      return null;
    }

    try {
      _setLoading(true);
      _setError(null);

      // Generate a new poll account keypair
      final pollKeypair = await Keypair.generate();

      // Call initialize using dynamic methods API
      final signature = await (_program!.methods as dynamic)
          .initialize(name, description, options)
          .accounts({
            'poll': pollKeypair.publicKey,
            'owner': _program!.provider.wallet!.publicKey,
            'systemProgram': PublicKey.fromBase58(
              '11111111111111111111111111111111',
            ), // Use correct System Program ID directly
          })
          .signers([pollKeypair])
          .rpc();

      // Add to our tracking
      _createdPollAddresses.add(pollKeypair.publicKey);

      // Wait a moment for the account to be available for reading
      await Future.delayed(Duration(milliseconds: 1500));

      // Fetch the created poll data with retry mechanism
      await _fetchPollDataWithRetry(pollKeypair.publicKey, fast: false);

      return signature;
    } catch (e) {
      _setError('Failed to create poll: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Submits a vote on-chain
  Future<String?> vote(int optionId) async {
    if (_program?.provider.wallet == null) {
      _setError('No wallet connected');
      return null;
    }

    if (_currentPollAddress == null) {
      _setError('No poll selected');
      return null;
    }

    try {
      _setLoading(true);
      _setError(null);

      // Call vote using dynamic methods API
      final signature = await (_program!.methods as dynamic)
          .vote(optionId)
          .accounts({
            'poll': _currentPollAddress!, // Ensure non-null
            'voter': _program!.provider.wallet!.publicKey, // Ensure non-null
          })
          .rpc();

      // Refresh poll data after voting
      await _fetchPollData(_currentPollAddress!);

      return signature;
    } catch (e) {
      _setError('Failed to submit vote: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Fetches poll data from on-chain
  Future<void> _fetchPollData(
    PublicKey pollAddress, {
    bool speed = true,
  }) async {
    if (_program == null) {
      _setError('Program not initialized');
      return;
    }

    try {
      // Fetch account using dart-coral-xyz - clean and simple!
      final accountData = await _program!.account['Poll']!.fetch(pollAddress);

      // Check if accountData is available
      if (accountData == null) {
        throw Exception('Account data not available yet');
      }

      // Convert the raw data to our Poll model
      final poll = _convertRawDataToPoll(accountData, pollAddress.toBase58());

      // Update current poll if this is the selected one
      if (_currentPollAddress == pollAddress) {
        _currentPoll = poll;
      }

      // Update in created polls list
      final index = _createdPolls.indexWhere((p) => p.address == poll.address);
      if (index >= 0) {
        _createdPolls[index] = poll;
      } else {
        _createdPolls.add(poll);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch poll: ${e.toString()}');
    }
  }

  /// Converts raw account data to Poll model
  Poll _convertRawDataToPoll(
    Map<String, dynamic> accountData,
    String pollAddress,
  ) {
    try {
      // Handle options array - dart-coral-xyz automatically deserializes complex types!
      final options = (accountData['options'] as List).map((option) {
        return PollOption(
          label: option['label'] as String,
          id: option['id'] as int,
          votes: option['votes'] as int,
        );
      }).toList();

      // Handle voters array - automatic PublicKey to String conversion
      final voters = (accountData['voters'] as List).map((voter) {
        if (voter is PublicKey) {
          return voter.toBase58();
        } else if (voter is String) {
          return voter;
        } else {
          return voter.toString();
        }
      }).toList();

      return Poll(
        finished: accountData['finished'] as bool,
        name: accountData['name'] as String,
        description: accountData['description'] as String,
        options: options,
        voters: voters,
        address: pollAddress,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Selects a specific poll by address
  Future<void> selectPoll(PublicKey pollAddress) async {
    _currentPollAddress = pollAddress;
    await _fetchPollData(pollAddress);
  }

  /// Refreshes all created polls from the blockchain
  Future<void> refreshAllPolls() async {
    if (_createdPollAddresses.isEmpty) {
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      for (final pollAddress in _createdPollAddresses) {
        await _fetchPollData(pollAddress);
      }
    } catch (e) {
      _setError('Failed to refresh polls: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void clearPoll() {
    _currentPoll = null;
    _currentPollAddress = null;
    _error = null;
    notifyListeners();
  }

  /// Fetches poll data from on-chain (public method for compatibility)
  Future<void> fetchPoll(String pollAddress, {bool bypassCache = false}) async {
    try {
      final pubkey = PublicKey.fromBase58(pollAddress);
      await _fetchPollData(pubkey);
    } catch (e) {
      _setError('Failed to fetch poll: ${e.toString()}');
    }
  }

  /// Fetches poll data with retry mechanism for newly created polls
  Future<void> _fetchPollDataWithRetry(
    PublicKey pollAddress, {
    int maxRetries = 3,
    bool fast = true,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        await _fetchPollData(pollAddress, speed: fast);

        // Check if we successfully retrieved the poll data
        final pollExists = _createdPolls.any(
          (poll) => _createdPollAddresses.contains(pollAddress),
        );

        if (pollExists) {
          return;
        }
      } catch (e) {
        // Continue to next attempt
      }

      // If this wasn't the last attempt, wait before retrying
      if (attempt < maxRetries) {
        await Future.delayed(
          Duration(milliseconds: 1000 * attempt),
        ); // Exponential backoff
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
