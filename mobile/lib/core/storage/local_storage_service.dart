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

  String getThemeMode() => _prefs.getString(_kThemeMode) ?? 'system';
  Future<void> setThemeMode(String mode) => _prefs.setString(_kThemeMode, mode);

  bool getOnboardingSeen() => _prefs.getBool(_kOnboardingSeen) ?? false;
  Future<void> setOnboardingSeen(bool value) => _prefs.setBool(_kOnboardingSeen, value);

  String? getLastEmail() => _prefs.getString(_kLastEmail);
  Future<void> setLastEmail(String email) => _prefs.setString(_kLastEmail, email);

  Future<void> clear() => _prefs.clear();
}
