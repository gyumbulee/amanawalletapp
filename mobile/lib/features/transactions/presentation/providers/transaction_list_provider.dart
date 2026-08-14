import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/transaction.dart';
import 'transaction_filter_provider.dart';
import 'transaction_repository_provider.dart';

class TransactionListState {
  const TransactionListState({
    this.transactions = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  final List<Transaction> transactions;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  TransactionListState copyWith({
    List<Transaction>? transactions,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return TransactionListState(
      transactions: transactions ?? this.transactions,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Drives the transactions list. Watches [transactionFilterProvider] so
/// changing a filter or search term automatically re-runs [build] from
/// page 1 — no manual refresh wiring needed in the filter sheet/search bar.
class TransactionListController extends AsyncNotifier<TransactionListState> {
  @override
  Future<TransactionListState> build() async {
    final filter = ref.watch(transactionFilterProvider);
    final result = await ref.read(transactionRepositoryProvider).getTransactions(page: 1, filter: filter);
    return TransactionListState(
      transactions: result.items,
      currentPage: result.currentPage,
      hasMore: result.hasMore,
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final filter = ref.read(transactionFilterProvider);
      final nextPage = current.currentPage + 1;
      final result = await ref
          .read(transactionRepositoryProvider)
          .getTransactions(page: nextPage, filter: filter);
      state = AsyncData(current.copyWith(
        transactions: [...current.transactions, ...result.items],
        currentPage: result.currentPage,
        hasMore: result.hasMore,
        isLoadingMore: false,
      ));
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }
}

final transactionListProvider =
    AsyncNotifierProvider<TransactionListController, TransactionListState>(TransactionListController.new);
