import 'package:dio/dio.dart';
import '../../../../constants/api_endpoints.dart';

class ReferralApiService {
  ReferralApiService(this._dio);
  final Dio _dio;

  Future<Response> getSummary() => _dio.get(ApiEndpoints.referralSummary);

  Future<Response> getHistory({int page = 1}) =>
      _dio.get(ApiEndpoints.referralHistory, queryParameters: {'page': page});
}
