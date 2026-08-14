import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/app_router.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/cards/wallet_card.dart';
import '../../../../shared/widgets/empty_states/empty_state.dart';
import '../../../../shared/widgets/loaders/skeleton_loader.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../virtual_account/presentation/providers/virtual_account_provider.dart';
import '../providers/wallet_balance_provider.dart';
import '../providers/wallet_ledger_provider.dart';
import '../widgets/ledger_list_tile.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
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
      ref.read(walletLedgerProvider.notifier).loadMore();
    }
  }

  Future<void> _refresh() async {
    await ref.read(walletBalanceProvider.notifier).refresh();
    ref.invalidate(walletLedgerProvider);
  }

  @override
  Widget build(BuildContext context) {
    final balanceAsync = ref.watch(walletBalanceProvider);
    final accountAsync = ref.watch(virtualAccountProvider);
    final ledgerAsync = ref.watch(walletLedgerProvider);

    return ResponsiveScaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            balanceAsync.when(
              loading: () => const WalletCard(balanceInKobo: 0, isLoading: true),
              error: (error, _) => const WalletCard(balanceInKobo: 0, isLoading: false),
              data: (balance) => WalletCard(
                balanceInKobo: balance.balanceKobo,
                accountNumber: accountAsync.asData?.value.accountNumber,
                bankName: accountAsync.asData?.value.bankName,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Fund Wallet',
                icon: Icons.add_rounded,
                onPressed: () => context.push(AppRoutes.virtualAccount),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            ledgerAsync.when(
              loading: () => Column(
                children: List.generate(4, (_) => const SkeletonListTile()),
              ),
              error: (error, _) => const Padding(
                padding: EdgeInsets.only(top: 20),
                child: EmptyState(
                  icon: Icons.error_outline_rounded,
                  message: 'Could not load wallet history. Pull down to try again.',
                ),
              ),
              data: (ledgerState) {
                if (ledgerState.entries.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: EmptyState(
                      icon: Icons.receipt_long_outlined,
                      message: 'No wallet activity yet.',
                    ),
                  );
                }
                return Column(
                  children: [
                    ...ledgerState.entries.map((entry) => LedgerListTile(entry: entry)),
                    if (ledgerState.isLoadingMore)
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
