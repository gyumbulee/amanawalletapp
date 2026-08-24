import '../../../../core/network/paginated_result.dart';
import '../entities/support_ticket.dart';

abstract class SupportRepository {
  Future<PaginatedResult<SupportTicket>> getTickets({int page = 1});

  Future<SupportTicket> getTicketDetail(String id);

  Future<SupportTicket> createTicket({
    required String subject,
    required String message,
    String? transactionReference,
  });

  Future<SupportTicket> addMessage({required String ticketId, required String message});
}
