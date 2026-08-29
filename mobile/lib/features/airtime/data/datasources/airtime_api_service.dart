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
    required String idempotencyKey,
  }) {
    return _dio.post(
      ApiEndpoints.airtimePurchase,
      data: {
        'network': network,
        'phone': phone,
        // Backend expects amount in plain Naira, not kobo — same fix as
        // electricity. Rounded (not truncated) in case of decimal input.
        'amount': (amountKobo / 100).round(),
        'pin': transactionPin,
      },
      // Lets the backend recognise a retry of THIS SAME attempt (e.g. after
      // a dropped connection) and return the original result instead of
      // charging the wallet / buying airtime a second time.
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
  }
}
