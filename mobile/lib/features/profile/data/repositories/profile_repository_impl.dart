import 'dart:typed_data';
import '../../../../core/network/error_mapper.dart';
import '../../../../core/network/media_url.dart';
import '../../../auth/data/models/auth_user_model.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_api_service.dart';

/// Response shapes are best-effort guesses following this backend's
/// established conventions (named-key wrapping, e.g. "user") — verify
/// against real requests the same way every other module needed a round
/// of fixes.
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._api);
  final ProfileApiService _api;

  AuthUser _parseUser(dynamic responseData) {
    final data = responseData as Map<String, dynamic>;
    final payload = data['user'] is Map
        ? data['user'] as Map<String, dynamic>
        : (data['data'] is Map ? data['data'] as Map<String, dynamic> : data);
    return AuthUserModel.fromJson(payload);
  }

  @override
  Future<AuthUser> getProfile() async {
    try {
      final response = await _api.getProfile();
      return _parseUser(response.data);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<AuthUser> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    try {
      final response = await _api.updateProfile(firstName: firstName, lastName: lastName, phone: phone);
      return _parseUser(response.data);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      await _api.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<void> setTransactionPin({required String pin, required String pinConfirmation}) async {
    try {
      await _api.setTransactionPin(pin: pin, pinConfirmation: pinConfirmation);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<void> verifyBvn({required String bvn}) async {
    try {
      await _api.verifyBvn(bvn: bvn);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<String> uploadPhoto(Uint8List bytes, String filename) async {
    try {
      final response = await _api.uploadPhoto(bytes, filename);
      final data = response.data as Map<String, dynamic>;
      final payload = data['user'] is Map ? data['user'] as Map<String, dynamic> : data;
      // Confirmed real field name: "profile_photo_url" — not "avatar_url"
      // or "photo_url" as first guessed.
      final rawUrl = (payload['profile_photo_url'] ?? payload['avatar_url'] ?? payload['photo_url']) as String?;
      return fixMediaUrl(rawUrl);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }
}
