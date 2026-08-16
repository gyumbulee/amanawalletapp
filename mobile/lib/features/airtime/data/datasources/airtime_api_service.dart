import 'package:dio/dio.dart';
import '../../../../constants/api_endpoints.dart';

class AirtimeApiService {
  AirtimeApiService(this._dio);
  final Dio _dio;

  Future<Response> purchase({
    required String network,
    required String phone,
    required int amountKobo,
    required String transactionPin,
  }) {
    return _dio.post(ApiEndpoints.airtimePurchase, data: {
      'network': network,
      'phone': phone,
      // Backend expects amount in plain Naira, not kobo — same fix as
      // electricity. Rounded (not truncated) in case of decimal input.
      'amount': (amountKobo / 100).round(),
      'pin': transactionPin,
    });
  }
}
