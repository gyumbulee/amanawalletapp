import 'package:dio/dio.dart';
import '../../../../constants/api_endpoints.dart';

class WalletApiService {
  WalletApiService(this._dio);
  final Dio _dio;

  Future<Response> getBalance() => _dio.get(ApiEndpoints.walletBalance);

  Future<Response> getLedger({int page = 1}) =>
      _dio.get(ApiEndpoints.walletLedger, queryParameters: {'page': page});
}
