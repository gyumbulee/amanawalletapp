import 'package:dio/dio.dart';
import '../../../../constants/api_endpoints.dart';

class TransactionApiService {
  TransactionApiService(this._dio);
  final Dio _dio;

  Future<Response> getTransactions({required int page, required Map<String, dynamic> filterParams}) {
    return _dio.get(ApiEndpoints.transactions, queryParameters: {
      'page': page,
      ...filterParams,
    });
  }

  Future<Response> getTransactionDetail(String reference) {
    return _dio.get(ApiEndpoints.transactionDetail(reference));
  }
}
