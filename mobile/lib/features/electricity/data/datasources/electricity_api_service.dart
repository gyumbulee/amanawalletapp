import 'package:dio/dio.dart';
import '../../../../constants/api_endpoints.dart';

class ElectricityApiService {
  ElectricityApiService(this._dio);
  final Dio _dio;

  Future<Response> validateMeter({
    required String disco,
    required String meterType,
    required String meterNumber,
  }) {
    return _dio.post(ApiEndpoints.electricityValidate, data: {
      'disco': disco,
      'meter_type': meterType,
      'meter_number': meterNumber,
    });
  }

  Future<Response> purchase({
    required String disco,
    required String meterType,
    required String meterNumber,
    required int amountKobo,
    required String phone,
    required String transactionPin,
  }) {
    return _dio.post(ApiEndpoints.electricityPurchase, data: {
      'disco': disco,
      'meter_type': meterType,
      'meter_number': meterNumber,
      // Backend expects amount in plain Naira, not kobo — same convention
      // as wallet balance and data plan amounts. Rounded (not truncated)
      // in case of decimal Naira input, e.g. ₦50.50.
      'amount': (amountKobo / 100).round(),
      'phone': phone,
      'pin': transactionPin,
    });
  }
}
