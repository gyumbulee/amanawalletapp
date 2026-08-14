import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../extensions/currency_extensions.dart';

/// Primary dashboard wallet card: balance, virtual account number, bank
/// name, and a copy-to-clipboard action. Charcoal Gray background, white
/// text, clean modern layout — per branding guidelines.
///
/// Wired to real data once the `wallet` and `virtual_account` features are
/// built; for now accepts plain values so it can be dropped into the
/// dashboard screen and previewed independently.
class WalletCard extends StatelessWidget {
  const WalletCard({
    super.key,
    required this.balanceInKobo,
    this.accountNumber,
    this.bankName,
    this.isBalanceHidden = false,
    this.onToggleVisibility,
    this.isLoading = false,
  });

  final int balanceInKobo;
  final String? accountNumber;
  final String? bankName;
  final bool isBalanceHidden;
  final VoidCallback? onToggleVisibility;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadii.cardRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Wallet Balance',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              if (onToggleVisibility != null)
                IconButton(
                  onPressed: onToggleVisibility,
                  icon: Icon(
                    isBalanceHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.white70,
                    size: 20,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 4),
          if (isLoading)
            const SizedBox(
              height: 32,
              width: 120,
              child: LinearProgressIndicator(color: Colors.white24),
            )
          else
            Text(
              isBalanceHidden ? '••••••' : balanceInKobo.toNairaDisplay(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
          const SizedBox(height: 20),
          if (accountNumber != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bankName ?? '',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          accountNumber!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: accountNumber!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Account number copied')),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, color: Colors.white, size: 18),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
