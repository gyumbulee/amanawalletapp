import 'package:dio/dio.dart';
import '../../../../constants/api_endpoints.dart';

class DataApiService {
  DataApiService(this._dio);
  final Dio _dio;

  Future<Response> getPlans({required String network}) {
    return _dio.get(ApiEndpoints.dataPlans, queryParameters: {'network': network});
  }

  Future<Response> purchase({
    required String network,
    required String variationCode,
    required String phone,
    required String transactionPin,
  }) {
    return _dio.post(ApiEndpoints.dataPurchase, data: {
      'network': network,
      'variation_code': variationCode,
      'phone': phone,
      'pin': transactionPin,
    });
  }
}
