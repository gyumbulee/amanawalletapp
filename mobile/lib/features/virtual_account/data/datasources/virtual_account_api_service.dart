import 'package:dio/dio.dart';
import '../../../../constants/api_endpoints.dart';

class VirtualAccountApiService {
  VirtualAccountApiService(this._dio);
  final Dio _dio;

  Future<Response> getVirtualAccount() => _dio.get(ApiEndpoints.virtualAccount);
}
