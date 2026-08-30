import 'package:dio/dio.dart';
import '../../../../constants/api_endpoints.dart';

class DataApiService {
  DataApiService(this._dio);
  final Dio _dio;

  Future<Response> getCategories({required String network}) {
    return _dio.get(ApiEndpoints.dataCategories, queryParameters: {'network': network});
  }

  Future<Response> getPlans({required String network, String? category}) {
    return _dio.get(ApiEndpoints.dataPlans, queryParameters: {
      'network': network,
      if (category != null) 'category': category,
    });
  }

  Future<Response> purchase({
    required String network,
    required String variationCode,
    required String phone,
    required String transactionPin,
    required String idempotencyKey,
  }) {
    return _dio.post(
      ApiEndpoints.dataPurchase,
      data: {
        'network': network,
        'variation_code': variationCode,
        'phone': phone,
        'pin': transactionPin,
      },
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
  }
}
