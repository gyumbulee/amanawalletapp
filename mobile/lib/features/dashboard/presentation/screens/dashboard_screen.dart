import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/app_router.dart';
import '../../../../shared/extensions/string_extensions.dart';
import '../../../../shared/widgets/cards/wallet_card.dart';
import '../../../../shared/widgets/empty_states/empty_state.dart';
import '../../../../shared/widgets/loaders/skeleton_loader.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../shared/widgets/whatsapp_contact_button.dart';
import '../../../../theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_session_provider.dart';
import '../../../notifications/presentation/providers/unread_count_provider.dart';
import '../../../transactions/presentation/providers/transaction_list_provider.dart';
import '../../../transactions/presentation/widgets/transaction_list_tile.dart';
import '../../../virtual_account/presentation/providers/virtual_account_provider.dart';
import '../../../wallet/presentation/providers/wallet_balance_provider.dart';
import '../widgets/quick_action_item.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _balanceHidden = false;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authSessionProvider);
    final balanceAsync = ref.watch(walletBalanceProvider);
    final accountAsync = ref.watch(virtualAccountProvider);

    return ResponsiveScaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(walletBalanceProvider.notifier).refresh();
          ref.invalidate(virtualAccountProvider);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () => context.push(AppRoutes.profile),
                  customBorder: const CircleBorder(),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary,
                    backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                    child: user?.avatarUrl == null
                        ? Text(
                            (user?.name ?? '').initials,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_greeting, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      Text(
                        user?.name.isNotEmpty == true ? user!.name : 'Welcome',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final unreadAsync = ref.watch(unreadNotificationCountProvider);
                    final unreadCount = unreadAsync.asData?.value ?? 0;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          onPressed: () => context.push(AppRoutes.notifications),
                          icon: const Icon(Icons.notifications_outlined),
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              height: 8,
                              width: 8,
                              decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const WhatsappContactButton(phoneNumber: '09066772894'),
              ],
            ),
            const SizedBox(height: 20),
            balanceAsync.when(
              loading: () => const WalletCard(balanceInKobo: 0, isLoading: true),
              error: (error, _) => const WalletCard(balanceInKobo: 0, isLoading: false),
              data: (balance) => WalletCard(
                balanceInKobo: balance.balanceKobo,
                accountNumber: accountAsync.asData?.value.accountNumber,
                bankName: accountAsync.asData?.value.bankName,
                isBalanceHidden: _balanceHidden,
                onToggleVisibility: () => setState(() => _balanceHidden = !_balanceHidden),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              children: [
                QuickActionItem(
                  icon: Icons.add_circle_outline_rounded,
                  label: 'Fund Wallet',
                  onTap: () => context.push(AppRoutes.virtualAccount),
                ),
                QuickActionItem(
                  icon: Icons.phone_iphone_rounded,
                  label: 'Airtime',
                  onTap: () => context.push(AppRoutes.airtime),
                ),
                QuickActionItem(
                  icon: Icons.wifi_rounded,
                  label: 'Data',
                  onTap: () => context.push(AppRoutes.dataBundle),
                ),
                QuickActionItem(
                  icon: Icons.bolt_rounded,
                  label: 'Electricity',
                  onTap: () => context.push(AppRoutes.electricity),
                ),
                QuickActionItem(
                  icon: Icons.tv_rounded,
                  label: 'Cable TV',
                  onTap: () => context.push(AppRoutes.cable),
                ),
                QuickActionItem(
                  icon: Icons.school_outlined,
                  label: 'Education',
                  onTap: () => context.push(AppRoutes.education),
                ),
                QuickActionItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'Transactions',
                  onTap: () => context.push(AppRoutes.transactions),
                ),
                QuickActionItem(
                  icon: Icons.card_giftcard_outlined,
                  label: 'Referral',
                  onTap: () => context.push(AppRoutes.referral),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Transactions', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                TextButton(
                  onPressed: () => context.push(AppRoutes.transactions),
                  child: const Text('See all'),
                ),
              ],
            ),
            // Reuses the same paginated provider as the full transactions
            // screen — filter defaults to "all", so this just shows the
            // first page's most recent entries, capped at 5 here.
            Consumer(
              builder: (context, ref, _) {
                final listAsync = ref.watch(transactionListProvider);
                return listAsync.when(
                  loading: () => Column(
                    children: List.generate(3, (_) => const SkeletonListTile()),
                  ),
                  error: (error, _) => const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: EmptyState(
                      icon: Icons.error_outline_rounded,
                      message: 'Could not load recent transactions.',
                    ),
                  ),
                  data: (listState) {
                    if (listState.transactions.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: EmptyState(
                          icon: Icons.receipt_long_outlined,
                          message: 'No transactions yet. Your recent activity will show up here.',
                        ),
                      );
                    }
                    final recent = listState.transactions.take(5).toList();
                    return Column(
                      children: [
                        for (final transaction in recent)
                          TransactionListTile(
                            transaction: transaction,
                            onTap: () => context.push(
                              AppRoutes.transactionDetail(transaction.reference),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
