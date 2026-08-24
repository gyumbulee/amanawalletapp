import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/support_ticket.dart';
import 'support_repository_provider.dart';
import 'support_ticket_list_provider.dart';

class CreateTicketController extends AsyncNotifier<SupportTicket?> {
  @override
  SupportTicket? build() => null;

  Future<void> submit({
    required String subject,
    required String message,
    String? transactionReference,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final ticket = await ref.read(supportRepositoryProvider).createTicket(
            subject: subject,
            message: message,
            transactionReference: transactionReference,
          );
      // So the ticket list reflects the new ticket next time it's opened,
      // without forcing an eager refetch right now.
      ref.invalidate(supportTicketListProvider);
      return ticket;
    });
  }
}

final createTicketControllerProvider =
    AsyncNotifierProvider<CreateTicketController, SupportTicket?>(CreateTicketController.new);
