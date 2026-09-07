import 'package:shared_preferences/shared_preferences.dart';

/// Wraps [SharedPreferences] for non-sensitive local state: theme choice,
/// onboarding-seen flags, last-used tab, etc. Never store tokens or PII here
/// — use [SecureStorageService] for that.
class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  static const _kThemeMode = 'theme_mode'; // 'system' | 'light' | 'dark'
  static const _kOnboardingSeen = 'onboarding_seen';
  static const _kLastEmail = 'last_login_email'; // convenience prefill only
  static const _kLastPromoSignature = 'last_promo_signature';
  static const _kLastPromoShownDate = 'last_promo_shown_date'; // yyyy-MM-dd

  String getThemeMode() => _prefs.getString(_kThemeMode) ?? 'system';
  Future<void> setThemeMode(String mode) => _prefs.setString(_kThemeMode, mode);

  bool getOnboardingSeen() => _prefs.getBool(_kOnboardingSeen) ?? false;
  Future<void> setOnboardingSeen(bool value) => _prefs.setBool(_kOnboardingSeen, value);

  String? getLastEmail() => _prefs.getString(_kLastEmail);
  Future<void> setLastEmail(String email) => _prefs.setString(_kLastEmail, email);

  /// [signature] identifies *which* banners were shown (e.g. their sorted
  /// IDs joined together) so a genuinely new banner still pops up even if
  /// it lands the same day as one already dismissed, while an unchanged
  /// set of banners won't nag the user again until tomorrow.
  String? getLastPromoSignature() => _prefs.getString(_kLastPromoSignature);
  String? getLastPromoShownDate() => _prefs.getString(_kLastPromoShownDate);

  Future<void> setLastPromoShown(String signature, String date) async {
    await _prefs.setString(_kLastPromoSignature, signature);
    await _prefs.setString(_kLastPromoShownDate, date);
  }

  Future<void> clear() => _prefs.clear();
}
