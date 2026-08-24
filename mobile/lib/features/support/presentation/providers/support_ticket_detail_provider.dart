import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/support_ticket.dart';
import 'support_repository_provider.dart';

/// Family provider keyed by ticket id, so the detail/thread screen can
/// `ref.watch` a specific ticket and `.refresh()`/`.sendReply()` on it
/// without affecting the ticket list state.
class SupportTicketDetailController extends FamilyAsyncNotifier<SupportTicket, String> {
  @override
  Future<SupportTicket> build(String arg) {
    return ref.read(supportRepositoryProvider).getTicketDetail(arg);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(supportRepositoryProvider).getTicketDetail(arg));
  }

  /// Deliberately doesn't wrap state in AsyncLoading/AsyncValue.guard the
  /// way [refresh] does — a failed send shouldn't blank out the thread the
  /// user is looking at. Callers should try/catch this and show the error
  /// (via ErrorMapper) without losing their place in the conversation.
  Future<void> sendReply(String message) async {
    final updated = await ref.read(supportRepositoryProvider).addMessage(ticketId: arg, message: message);
    state = AsyncData(updated);
  }
}

final supportTicketDetailProvider =
    AsyncNotifierProvider.family<SupportTicketDetailController, SupportTicket, String>(
  SupportTicketDetailController.new,
);
