import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/app_router.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/empty_states/empty_state.dart';
import '../../../../shared/widgets/loaders/skeleton_loader.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../theme/app_colors.dart';
import '../../../wallet/presentation/providers/wallet_balance_provider.dart';
import '../providers/virtual_account_provider.dart';

/// Wallet funding is bank-transfer based per the project spec (Flutterwave
/// webhook auto-credits on incoming transfer) — there's no in-app checkout
/// here. This screen shows the dedicated virtual account and lets the user
/// refresh their balance after making a transfer.
class VirtualAccountScreen extends ConsumerWidget {
  const VirtualAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountAsync = ref.watch(virtualAccountProvider);

    return ResponsiveScaffold(
      appBar: AppBar(title: const Text('Fund Wallet')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(virtualAccountProvider);
          await ref.read(walletBalanceProvider.notifier).refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: accountAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Column(
                children: [
                  SkeletonLoader(height: 160, borderRadius: BorderRadius.all(Radius.circular(16))),
                ],
              ),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.only(top: 60),
              child: EmptyState(
                icon: Icons.error_outline_rounded,
                message: 'Could not load your virtual account. Pull down to try again.',
                actionLabel: 'Retry',
                onAction: () => ref.invalidate(virtualAccountProvider),
              ),
            ),
            data: (account) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Transfer to this account and your wallet will be credited automatically.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bank Name', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text(
                        account.bankName,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      const Text('Account Number', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              account.accountNumber,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: account.accountNumber));
                              context.showSnack('Account number copied');
                            },
                            icon: const Icon(Icons.copy_rounded, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('Account Name', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text(
                        account.accountName,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (account.isFailed)
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: AppColors.error),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'We could not set up your virtual account.',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        if ((account.failureReason ?? '').isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            account.failureReason!,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => context.push(AppRoutes.verifyBvn),
                            child: const Text('Fix with BVN'),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (!account.isActive)
                  AppCard(
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppColors.warning),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "We're setting up your virtual account. This usually only takes a moment — pull down to refresh.",
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                AppCard(
                  child: Row(
                    children: [
                      const Icon(Icons.bolt_rounded, color: AppColors.accent),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Transfers are credited automatically, usually within a minute. Pull down to refresh if your balance hasn\'t updated.',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
