import '../../domain/entities/virtual_account.dart';

/// JSON <-> [VirtualAccount] mapping.
///
/// `GET /virtual-account` returns, nested under `"virtual_account"`:
/// `{ "id": "...", "account_number": "...", "account_name": "...",
///    "bank_name": "...", "status": "active", "created_at": "..." }`
/// (unwrapping the "virtual_account" key happens in the repository).
class VirtualAccountModel {
  static VirtualAccount fromJson(Map<String, dynamic> json) {
    return VirtualAccount(
      accountNumber: json['account_number'] as String? ?? '',
      accountName: json['account_name'] as String? ?? '',
      bankName: json['bank_name'] as String? ?? '',
      isActive: (json['status'] as String?)?.toLowerCase() == 'active',
    );
  }
}

