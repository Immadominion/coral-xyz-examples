import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/solana_voting_service.dart';
import 'screens/home_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(const VotingApp());
}

class VotingApp extends StatelessWidget {
  const VotingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            print('Initializing SolanaVotingService');
            return SolanaVotingService();
          },
        ),
      ],
      child: MaterialApp(
        title: 'Decentralized Voting',
        theme: AppTheme.themeData,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
