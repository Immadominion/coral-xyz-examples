import 'dart:async';
import 'dart:convert';
import 'package:coral_xyz/coral_xyz_anchor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bs58/bs58.dart' as bs58;
import 'package:solana/solana.dart' as sol;
import 'private.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  _CounterScreenState createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  late Program program;
  late PublicKey counterPda;
  int count = 0;
  bool loading = false;
  bool initialized = false;

  @override
  void initState() {
    super.initState();
    setupClient();
  }

  Future<void> setupClient() async {
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
    program = Program.withProgramId(
      idl,
      PublicKey.fromBase58(PROGRAM_ID),
      provider: provider,
    );

    // 4. PDA derivation
    final pdaResult = await PublicKey.findProgramAddress([
      utf8.encode('counter_v2'),
    ], program.programId);
    counterPda = pdaResult.address;

    // 5. Fetch initial count
    await updateCount();
  }

  Future<void> initCounter() async {
    setState(() => loading = true);
    try {
      // Use typed method builder matching TypeScript API
      // Call initialize using dynamic methods API
      await (program.methods as dynamic).initialize().accounts({
        'counter': counterPda,
        'payer': program.provider.wallet!.publicKey,
        'systemProgram': sol.SystemProgram.programId,
      }).rpc();
      setState(() {
        initialized = true;
      });
      await updateCount();
    } catch (e) {
      // Already initialized or error
      await updateCount();
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> incrementCounter() async {
    setState(() => loading = true);
    try {
      // Use typed method builder matching TypeScript API
      // Call increment using dynamic methods API
      await (program.methods as dynamic).increment(BigInt.one).accounts({
        'counter': counterPda,
      }).rpc();
      await updateCount();
    } catch (e) {
      print('Error incrementing: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> updateCount() async {
    try {
      // Fetch account using non-null assertion
      final accountData = await program.account['Counter']!.fetch(counterPda);
      setState(() {
        count = (accountData['count'] as BigInt).toInt();
      });
    } catch (e) {
      setState(() {
        count = -1; // N/A
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Anchor Counter')),
      body: Center(
        child: loading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Count: ${count == -1 ? 'N/A' : count}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: initialized ? null : initCounter,
                    child: Text('Initialize'),
                  ),
                  ElevatedButton(
                    onPressed: incrementCounter,
                    child: Text('Increment'),
                  ),
                ],
              ),
      ),
    );
  }
}
