import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/referral_entry.dart';
import 'referral_repository_provider.dart';

class ReferralHistoryState {
  const ReferralHistoryState({
    this.entries = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  final List<ReferralEntry> entries;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  ReferralHistoryState copyWith({
    List<ReferralEntry>? entries,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ReferralHistoryState(
      entries: entries ?? this.entries,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Same pagination pattern as WalletLedgerController / TransactionListController.
class ReferralHistoryController extends AsyncNotifier<ReferralHistoryState> {
  @override
  Future<ReferralHistoryState> build() async {
    final result = await ref.read(referralRepositoryProvider).getHistory(page: 1);
    return ReferralHistoryState(
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
      final result = await ref.read(referralRepositoryProvider).getHistory(page: nextPage);
      state = AsyncData(current.copyWith(
        entries: [...current.entries, ...result.items],
        currentPage: result.currentPage,
        hasMore: result.hasMore,
        isLoadingMore: false,
      ));
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }
}

final referralHistoryProvider =
    AsyncNotifierProvider<ReferralHistoryController, ReferralHistoryState>(ReferralHistoryController.new);
