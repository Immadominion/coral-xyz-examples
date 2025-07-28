import 'package:flutter/material.dart';
import '../utils/theme.dart';

class WalletConnectionCard extends StatelessWidget {
  final String? walletAddress;
  final bool isConnecting;
  final VoidCallback onConnect;
  final VoidCallback? onDisconnect;

  const WalletConnectionCard({
    super.key,
    this.walletAddress,
    this.isConnecting = false,
    required this.onConnect,
    this.onDisconnect,
  });

  bool get isConnected => walletAddress != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: isConnected
              ? AppTheme.successColor.withOpacity(0.3)
              : Colors.grey.shade200,
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: isConnected
                      ? AppTheme.successColor.withOpacity(0.1)
                      : AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Icon(
                  isConnected ? Icons.account_balance_wallet : Icons.wallet,
                  color: isConnected
                      ? AppTheme.successColor
                      : AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isConnected ? 'Wallet Connected' : 'Connect Wallet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    if (isConnected) ...[
                      const SizedBox(height: AppTheme.spacingXS),
                      Text(
                        '${walletAddress!.substring(0, 8)}...${walletAddress!.substring(walletAddress!.length - 8)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: AppTheme.spacingXS),
                      Text(
                        'Connect your wallet to participate in voting',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isConnected ? AppTheme.successColor : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          Row(
            children: [
              if (!isConnected)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isConnecting ? null : onConnect,
                    icon: isConnecting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.link, size: 18),
                    label: Text(
                      isConnecting ? 'Connecting...' : 'Connect Wallet',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                )
              else ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDisconnect,
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Disconnect'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: BorderSide(color: AppTheme.errorColor),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
