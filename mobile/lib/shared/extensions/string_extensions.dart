extension StringExtensions on String {
  bool get isValidEmail =>
      RegExp(r'^[\w\.\-+]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(this);

  /// Nigerian phone number: 11 digits starting with 0, or +234 format.
  bool get isValidNigerianPhone =>
      RegExp(r'^(0[789][01]\d{8}|\+234[789][01]\d{8})$').hasMatch(this);

  String get maskAccountNumber =>
      length <= 4 ? this : '${'*' * (length - 4)}${substring(length - 4)}';

  String get capitalizeFirst =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String get initials {
    final parts = trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
