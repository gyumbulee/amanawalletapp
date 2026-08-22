import 'dart:typed_data';
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

  /// Takes raw bytes rather than a file path — `MultipartFile.fromFile`
  /// needs a real filesystem path, which Flutter Web's image_picker
  /// doesn't provide (it returns a blob URL instead). Reading bytes via
  /// `XFile.readAsBytes()` works uniformly on web and mobile.
  Future<Response> uploadPhoto(Uint8List bytes, String filename) async {
    final formData = FormData.fromMap({
      'photo': MultipartFile.fromBytes(bytes, filename: filename),
    });
    return _dio.post(ApiEndpoints.uploadPhoto, data: formData);
  }
}
