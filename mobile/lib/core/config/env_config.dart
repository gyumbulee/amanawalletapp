/// Environment configuration for Amana Wallet.
///
/// Switch [Env.current] (or better, pass `--dart-define=ENV=prod` at build
/// time) to point the app at the right API base URL.
enum Env { dev, staging, prod }

class EnvConfig {
  EnvConfig._();

  /// Change this default while developing locally, or override via
  /// `flutter run --dart-define=ENV=staging`.
  static const Env current = Env.dev;

  static const String _envOverride = String.fromEnvironment('ENV');

  static Env get _resolved {
    switch (_envOverride) {
      case 'prod':
        return Env.prod;
      case 'staging':
        return Env.staging;
      case 'dev':
        return Env.dev;
      default:
        return current;
    }
  }

  /// Base URL for the Laravel API, versioned at /api/v1.
  ///
  /// NOTE (dev defaults):
  /// - Android emulator -> host machine localhost is 10.0.2.2
  /// - iOS simulator    -> localhost works directly
  /// - Physical device / Web -> use your machine's LAN IP (e.g. 192.168.x.x)
  ///   or your Hostinger VPS URL once deployed.
  static String get apiBaseUrl {
    switch (_resolved) {
      case Env.dev:
        return const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'http://192.168.63.156:8000/api/v1',
        );
      case Env.staging:
        return const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://staging.amanawallet.com/api/v1',
        );
      case Env.prod:
        return const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://api.amanawallet.com/api/v1',
        );
    }
  }

  static bool get isDev => _resolved == Env.dev;
  static bool get isProd => _resolved == Env.prod;

  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
