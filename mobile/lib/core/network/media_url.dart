import '../config/env_config.dart';

/// Rewrites the host of backend-returned media URLs (profile photos, etc.)
/// to match the API host actually being used.
///
/// The backend generates these URLs from its own APP_URL config, which is
/// often `localhost` — fine when the backend and client run on the exact
/// same machine, but broken whenever testing over LAN/emulator/device,
/// since each device's "localhost" means itself, not the server. This
/// swaps `localhost`/`127.0.0.1` for the real host from [EnvConfig.apiBaseUrl]
/// so images actually resolve.
String fixMediaUrl(String? url) {
  if (url == null || url.isEmpty) return '';

  final uri = Uri.tryParse(url);
  if (uri == null) return url;

  final isLocalHost = uri.host == 'localhost' || uri.host == '127.0.0.1' || uri.host == '10.0.2.2';
  if (!isLocalHost) return url;

  final apiUri = Uri.tryParse(EnvConfig.apiBaseUrl);
  if (apiUri == null) return url;

  final fixed = uri.replace(
    scheme: apiUri.scheme,
    host: apiUri.host,
    port: apiUri.hasPort ? apiUri.port : null,
  );
  return fixed.toString();
}
