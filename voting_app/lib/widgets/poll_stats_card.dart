import 'package:flutter/material.dart';
import '../models/poll.dart';
import '../utils/theme.dart';

class PollStatsCard extends StatelessWidget {
  final Poll poll;

  const PollStatsCard({super.key, required this.poll});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        gradient: AppTheme.accentGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.poll, color: Colors.white, size: 24),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                'Poll Statistics',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          Row(
            children: [
              _buildStatItem(
                icon: Icons.how_to_vote,
                label: 'Total Votes',
                value: poll.totalVotes.toString(),
              ),
              const SizedBox(width: AppTheme.spacingXL),
              _buildStatItem(
                icon: Icons.people,
                label: 'Participants',
                value: poll.voters.length.toString(),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          Row(
            children: [
              _buildStatItem(
                icon: Icons.list_alt,
                label: 'Options',
                value: poll.options.length.toString(),
              ),
              const SizedBox(width: AppTheme.spacingXL),
              _buildStatItem(
                icon: poll.finished ? Icons.check_circle : Icons.access_time,
                label: 'Status',
                value: poll.finished ? 'Finished' : 'Active',
              ),
            ],
          ),
          if (poll.hasVotes && poll.leadingOption != null) ...[
            const SizedBox(height: AppTheme.spacingL),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.white, size: 20),
                  const SizedBox(width: AppTheme.spacingS),
                  Text(
                    'Leading: ${poll.leadingOption!.label}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${poll.leadingOption!.getVotePercentage(poll.totalVotes).toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white.withOpacity(0.8), size: 16),
              const SizedBox(width: AppTheme.spacingXS),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
