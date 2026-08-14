import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps [FlutterSecureStorage] for anything sensitive: the Sanctum bearer
/// token and transaction-PIN-related flags.
///
/// NOTE (web): flutter_secure_storage falls back to browser storage on Web,
/// which is not as secure as Keychain/Keystore on mobile. Treat Web sessions
/// as lower-trust — shorter token lifetime / step-up re-auth for sensitive
/// actions (PIN change, BVN verification) should be enforced server-side
/// regardless of what the client does.
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  final FlutterSecureStorage _storage;

  static const _kAuthToken = 'auth_token';
  static const _kPinSet = 'pin_set';

  Future<void> saveAuthToken(String token) => _storage.write(key: _kAuthToken, value: token);
  Future<String?> getAuthToken() => _storage.read(key: _kAuthToken);
  Future<void> deleteAuthToken() => _storage.delete(key: _kAuthToken);

  Future<void> setPinConfigured(bool value) =>
      _storage.write(key: _kPinSet, value: value.toString());
  Future<bool> isPinConfigured() async =>
      (await _storage.read(key: _kPinSet)) == 'true';

  /// Full wipe on logout.
  Future<void> clearAll() => _storage.deleteAll();
}
