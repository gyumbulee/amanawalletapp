import '../../../../core/network/media_url.dart';
import '../../domain/entities/auth_user.dart';

/// JSON <-> [AuthUser] mapping. Adjust the key names here if the Laravel
/// UserResource field names differ once you wire this against the live API.
class AuthUserModel {
  static AuthUser fromJson(Map<String, dynamic> json) {
    // Field name unconfirmed here — mirrors "profile_photo_url" confirmed
    // on the upload response, with fallbacks in case /auth/me differs.
    final rawAvatarUrl =
        (json['profile_photo_url'] ?? json['avatar_url'] ?? json['photo_url']) as String?;

    return AuthUser(
      id: json['id'].toString(),
      name: _resolveName(json),
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      referralCode: json['referral_code'] as String? ?? '',
      isEmailVerified: json['email_verified_at'] != null || json['is_email_verified'] == true,
      avatarUrl: rawAvatarUrl != null ? fixMediaUrl(rawAvatarUrl) : null,
      hasTransactionPin: json['has_transaction_pin'] as bool? ?? false,
      isBvnVerified: json['is_bvn_verified'] as bool? ?? false,
    );
  }

  /// Backend stores/returns first_name + last_name separately; fall back to
  /// a combined "name" key if that's ever present instead (e.g. a future
  /// endpoint that returns a display name directly).
  static String _resolveName(Map<String, dynamic> json) {
    final firstName = json['first_name'] as String?;
    final lastName = json['last_name'] as String?;
    if (firstName != null || lastName != null) {
      return [firstName, lastName].where((n) => n != null && n.isNotEmpty).join(' ');
    }
    return json['name'] as String? ?? '';
  }
}
