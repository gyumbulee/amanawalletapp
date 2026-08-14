class AppConstants {
  AppConstants._();

  static const String appName = 'Amana Wallet';
  static const String tagline = 'Secure. Simple. Reliable.';

  static const int otpLength = 6;
  static const int pinLength = 4;

  static const Duration otpResendCooldown = Duration(seconds: 60);

  // Transaction statuses (must mirror the Laravel enum exactly)
  static const String txPending = 'pending';
  static const String txProcessing = 'processing';
  static const String txSuccessful = 'successful';
  static const String txFailed = 'failed';
  static const String txReversed = 'reversed';
}
