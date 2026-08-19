import 'package:dio/dio.dart';
import '../../../../constants/api_endpoints.dart';

class ProfileApiService {
  ProfileApiService(this._dio);
  final Dio _dio;

  Future<Response> getProfile() => _dio.get(ApiEndpoints.authMe);

  Future<Response> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
  }) {
    return _dio.put(ApiEndpoints.updateProfile, data: {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
    });
  }

  Future<Response> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) {
    return _dio.post(ApiEndpoints.changePassword, data: {
      'current_password': currentPassword,
      'password': newPassword,
      'password_confirmation': newPasswordConfirmation,
    });
  }

  Future<Response> setTransactionPin({
    required String pin,
    required String pinConfirmation,
  }) {
    return _dio.post(ApiEndpoints.setPin, data: {
      'pin': pin,
      'pin_confirmation': pinConfirmation,
    });
  }

  Future<Response> verifyBvn({required String bvn}) {
    return _dio.post(ApiEndpoints.verifyBvn, data: {'bvn': bvn});
  }

  Future<Response> uploadPhoto(String filePath) async {
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(filePath),
    });
    return _dio.post(ApiEndpoints.uploadPhoto, data: formData);
  }
}
