import '../../../auth/domain/entities/auth_user.dart';

/// Reuses [AuthUser] from the auth feature rather than a separate Profile
/// entity — it already carries every field the Profile screen needs
/// (name, email, phone, avatarUrl, hasTransactionPin, isBvnVerified), and
/// GET /auth/me / PUT /profile both describe the same underlying user.
abstract class ProfileRepository {
  /// There's no GET /profile route per the API spec — the current user is
  /// fetched via GET /auth/me instead.
  Future<AuthUser> getProfile();

  Future<AuthUser> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  });

  Future<void> setTransactionPin({
    required String pin,
    required String pinConfirmation,
  });

  Future<void> verifyBvn({required String bvn});

  /// Returns the new avatar URL on success.
  Future<String> uploadPhoto(String filePath);
}
