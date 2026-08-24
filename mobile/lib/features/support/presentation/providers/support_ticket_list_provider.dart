import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/support_ticket.dart';
import 'support_repository_provider.dart';

class SupportTicketListState {
  const SupportTicketListState({
    this.tickets = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  final List<SupportTicket> tickets;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  SupportTicketListState copyWith({
    List<SupportTicket>? tickets,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return SupportTicketListState(
      tickets: tickets ?? this.tickets,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class SupportTicketListController extends AsyncNotifier<SupportTicketListState> {
  @override
  Future<SupportTicketListState> build() async {
    final result = await ref.read(supportRepositoryProvider).getTickets(page: 1);
    return SupportTicketListState(
      tickets: result.items,
      currentPage: result.currentPage,
      hasMore: result.hasMore,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(supportRepositoryProvider).getTickets(page: 1);
      return SupportTicketListState(
        tickets: result.items,
        currentPage: result.currentPage,
        hasMore: result.hasMore,
      );
    });
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final nextPage = current.currentPage + 1;
      final result = await ref.read(supportRepositoryProvider).getTickets(page: nextPage);
      state = AsyncData(current.copyWith(
        tickets: [...current.tickets, ...result.items],
        currentPage: result.currentPage,
        hasMore: result.hasMore,
        isLoadingMore: false,
      ));
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }
}

final supportTicketListProvider =
    AsyncNotifierProvider<SupportTicketListController, SupportTicketListState>(SupportTicketListController.new);
