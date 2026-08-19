import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/extensions/currency_extensions.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/empty_states/empty_state.dart';
import '../../../../shared/widgets/loaders/skeleton_loader.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../theme/app_colors.dart';
import '../providers/referral_history_provider.dart';
import '../providers/referral_summary_provider.dart';
import '../widgets/referral_entry_tile.dart';

class ReferralScreen extends ConsumerStatefulWidget {
  const ReferralScreen({super.key});

  @override
  ConsumerState<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends ConsumerState<ReferralScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(referralHistoryProvider.notifier).loadMore();
    }
  }

  Future<void> _refresh() async {
    await ref.read(referralSummaryProvider.notifier).refresh();
    ref.invalidate(referralHistoryProvider);
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(referralSummaryProvider);
    final historyAsync = ref.watch(referralHistoryProvider);

    return ResponsiveScaffold(
      appBar: AppBar(title: const Text('Referral')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            summaryAsync.when(
              loading: () => const Column(
                children: [
                  SkeletonLoader(height: 140, borderRadius: BorderRadius.all(Radius.circular(16))),
                ],
              ),
              error: (error, _) => EmptyState(
                icon: Icons.error_outline_rounded,
                message: 'Could not load your referral details.',
                actionLabel: 'Retry',
                onAction: () => ref.read(referralSummaryProvider.notifier).refresh(),
              ),
              data: (summary) => Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Referral Code',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                summary.referralCode,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: summary.referralCode));
                                context.showSnack('Referral code copied');
                              },
                              icon: const Icon(Icons.copy_rounded, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Share your code — you both earn a bonus when they sign up and fund their wallet.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Referrals',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${summary.referralCount}',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Earnings',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                summary.totalEarningsKobo.toNairaDisplay(),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Referral History', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            historyAsync.when(
              loading: () => Column(children: List.generate(4, (_) => const SkeletonListTile())),
              error: (error, _) => const Padding(
                padding: EdgeInsets.only(top: 20),
                child: EmptyState(
                  icon: Icons.error_outline_rounded,
                  message: 'Could not load referral history. Pull down to try again.',
                ),
              ),
              data: (historyState) {
                if (historyState.entries.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: EmptyState(
                      icon: Icons.group_outlined,
                      message: "You haven't referred anyone yet. Share your code to get started.",
                    ),
                  );
                }
                return Column(
                  children: [
                    ...historyState.entries.map((entry) => ReferralEntryTile(entry: entry)),
                    if (historyState.isLoadingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                  ],
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
