import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:coral_xyz/coral_xyz_anchor.dart';
import '../models/todo_models.dart';
import '../utils/solana_utils.dart';

/// Minimal Solana service demonstrating dart-coral-xyz simplicity
class SolanaService extends ChangeNotifier {
  Program? _program;
  UserProfile? _userProfile;
  List<TodoAccount> _todos = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  Program? get program => _program;
  UserProfile? get userProfile => _userProfile;
  List<TodoAccount> get todos => List.unmodifiable(_todos);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConnected => _program != null;
  String? get walletAddress => _program?.provider.wallet?.publicKey.toBase58();

  SolanaService() {
    _init();
  }

  Future<void> _init() async {
    try {
      _setLoading(true);
      _program = await SolanaUtils.createProgram();
      await _loadUserProfile();
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
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

  /// Get user profile PDA - one simple call!
  Future<PublicKey> _getUserProfilePDA() async {
    final userTag = _program!.idl.constants!.firstWhere(
      (c) => c.name == 'USER_TAG',
    );
    // Parse constant value directly as JSON array
    final seedBytes = (jsonDecode(userTag.value) as List).cast<int>();

    return (await PublicKey.findProgramAddress([
      Uint8List.fromList(seedBytes),
      _program!.provider.wallet!.publicKey.toBytes(),
    ], _program!.programId)).address;
  }

  /// Get todo account PDA - one simple call!
  Future<PublicKey> _getTodoAccountPDA(int todoIdx) async {
    final todoTag = _program!.idl.constants!.firstWhere(
      (c) => c.name == 'TODO_TAG',
    );
    // Parse constant value directly as JSON array
    final seedBytes = (jsonDecode(todoTag.value) as List).cast<int>();

    return (await PublicKey.findProgramAddress([
      Uint8List.fromList(seedBytes),
      _program!.provider.wallet!.publicKey.toBytes(),
      Uint8List.fromList([todoIdx]),
    ], _program!.programId)).address;
  }

  /// Initialize user - dart-coral-xyz magic!
  Future<String?> initializeUser() async {
    if (_program == null) return null;

    try {
      _setLoading(true);
      _setError(null);

      // Check if already initialized
      await _loadUserProfile();
      if (_userProfile != null) return 'User already initialized';

      final userProfilePDA = await _getUserProfilePDA();
      final signature =
          await (_program!.methods as dynamic).initializeUser().accounts({
            'authority': _program!.provider.wallet!.publicKey,
            'userProfile': userProfilePDA,
            'systemProgram': SolanaUtils.systemProgram,
          }).rpc();

      await _loadUserProfile();
      return signature;
    } catch (e) {
      _setError('Failed to initialize user: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Add todo - simple and clean!
  Future<String?> addTodo(String content) async {
    if (_program == null || _userProfile == null) return null;

    try {
      _setLoading(true);
      _setError(null);

      final userProfilePDA = await _getUserProfilePDA();
      final todoAccountPDA = await _getTodoAccountPDA(_userProfile!.lastTodo);

      final signature =
          await (_program!.methods as dynamic).addTodo(content).accounts({
            'userProfile': userProfilePDA,
            'todoAccount': todoAccountPDA,
            'authority': _program!.provider.wallet!.publicKey,
            'systemProgram': SolanaUtils.systemProgram,
          }).rpc();

      await _loadUserProfile();
      await _loadAllTodos();
      return signature;
    } catch (e) {
      _setError('Failed to add todo: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Mark todo - one method call!
  Future<String?> markTodo(int todoIdx) async {
    if (_program == null) return null;

    try {
      _setLoading(true);
      final userProfilePDA = await _getUserProfilePDA();
      final todoAccountPDA = await _getTodoAccountPDA(todoIdx);

      final signature =
          await (_program!.methods as dynamic).markTodo(todoIdx).accounts({
            'userProfile': userProfilePDA,
            'todoAccount': todoAccountPDA,
            'authority': _program!.provider.wallet!.publicKey,
            'systemProgram': SolanaUtils.systemProgram,
          }).rpc();

      await _loadAllTodos();
      return signature;
    } catch (e) {
      _setError('Failed to mark todo: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Remove todo - clean and simple!
  Future<String?> removeTodo(int todoIdx) async {
    if (_program == null) return null;

    try {
      _setLoading(true);
      final userProfilePDA = await _getUserProfilePDA();
      final todoAccountPDA = await _getTodoAccountPDA(todoIdx);

      final signature =
          await (_program!.methods as dynamic).removeTodo(todoIdx).accounts({
            'userProfile': userProfilePDA,
            'todoAccount': todoAccountPDA,
            'authority': _program!.provider.wallet!.publicKey,
            'systemProgram': SolanaUtils.systemProgram,
          }).rpc();

      await _loadUserProfile();
      await _loadAllTodos();
      return signature;
    } catch (e) {
      _setError('Failed to remove todo: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Load user profile - automatic deserialization!
  Future<void> _loadUserProfile() async {
    if (_program == null) return;

    try {
      final userProfilePDA = await _getUserProfilePDA();
      final accountData = await _program!.account['UserProfile']!.fetch(
        userProfilePDA,
      );

      _userProfile = accountData != null
          ? UserProfile.fromJson(accountData)
          : null;
      notifyListeners();
    } catch (e) {
      _userProfile = null;
    }
  }

  /// Load todos - super clean with dart-coral-xyz!
  Future<void> _loadAllTodos() async {
    if (_program == null || _userProfile == null) return;

    _todos.clear();
    for (int i = 0; i < _userProfile!.lastTodo; i++) {
      try {
        final todoAccountPDA = await _getTodoAccountPDA(i);
        final accountData = await _program!.account['TodoAccount']!.fetch(
          todoAccountPDA,
        );

        if (accountData != null) {
          _todos.add(TodoAccount.fromJson(accountData));
        }
      } catch (e) {
        // Some todos might not exist
        continue;
      }
    }
    notifyListeners();
  }

  /// Check if user is initialized
  Future<bool> isUserInitialized() async {
    await _loadUserProfile();
    return _userProfile != null;
  }

  /// Refresh data
  Future<void> refresh() async {
    if (_program == null) return;
    _setLoading(true);
    try {
      await _loadUserProfile();
      if (_userProfile != null) await _loadAllTodos();
    } finally {
      _setLoading(false);
    }
  }

  void clearError() => _setError(null);
}
