import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

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
import '../../domain/entities/promo_banner.dart';
import '../providers/banners_provider.dart';
import '../widgets/banner_carousel.dart';
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

  // Keep in sync with the Filament BannerResource's SERVICE_LINKS options.
  static const _serviceRoutes = {
    'wallet_funding': AppRoutes.virtualAccount,
    'airtime': AppRoutes.airtime,
    'data': AppRoutes.dataBundle,
    'electricity': AppRoutes.electricity,
    'cable': AppRoutes.cable,
    'education': AppRoutes.education,
    'referral': AppRoutes.referral,
  };

  Future<void> _onBannerTap(PromoBanner banner) async {
    if (banner.linkType == 'service') {
      final route = _serviceRoutes[banner.linkValue];
      if (route != null) context.push(route);
      return;
    }

    if (banner.linkType == 'url' && banner.linkValue != null) {
      final uri = Uri.tryParse(banner.linkValue!);
      if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authSessionProvider);
    final balanceAsync = ref.watch(walletBalanceProvider);
    final accountAsync = ref.watch(virtualAccountProvider);
    final bannersAsync = ref.watch(bannersProvider);

    return ResponsiveScaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(walletBalanceProvider.notifier).refresh();
          ref.invalidate(virtualAccountProvider);
          ref.invalidate(bannersProvider);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () => context.push(AppRoutes.profile),
                  customBorder: const CircleBorder(),
                  child: Builder(builder: (context) {
                    final hasAvatar = (user?.avatarUrl ?? '').isNotEmpty;
                    return CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary,
                      backgroundImage: hasAvatar ? NetworkImage(user!.avatarUrl!) : null,
                      child: !hasAvatar
                          ? Text(
                              (user?.name ?? '').initials,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            )
                          : null,
                    );
                  }),
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
            bannersAsync.when(
              // Deliberately quiet on loading/error/empty — a promo carousel
              // failing to load shouldn't ever block or clutter the dashboard.
              loading: () => const SizedBox.shrink(),
              error: (error, _) => const SizedBox.shrink(),
              data: (banners) => banners.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: BannerCarousel(banners: banners, onTap: _onBannerTap),
                    ),
            ),
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
                  color: AppColors.actionFundWallet,
                  onTap: () => context.push(AppRoutes.virtualAccount),
                ),
                QuickActionItem(
                  icon: Icons.phone_iphone_rounded,
                  label: 'Airtime',
                  color: AppColors.actionAirtime,
                  onTap: () => context.push(AppRoutes.airtime),
                ),
                QuickActionItem(
                  icon: Icons.wifi_rounded,
                  label: 'Data',
                  color: AppColors.actionData,
                  onTap: () => context.push(AppRoutes.dataBundle),
                ),
                QuickActionItem(
                  icon: Icons.bolt_rounded,
                  label: 'Electricity',
                  color: AppColors.actionElectricity,
                  onTap: () => context.push(AppRoutes.electricity),
                ),
                QuickActionItem(
                  icon: Icons.tv_rounded,
                  label: 'Cable TV',
                  color: AppColors.actionCable,
                  onTap: () => context.push(AppRoutes.cable),
                ),
                QuickActionItem(
                  icon: Icons.school_outlined,
                  label: 'Education',
                  color: AppColors.actionEducation,
                  onTap: () => context.push(AppRoutes.education),
                ),
                QuickActionItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'Transactions',
                  color: AppColors.actionTransactions,
                  onTap: () => context.push(AppRoutes.transactions),
                ),
                QuickActionItem(
                  icon: Icons.card_giftcard_outlined,
                  label: 'Referral',
                  color: AppColors.actionReferral,
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
                              AppRoutes.transactionDetail(transaction.id),
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
