import 'package:dio/dio.dart';
import '../../../../constants/api_endpoints.dart';

class SupportApiService {
  SupportApiService(this._dio);
  final Dio _dio;

  Future<Response> getTickets({required int page}) {
    return _dio.get(ApiEndpoints.supportTickets, queryParameters: {'page': page});
  }

  Future<Response> getTicketDetail(String id) {
    return _dio.get(ApiEndpoints.supportTicketDetail(id));
  }

  Future<Response> createTicket({
    required String subject,
    required String message,
    String? transactionReference,
  }) {
    return _dio.post(ApiEndpoints.supportTickets, data: {
      'subject': subject,
      'message': message,
      if (transactionReference != null) 'transaction_reference': transactionReference,
    });
  }

  Future<Response> addMessage({required String ticketId, required String message}) {
    return _dio.post(ApiEndpoints.supportTicketMessages(ticketId), data: {'message': message});
  }
}
