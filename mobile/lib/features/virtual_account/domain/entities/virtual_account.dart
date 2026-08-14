import 'package:equatable/equatable.dart';

/// A user's dedicated Flutterwave virtual account — the bank account
/// details customers transfer into to fund their wallet.
class VirtualAccount extends Equatable {
  const VirtualAccount({
    required this.accountNumber,
    required this.accountName,
    required this.bankName,
    required this.isActive,
  });

  final String accountNumber;
  final String accountName;
  final String bankName;
  final bool isActive;

  @override
  List<Object?> get props => [accountNumber, accountName, bankName, isActive];
}
