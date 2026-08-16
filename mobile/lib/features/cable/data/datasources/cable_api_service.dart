import 'package:dio/dio.dart';
import '../../../../constants/api_endpoints.dart';

class CableApiService {
  CableApiService(this._dio);
  final Dio _dio;

  Future<Response> getPackages({required String provider}) {
    return _dio.get(ApiEndpoints.cablePlans, queryParameters: {'cable_provider': provider});
  }

  Future<Response> validateSmartcard({
    required String provider,
    required String smartCardNumber,
  }) {
    return _dio.post(ApiEndpoints.cableValidate, data: {
      'cable_provider': provider,
      'smartcard_number': smartCardNumber,
    });
  }

  Future<Response> purchase({
    required String provider,
    required String smartCardNumber,
    required String variationCode,
    required String phone,
    required String transactionPin,
  }) {
    return _dio.post(ApiEndpoints.cablePurchase, data: {
      'cable_provider': provider,
      'smartcard_number': smartCardNumber,
      'variation_code': variationCode,
      'phone': phone,
      'pin': transactionPin,
    });
  }
}
