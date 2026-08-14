import 'package:intl/intl.dart';

/// All monetary amounts are handled as integer kobo on the wire (matching
/// the Laravel ledger's minor-unit storage) to avoid floating point drift.
/// These extensions convert kobo -> a display-ready Naira string.
extension NairaKoboExtension on int {
  /// e.g. 150000 (kobo) -> "₦1,500.00"
  String toNairaDisplay() {
    final naira = this / 100;
    final formatter = NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 2);
    return formatter.format(naira);
  }

  /// e.g. 150000 (kobo) -> "1,500.00" (no symbol, for form fields/receipts)
  String toNairaPlain() {
    final naira = this / 100;
    final formatter = NumberFormat('#,##0.00', 'en_NG');
    return formatter.format(naira);
  }
}

extension NairaDoubleExtension on double {
  /// Naira amount (e.g. from a text field) -> integer kobo for API payloads.
  int toKobo() => (this * 100).round();
}
