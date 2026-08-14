import 'package:flutter/material.dart';
import '../../domain/entities/transaction.dart';

IconData transactionServiceIcon(TransactionService service) {
  switch (service) {
    case TransactionService.walletFunding:
      return Icons.arrow_downward_rounded;
    case TransactionService.airtime:
      return Icons.phone_iphone_rounded;
    case TransactionService.data:
      return Icons.wifi_rounded;
    case TransactionService.electricity:
      return Icons.bolt_rounded;
    case TransactionService.cable:
      return Icons.tv_rounded;
    case TransactionService.education:
      return Icons.school_outlined;
    case TransactionService.referralBonus:
      return Icons.card_giftcard_outlined;
    case TransactionService.unknown:
      return Icons.receipt_long_outlined;
  }
}
