import 'package:dio/dio.dart';
import '../../../../constants/api_endpoints.dart';

class EducationApiService {
  EducationApiService(this._dio);
  final Dio _dio;

  Future<Response> getPlans({required String examType}) {
    return _dio.get(ApiEndpoints.educationPlans, queryParameters: {'education_type': examType});
  }

  Future<Response> validateProfile({
    required String examType,
    required String variationCode,
    required String profileId,
  }) {
    return _dio.post(ApiEndpoints.educationValidate, data: {
      'education_type': examType,
      'variation_code': variationCode,
      'profile_id': profileId,
    });
  }

  Future<Response> purchase({
    required String examType,
    required String variationCode,
    required String phone,
    required String transactionPin,
    String? profileId,
  }) {
    return _dio.post(ApiEndpoints.educationPurchase, data: {
      'education_type': examType,
      'variation_code': variationCode,
      'phone': phone,
      'pin': transactionPin,
      if (profileId != null && profileId.isNotEmpty) 'profile_id': profileId,
    });
  }
}
