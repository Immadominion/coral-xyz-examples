import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:coral_xyz/coral_xyz_anchor.dart';
import 'package:bs58/bs58.dart' as bs58;
import '../private.dart';

/// Utility functions for Solana operations
class SolanaUtils {
  /// Create a configured Anchor program instance
  static Future<Program> createProgram() async {
    // Load IDL from bundled asset
    final idlJson = await rootBundle.loadString('assets/idl.json');
    final idlMap = jsonDecode(idlJson) as Map<String, dynamic>;
    idlMap['address'] = PROGRAM_ID;
    final idl = Idl.fromJson(idlMap);

    // Setup connection and wallet
    final connection = Connection('https://api.devnet.solana.com');
    final secretKeyFull = bs58.base58.decode(PRIVATE_KEY);
    final seed = secretKeyFull.sublist(0, 32);
    final keypair = await Keypair.fromSeed(seed);
    final wallet = KeypairWallet(keypair);
    final provider = AnchorProvider(connection, wallet);

    return Program.withProgramId(
      idl,
      PublicKey.fromBase58(PROGRAM_ID),
      provider: provider,
    );
  }

  /// Get system program public key
  static PublicKey get systemProgram =>
      PublicKey.fromBase58('11111111111111111111111111111111');
}
