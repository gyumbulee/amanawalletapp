import 'package:equatable/equatable.dart';

/// A user's dedicated Flutterwave virtual account — the bank account
/// details customers transfer into to fund their wallet.
class VirtualAccount extends Equatable {
  const VirtualAccount({
    required this.accountNumber,
    required this.accountName,
    required this.bankName,
    required this.status,
    this.failureReason,
  });

  final String accountNumber;
  final String accountName;
  final String bankName;

  /// Raw backend status: 'pending' | 'active' | 'inactive' | 'failed'.
  /// Provisioning (App\Services\VirtualAccountService::provisionForUser)
  /// resolves synchronously to 'active' or 'failed' — 'pending' only exists
  /// for the brief window before the queued job runs, so in practice a
  /// user will almost never see it.
  final String status;

  /// Only ever populated by the backend when [status] is 'failed'.
  final String? failureReason;

  bool get isActive => status == 'active';
  bool get isFailed => status == 'failed';

  @override
  List<Object?> get props => [accountNumber, accountName, bankName, status, failureReason];
}
