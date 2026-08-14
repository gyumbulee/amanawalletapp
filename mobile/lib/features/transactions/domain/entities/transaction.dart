import 'package:equatable/equatable.dart';

/// Mirrors the backend's transaction "service" values — every operation
/// creates exactly one transaction, per the project spec.
enum TransactionService {
  walletFunding,
  airtime,
  data,
  electricity,
  cable,
  education,
  referralBonus,
  unknown;

  static TransactionService fromApi(String? value) {
    switch (value) {
      case 'wallet_funding':
        return TransactionService.walletFunding;
      case 'airtime':
        return TransactionService.airtime;
      case 'data':
        return TransactionService.data;
      case 'electricity':
        return TransactionService.electricity;
      case 'cable':
        return TransactionService.cable;
      case 'education':
        return TransactionService.education;
      case 'referral_bonus':
        return TransactionService.referralBonus;
      default:
        return TransactionService.unknown;
    }
  }

  /// For building filter query params — kept the inverse of [fromApi].
  String get apiValue {
    switch (this) {
      case TransactionService.walletFunding:
        return 'wallet_funding';
      case TransactionService.airtime:
        return 'airtime';
      case TransactionService.data:
        return 'data';
      case TransactionService.electricity:
        return 'electricity';
      case TransactionService.cable:
        return 'cable';
      case TransactionService.education:
        return 'education';
      case TransactionService.referralBonus:
        return 'referral_bonus';
      case TransactionService.unknown:
        return '';
    }
  }

  String get label {
    switch (this) {
      case TransactionService.walletFunding:
        return 'Wallet Funding';
      case TransactionService.airtime:
        return 'Airtime';
      case TransactionService.data:
        return 'Data';
      case TransactionService.electricity:
        return 'Electricity';
      case TransactionService.cable:
        return 'Cable TV';
      case TransactionService.education:
        return 'Education';
      case TransactionService.referralBonus:
        return 'Referral Bonus';
      case TransactionService.unknown:
        return 'Transaction';
    }
  }

  /// Wallet funding and referral bonuses credit the wallet; everything else
  /// debits it. Used for +/- display and icon direction, matching the same
  /// convention as the wallet ledger.
  bool get isCredit => this == TransactionService.walletFunding || this == TransactionService.referralBonus;
}

/// Mirrors AppConstants.tx* string values from the backend enum exactly.
enum TransactionStatus {
  pending,
  processing,
  successful,
  failed,
  reversed;

  static TransactionStatus fromApi(String? value) {
    switch (value) {
      case 'processing':
        return TransactionStatus.processing;
      case 'successful':
        return TransactionStatus.successful;
      case 'failed':
        return TransactionStatus.failed;
      case 'reversed':
        return TransactionStatus.reversed;
      case 'pending':
      default:
        return TransactionStatus.pending;
    }
  }

  String get apiValue => name;

  String get label {
    switch (this) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.processing:
        return 'Processing';
      case TransactionStatus.successful:
        return 'Successful';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.reversed:
        return 'Reversed';
    }
  }
}

class Transaction extends Equatable {
  const Transaction({
    required this.reference,
    required this.service,
    required this.status,
    required this.amountKobo,
    required this.description,
    required this.createdAt,
    this.feeKobo = 0,
    this.recipient,
    this.narration,
    this.providerReference,
  });

  final String reference;
  final TransactionService service;
  final TransactionStatus status;
  final int amountKobo;
  final int feeKobo;
  final String description;
  final String? recipient;
  final String? narration;
  final String? providerReference;
  final DateTime createdAt;

  bool get isCredit => service.isCredit;
  int get totalKobo => amountKobo + feeKobo;

  @override
  List<Object?> get props => [
        reference,
        service,
        status,
        amountKobo,
        feeKobo,
        description,
        recipient,
        narration,
        providerReference,
        createdAt,
      ];
}
