import '../../domain/entities/virtual_account.dart';

/// JSON <-> [VirtualAccount] mapping.
///
/// Assumes `GET /virtual-account` returns:
/// `{ "account_number": "...", "account_name": "...", "bank_name": "...", "is_active": true }`
/// (or the same fields nested one level under "data" — both are handled in
/// the repository, not here).
class VirtualAccountModel {
  static VirtualAccount fromJson(Map<String, dynamic> json) {
    return VirtualAccount(
      accountNumber: json['account_number'] as String? ?? '',
      accountName: json['account_name'] as String? ?? '',
      bankName: json['bank_name'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
