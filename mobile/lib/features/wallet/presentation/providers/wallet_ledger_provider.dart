import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/wallet_ledger_entry.dart';
import 'wallet_repository_provider.dart';

class WalletLedgerState {
  const WalletLedgerState({
    this.entries = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  final List<WalletLedgerEntry> entries;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  WalletLedgerState copyWith({
    List<WalletLedgerEntry>? entries,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return WalletLedgerState(
      entries: entries ?? this.entries,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Drives the wallet ledger list: initial load via [build], then
/// [loadMore] appends the next page. Pull-to-refresh should call
/// `ref.invalidate(walletLedgerProvider)` rather than a method here, since
/// that's the idiomatic way to force [build] to re-run from page 1.
class WalletLedgerController extends AsyncNotifier<WalletLedgerState> {
  @override
  Future<WalletLedgerState> build() async {
    final result = await ref.read(walletRepositoryProvider).getLedger(page: 1);
    return WalletLedgerState(
      entries: result.items,
      currentPage: result.currentPage,
      hasMore: result.hasMore,
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final nextPage = current.currentPage + 1;
      final result = await ref.read(walletRepositoryProvider).getLedger(page: nextPage);
      state = AsyncData(current.copyWith(
        entries: [...current.entries, ...result.items],
        currentPage: result.currentPage,
        hasMore: result.hasMore,
        isLoadingMore: false,
      ));
    } catch (_) {
      // Keep existing entries visible; just stop the loading spinner so the
      // user can retry by scrolling again rather than losing the list.
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }
}

final walletLedgerProvider =
    AsyncNotifierProvider<WalletLedgerController, WalletLedgerState>(WalletLedgerController.new);
