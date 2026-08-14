import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/otp_verify_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/transactions/presentation/screens/transaction_detail_screen.dart';
import '../features/transactions/presentation/screens/transactions_screen.dart';
import '../features/virtual_account/presentation/screens/virtual_account_screen.dart';
import '../features/wallet/presentation/screens/wallet_screen.dart';
import '../providers/global_providers.dart';
import '../shared/widgets/empty_states/coming_soon_screen.dart';
import 'route_guards.dart';

/// Named route paths — reference these instead of hardcoding strings when
/// navigating (`context.go(AppRoutes.dashboard)`), so refactors don't break
/// deep links, especially on Web.
class AppRoutes {
  AppRoutes._();

  static const login = '/login';
  static const register = '/register';
  static const verifyOtp = '/verify-otp';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';

  static const dashboard = '/dashboard';
  static const wallet = '/wallet';
  static const virtualAccount = '/virtual-account';
  static const transactions = '/transactions';
  static String transactionDetail(String reference) => '/transactions/$reference';
  static const airtime = '/airtime';
  static const dataBundle = '/data';
  static const electricity = '/electricity';
  static const cable = '/cable';
  static const education = '/education';
  static const referral = '/referral';
  static const notifications = '/notifications';
  static const profile = '/profile';
  static const settings = '/settings';
}

/// Router is a provider so it can watch [isAuthenticatedProvider] and
/// re-evaluate redirects reactively (e.g. right after logout or a 401).
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authAsync = ref.read(isAuthenticatedProvider);
      // While the auth check is still resolving, don't redirect yet —
      // avoids a flash to /login before secure storage has been read.
      final isAuthenticated = authAsync.asData?.value ?? false;
      if (authAsync.isLoading) return null;
      return authRedirect(isAuthenticated: isAuthenticated, currentPath: state.currentPath);
    },
    refreshListenable: GoRouterRefreshStream(ref),
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) {
          final referralCode = state.uri.queryParameters['ref'];
          return RegisterScreen(referralCode: referralCode);
        },
      ),
      GoRoute(
        path: AppRoutes.verifyOtp,
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return OtpVerifyScreen(email: email);
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return ResetPasswordScreen(email: email);
        },
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.wallet,
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: AppRoutes.virtualAccount,
        builder: (context, state) => const VirtualAccountScreen(),
      ),
      GoRoute(
        path: AppRoutes.transactions,
        builder: (context, state) => const TransactionsScreen(),
        routes: [
          GoRoute(
            path: ':reference',
            builder: (context, state) {
              final reference = state.pathParameters['reference'] ?? '';
              return TransactionDetailScreen(reference: reference);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.airtime,
        builder: (context, state) => const ComingSoonScreen(featureName: 'Airtime'),
      ),
      GoRoute(
        path: AppRoutes.dataBundle,
        builder: (context, state) => const ComingSoonScreen(featureName: 'Data'),
      ),
      GoRoute(
        path: AppRoutes.electricity,
        builder: (context, state) => const ComingSoonScreen(featureName: 'Electricity'),
      ),
      GoRoute(
        path: AppRoutes.cable,
        builder: (context, state) => const ComingSoonScreen(featureName: 'Cable TV'),
      ),
      GoRoute(
        path: AppRoutes.education,
        builder: (context, state) => const ComingSoonScreen(featureName: 'Education'),
      ),
      GoRoute(
        path: AppRoutes.referral,
        builder: (context, state) => const ComingSoonScreen(featureName: 'Referral'),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const ComingSoonScreen(featureName: 'Notifications'),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ComingSoonScreen(featureName: 'Profile'),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const ComingSoonScreen(featureName: 'Settings'),
      ),
    ],
  );
});

/// Bridges Riverpod's [isAuthenticatedProvider] to a [Listenable] so
/// GoRouter's `refreshListenable` re-runs `redirect` whenever auth status
/// changes (login, logout, 401-triggered token clear).
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Ref ref) {
    ref.listen(isAuthenticatedProvider, (_, __) => notifyListeners());
  }
}
