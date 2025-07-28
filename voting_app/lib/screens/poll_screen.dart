import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/solana_voting_service.dart';
import '../widgets/vote_option_card.dart';
import '../widgets/poll_stats_card.dart';
import '../widgets/gradient_button.dart';
import '../utils/theme.dart';

class PollScreen extends StatefulWidget {
  const PollScreen({super.key});

  @override
  State<PollScreen> createState() => _PollScreenState();
}

class _PollScreenState extends State<PollScreen> {
  int? _selectedOptionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poll Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Consumer<SolanaVotingService>(
            builder: (context, solanaService, child) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: solanaService.currentPollAddress != null
                    ? () async {
                        await solanaService.fetchPoll(
                          solanaService.currentPollAddress!.toString(),
                          bypassCache: true,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Poll data refreshed'),
                            ),
                          );
                        }
                      }
                    : null,
              );
            },
          ),
        ],
      ),
      body: Consumer<SolanaVotingService>(
        builder: (context, solanaService, child) {
          final poll = solanaService.currentPoll;

          if (solanaService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (poll == null) {
            return _buildEmptyState();
          }

          final hasUserVoted =
              solanaService.wallet != null &&
              poll.hasUserVoted(solanaService.walletAddress!);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPollHeader(poll),
                const SizedBox(height: AppTheme.spacingL),
                PollStatsCard(poll: poll),
                const SizedBox(height: AppTheme.spacingL),
                if (solanaService.wallet == null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      border: Border.all(
                        color: AppTheme.warningColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.wallet,
                          color: AppTheme.warningColor,
                          size: 20,
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        Expanded(
                          child: Text(
                            'Wallet not loaded from wallet.json',
                            style: TextStyle(
                              color: AppTheme.warningColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      border: Border.all(
                        color: AppTheme.successColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          color: AppTheme.successColor,
                          size: 20,
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Connected Wallet',
                                style: TextStyle(
                                  color: AppTheme.successColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${solanaService.walletAddress!.substring(0, 8)}...${solanaService.walletAddress!.substring(solanaService.walletAddress!.length - 8)}',
                                style: TextStyle(
                                  color: AppTheme.successColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                ],
                _buildVotingSection(
                  poll,
                  hasUserVoted,
                  solanaService.wallet != null,
                  solanaService,
                ),
                if (solanaService.error != null) ...[
                  const SizedBox(height: AppTheme.spacingL),
                  _buildErrorCard(solanaService.error!),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.poll_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'No poll found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'The poll you\'re looking for doesn\'t exist or failed to load.',
            style: TextStyle(color: AppTheme.textMutedColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPollHeader(poll) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  poll.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color: poll.finished
                      ? AppTheme.errorColor.withOpacity(0.1)
                      : AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Text(
                  poll.finished ? 'Finished' : 'Active',
                  style: TextStyle(
                    color: poll.finished
                        ? AppTheme.errorColor
                        : AppTheme.successColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            poll.description,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVotingSection(
    poll,
    bool hasUserVoted,
    bool isWalletConnected,
    SolanaVotingService solanaService,
  ) {
    final showResults = hasUserVoted || poll.finished;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              showResults ? 'Results' : 'Cast Your Vote',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            if (hasUserVoted) ...[
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingS,
                  vertical: AppTheme.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.successColor,
                      size: 16,
                    ),
                    const SizedBox(width: AppTheme.spacingXS),
                    Text(
                      'Voted',
                      style: TextStyle(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppTheme.spacingL),
        ...poll.options.map<Widget>((option) {
          return VoteOptionCard(
            option: option,
            isSelected: _selectedOptionId == option.id,
            showResults: showResults,
            totalVotes: poll.totalVotes,
            hasUserVoted: hasUserVoted,
            onTap: () {
              if (!showResults && isWalletConnected) {
                setState(() {
                  _selectedOptionId = option.id;
                });
              }
            },
          );
        }).toList(),
        if (!showResults && isWalletConnected) ...[
          const SizedBox(height: AppTheme.spacingL),
          Consumer<SolanaVotingService>(
            builder: (context, votingService, child) {
              return GradientButton(
                text: 'Submit Vote',
                icon: Icons.how_to_vote,
                isLoading: votingService.isLoading,
                onPressed: _selectedOptionId != null
                    ? () => _submitVote(solanaService)
                    : null,
              );
            },
          ),
        ] else if (!isWalletConnected && !showResults) ...[
          const SizedBox(height: AppTheme.spacingL),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(color: AppTheme.warningColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.wallet, color: AppTheme.warningColor, size: 20),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: Text(
                    'Connect your wallet to vote',
                    style: TextStyle(
                      color: AppTheme.warningColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppTheme.errorColor, size: 20),
          const SizedBox(width: AppTheme.spacingS),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Provider.of<SolanaVotingService>(
                context,
                listen: false,
              ).clearError();
            },
            child: Text(
              'Dismiss',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitVote(SolanaVotingService solanaService) async {
    final signature = await solanaService.vote(_selectedOptionId!);

    if (signature != null) {
      print('Vote submitted successfully: $signature');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vote submitted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      if (mounted) {
        print(solanaService.error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to submit vote: ${solanaService.error ?? "Unknown error"}',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }

    if (mounted) {
      // Refresh poll data after voting
      await solanaService.fetchPoll(
        solanaService.currentPollAddress!.toString(),
      );
    }
  }
}
