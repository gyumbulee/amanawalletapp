import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/failure.dart';
import '../../../features/transactions/domain/entities/transaction.dart';
import '../../../routing/app_router.dart';
import '../../extensions/context_extensions.dart';

/// Call this from every bill-payment screen's `onConfirm` success branch.
///
/// Purchases are queued and processed against an external provider
/// (VTpass/BigiSub), so the transaction handed back immediately after PIN
/// entry frequently has status Pending or Processing, not Successful. This
/// gives the user a message that actually matches what happened, closes
/// the PIN sheet, and always routes to the transaction detail screen —
/// which polls while the transaction is still settling, so the user isn't
/// left staring at a stale "Processing" badge wondering if anything is
/// still happening.
void handleBillPaymentSuccess(
  BuildContext context, {
  required Transaction transaction,
  required String serviceLabel,
}) {
  switch (transaction.status) {
    case TransactionStatus.successful:
      context.showSnack('$serviceLabel successful');
    case TransactionStatus.failed:
      context.showSnack('$serviceLabel failed', isError: true);
    case TransactionStatus.reversed:
      context.showSnack('$serviceLabel was reversed — your wallet has been refunded', isError: true);
    case TransactionStatus.pending:
    case TransactionStatus.processing:
      context.showSnack("$serviceLabel is processing — we'll update you shortly");
  }

  Navigator.of(context).pop(); // close the PIN sheet
  context.pushReplacement(AppRoutes.transactionDetail(transaction.id));
}

/// Call this from every bill-payment screen's `onConfirm` error branch
/// (e.g. wrong PIN, insufficient balance, validation failure before the
/// transaction was even created).
void handleBillPaymentError(BuildContext context, Object? error) {
  final failure = error is Failure ? error : null;
  Navigator.of(context).pop(); // close the PIN sheet
  context.showSnack(
    failure?.message ?? 'Purchase failed. Please try again.',
    isError: true,
  );
}
