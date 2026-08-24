import '../../../../core/network/error_mapper.dart';
import '../../../../core/network/paginated_result.dart';
import '../../domain/entities/support_ticket.dart';
import '../../domain/repositories/support_repository.dart';
import '../datasources/support_api_service.dart';
import '../models/support_ticket_model.dart';

class SupportRepositoryImpl implements SupportRepository {
  SupportRepositoryImpl(this._api);
  final SupportApiService _api;

  @override
  Future<PaginatedResult<SupportTicket>> getTickets({int page = 1}) async {
    try {
      final response = await _api.getTickets(page: page);
      final data = response.data as Map<String, dynamic>;
      final rawList = (data['tickets'] ?? data['data']) as List? ?? const [];
      final items = rawList.map((e) => SupportTicketModel.fromJson(e as Map<String, dynamic>)).toList();

      final meta = data['meta'] as Map<String, dynamic>?;
      return PaginatedResult(
        items: items,
        currentPage: meta?['current_page'] as int? ?? page,
        lastPage: meta?['last_page'] as int? ?? page,
      );
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<SupportTicket> getTicketDetail(String id) async {
    try {
      final response = await _api.getTicketDetail(id);
      final data = response.data as Map<String, dynamic>;
      final payload = data['ticket'] as Map<String, dynamic>;
      return SupportTicketModel.fromJson(payload);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<SupportTicket> createTicket({
    required String subject,
    required String message,
    String? transactionReference,
  }) async {
    try {
      final response = await _api.createTicket(
        subject: subject,
        message: message,
        transactionReference: transactionReference,
      );
      final data = response.data as Map<String, dynamic>;
      final payload = data['ticket'] as Map<String, dynamic>;
      return SupportTicketModel.fromJson(payload);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<SupportTicket> addMessage({required String ticketId, required String message}) async {
    try {
      final response = await _api.addMessage(ticketId: ticketId, message: message);
      final data = response.data as Map<String, dynamic>;
      final payload = data['ticket'] as Map<String, dynamic>;
      return SupportTicketModel.fromJson(payload);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }
}
