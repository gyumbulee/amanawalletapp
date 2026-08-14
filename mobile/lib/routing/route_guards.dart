import 'package:go_router/go_router.dart';

/// Paths reachable without a session.
const List<String> publicPaths = [
  '/login',
  '/register',
  '/verify-otp',
  '/forgot-password',
  '/reset-password',
];

/// Decides whether to redirect based on current auth status.
///
/// - Logged out + hitting a private route -> send to /login
/// - Logged in + hitting an auth route (e.g. /login) -> send to /dashboard
/// - Otherwise -> no redirect (null)
String? authRedirect({
  required bool isAuthenticated,
  required String currentPath,
}) {
  final isPublic = publicPaths.any((p) => currentPath.startsWith(p));

  if (!isAuthenticated && !isPublic) {
    return '/login';
  }
  if (isAuthenticated && isPublic) {
    return '/dashboard';
  }
  return null;
}

/// Small helper so app_router.dart can pull the current location out of
/// GoRouterState consistently across go_router versions.
extension GoRouterStateLocation on GoRouterState {
  String get currentPath => uri.toString();
}
