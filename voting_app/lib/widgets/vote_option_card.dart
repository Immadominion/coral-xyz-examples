import 'package:flutter/material.dart';
import '../models/poll_option.dart';
import '../utils/theme.dart';

class VoteOptionCard extends StatelessWidget {
  final PollOption option;
  final bool isSelected;
  final bool showResults;
  final int totalVotes;
  final VoidCallback? onTap;
  final bool hasUserVoted;

  const VoteOptionCard({
    super.key,
    required this.option,
    this.isSelected = false,
    this.showResults = false,
    required this.totalVotes,
    this.onTap,
    this.hasUserVoted = false,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = option.getVotePercentage(totalVotes);
    final isWinning =
        showResults &&
        totalVotes > 0 &&
        option.votes > 0 &&
        percentage >= (100 / 4); // Assume winning if above average

    return GestureDetector(
      onTap: showResults || hasUserVoted ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.1),
                    AppTheme.secondaryColor.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white,
          boxShadow: isSelected ? AppTheme.cardShadow : [],
        ),
        child: Stack(
          children: [
            // Background progress bar for results
            if (showResults)
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    gradient: LinearGradient(
                      colors: [
                        (isWinning
                                ? AppTheme.successColor
                                : AppTheme.accentColor)
                            .withOpacity(0.1),
                        Colors.transparent,
                      ],
                      stops: [percentage / 100, percentage / 100],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
            // Content
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Row(
                children: [
                  // Option content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              option.label,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                            if (isWinning && showResults) ...[
                              const SizedBox(width: AppTheme.spacingS),
                              Icon(
                                Icons.emoji_events,
                                color: AppTheme.successColor,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                        if (showResults) ...[
                          const SizedBox(height: AppTheme.spacingS),
                          Text(
                            '${option.votes} vote${option.votes != 1 ? 's' : ''} • ${percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Vote count or selection indicator
                  if (showResults)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingM,
                        vertical: AppTheme.spacingS,
                      ),
                      decoration: BoxDecoration(
                        color: isWinning
                            ? AppTheme.successColor
                            : AppTheme.accentColor,
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    )
                  else if (isSelected)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    )
                  else
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
