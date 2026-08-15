/// Route paths relative to EnvConfig.apiBaseUrl (which already includes
/// /api/v1). Update alongside the Laravel routes/api.php as modules land.
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const register = '/auth/register';
  static const login = '/auth/login';
  static const logout = '/auth/logout';
  static const verifyOtp = '/auth/verify-email';
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
  static const electricityValidate = '/electricity/validate';
  static const electricityPurchase = '/electricity/purchase';
  static const cableValidate = '/cable/validate';
  static const cablePurchase = '/cable/purchase';
  static const educationValidate = '/education/validate';
  static const educationPurchase = '/education/purchase';

  // Referral
  static const referralSummary = '/referral/summary';
  static const referralHistory = '/referral/history';

  // Notifications
  static const notifications = '/notifications';
  static String markNotificationRead(String id) => '/notifications/$id/read';
}
