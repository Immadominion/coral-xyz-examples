import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coral_xyz/coral_xyz_anchor.dart';
import '../services/solana_voting_service.dart';
import '../models/poll.dart';
import '../widgets/gradient_button.dart';
import '../utils/theme.dart';
import 'create_poll_screen.dart';
import 'poll_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppTheme.spacingXL),
              _buildHeader(),
              const SizedBox(height: AppTheme.spacingXXL),
              _buildWalletSection(),
              const SizedBox(height: AppTheme.spacingXXL),
              _buildPollsSection(context),
              const SizedBox(height: AppTheme.spacingXXL),
              _buildActionsSection(context),
              const SizedBox(height: AppTheme.spacingXXL),
              _buildInfoSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
            boxShadow: AppTheme.cardShadow,
          ),
          child: const Icon(Icons.how_to_vote, color: Colors.white, size: 40),
        ),
        const SizedBox(height: AppTheme.spacingL),
        Text(
          'Decentralized Voting',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingS),
        Text(
          'Create and participate in transparent,\non-chain polls powered by Solana',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondaryColor,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWalletSection() {
    return Consumer<SolanaVotingService>(
      builder: (context, solanaService, child) {
        if (solanaService.wallet == null) {
          return Container(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
              border: Border.all(color: AppTheme.warningColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: AppTheme.warningColor,
                  size: 48,
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'Wallet Not Loaded',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.warningColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  'Unable to load wallet from wallet.json file',
                  style: TextStyle(color: AppTheme.warningColor, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Wallet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingXS),
                        Text(
                          '${solanaService.walletAddress!.substring(0, 8)}...${solanaService.walletAddress!.substring(solanaService.walletAddress!.length - 8)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondaryColor,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
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
                          'Connected',
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
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Consumer<SolanaVotingService>(
      builder: (context, solanaService, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'What would you like to do?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            GradientButton(
              text: 'Create New Poll',
              icon: Icons.add_circle_outline,
              onPressed: solanaService.wallet != null
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreatePollScreen(),
                        ),
                      );
                    }
                  : null,
            ),
            if (solanaService.wallet == null) ...[
              const SizedBox(height: AppTheme.spacingM),
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
                      Icons.info_outline,
                      color: AppTheme.warningColor,
                      size: 20,
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    Expanded(
                      child: Text(
                        'Wallet not loaded from wallet.json',
                        style: TextStyle(
                          color: AppTheme.warningColor,
                          fontSize: 14,
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
      },
    );
  }

  Widget _buildInfoSection() {
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
              Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 24),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                'How it works',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          _buildInfoItem(
            icon: Icons.create,
            title: 'Create',
            description: 'Set up a new poll with up to 4 options',
          ),
          _buildInfoItem(
            icon: Icons.how_to_vote,
            title: 'Vote',
            description: 'Participants cast their votes on-chain',
          ),
          _buildInfoItem(
            icon: Icons.analytics,
            title: 'Results',
            description: 'View real-time, transparent results',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPollsSection(BuildContext context) {
    return Consumer<SolanaVotingService>(
      builder: (context, solanaService, child) {
        final createdPolls = solanaService.createdPolls;
        final currentPoll = solanaService.currentPoll;

        if (createdPolls.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              children: [
                Icon(
                  Icons.poll_outlined,
                  color: AppTheme.textSecondaryColor,
                  size: 48,
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'No Polls Created Yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  'Create your first poll to get started with decentralized voting',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.poll, color: AppTheme.primaryColor, size: 24),
                      const SizedBox(width: AppTheme.spacingS),
                      Text(
                        'Your Polls (${createdPolls.length})',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  if (createdPolls.isNotEmpty)
                    IconButton(
                      onPressed: solanaService.isLoading
                          ? null
                          : () {
                              solanaService.refreshAllPolls();
                            },
                      icon: Icon(Icons.refresh, color: AppTheme.primaryColor),
                      tooltip: 'Refresh all polls',
                    ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingM),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: createdPolls.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppTheme.spacingM),
                itemBuilder: (context, index) {
                  final poll = createdPolls[index];
                  final isSelected =
                      currentPoll != null &&
                      poll.name == currentPoll.name &&
                      poll.description == currentPoll.description;

                  return _buildPollCard(
                    context,
                    poll,
                    isSelected,
                    solanaService,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPollCard(
    BuildContext context,
    Poll poll,
    bool isSelected,
    SolanaVotingService solanaService,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryColor.withOpacity(0.1)
            : AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.3)
              : AppTheme.primaryColor.withOpacity(0.1),
          width: isSelected ? 2 : 1,
        ),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingS,
                    vertical: AppTheme.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: const Text(
                    'Selected',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            poll.description,
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondaryColor),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            children: [
              Icon(
                Icons.how_to_vote,
                size: 16,
                color: AppTheme.textSecondaryColor,
              ),
              const SizedBox(width: AppTheme.spacingXS),
              Text(
                '${poll.options.length} option${poll.options.length != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const Spacer(),
              if (poll.finished)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingS,
                    vertical: AppTheme.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Text(
                    'Finished',
                    style: TextStyle(
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingS,
                    vertical: AppTheme.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Text(
                    'Active',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            children: [
              if (!isSelected)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      // Select the poll and navigate to poll screen
                      await solanaService.selectPoll(
                        PublicKey.fromBase58(poll.address),
                      );
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PollScreen(),
                          ),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(color: AppTheme.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      ),
                    ),
                    child: const Text('Select'),
                  ),
                ),
              if (!isSelected) const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    // Select the poll and navigate to poll screen
                    await solanaService.selectPoll(
                      PublicKey.fromBase58(poll.address),
                    );
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PollScreen(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                  ),
                  child: const Text('View Details'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
