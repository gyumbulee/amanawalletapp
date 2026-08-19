/// Route paths relative to EnvConfig.apiBaseUrl (which already includes
/// /api/v1). Update alongside the Laravel routes/api.php as modules land.
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const register = '/auth/register';
  static const login = '/auth/login';
  static const logout = '/auth/logout';
  static const authMe = '/auth/me';
  static const verifyOtp = '/auth/verify-otp';
  static const resendOtp = '/auth/resend-otp';
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword = '/auth/reset-password';

  // Profile
  static const profile = '/profile';
  static const updateProfile = '/profile';
  static const changePassword = '/profile/change-password';
  static const setPin = '/profile/set-pin';
  static const verifyBvn = '/profile/verify-bvn';
  static const uploadPhoto = '/profile/photo';

  // Wallet
  static const walletBalance = '/wallet';
  static const walletLedger = '/wallet/ledger';

  // Virtual account
  static const virtualAccount = '/virtual-account';

  // Transactions
  static const transactions = '/transactions';
  static String transactionDetail(String ref) => '/transactions/$ref';

  // Bill payments
  static const airtimePurchase = '/airtime/purchase';
  static const dataPurchase = '/data/purchase';
  static const dataPlans = '/data/plans';
  static const electricityValidate = '/electricity/verify-meter';
  static const electricityPurchase = '/electricity/purchase';
  static const cablePlans = '/cable/plans';
  // NOTE: electricityValidate was actually '/electricity/verify-meter', not
  // '/electricity/validate' as first assumed — the naming convention here
  // is a guess following that same pattern. Check the real route if this
  // 404s (same fix as electricity: paste the 404 response back).
  static const cableValidate = '/cable/verify-smartcard';
  static const cablePurchase = '/cable/purchase';
  static const educationPlans = '/education/plans';
  // NOTE: electricity's actual validate route was '/electricity/verify-meter'
  // and cable's field name turned out to be 'cable_provider' (prefixed),
  // not the plain 'provider'/'disco' first guessed. Naming here follows
  // that same pattern but is unconfirmed — check the real route/fields if
  // this 404s or 422s, same fix as electricity/cable needed.
  static const educationValidate = '/education/verify-profile';
  static const educationPurchase = '/education/purchase';

  // Referral
  static const referralSummary = '/referrals/summary';
  static const referralHistory = '/referrals/history';

  // Notifications
  static const notifications = '/notifications';
  static const notificationsUnreadCount = '/notifications/unread-count';
  static const notificationsMarkAllRead = '/notifications/read-all';
  static String markNotificationRead(String id) => '/notifications/$id/read';
}
