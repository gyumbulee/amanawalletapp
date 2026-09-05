import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../routing/app_router.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/extensions/currency_extensions.dart';
import '../../../../shared/widgets/buttons/secondary_button.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/empty_states/empty_state.dart';
import '../../../../shared/widgets/loaders/app_spinner.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transaction_detail_provider.dart';
import '../widgets/status_badge.dart';
import '../widgets/transaction_service_icon.dart';

class TransactionDetailScreen extends ConsumerStatefulWidget {
  const TransactionDetailScreen({super.key, required this.reference});

  final String reference;

  @override
  ConsumerState<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends ConsumerState<TransactionDetailScreen> {
  static const _pollInterval = Duration(seconds: 4);

  Timer? _pollTimer;

  bool _isSettled(TransactionStatus status) => switch (status) {
        TransactionStatus.successful || TransactionStatus.failed || TransactionStatus.reversed => true,
        TransactionStatus.pending || TransactionStatus.processing => false,
      };

  /// Keeps re-fetching every few seconds while the transaction is still
  /// Pending/Processing, so a user who just entered their PIN sees the
  /// status resolve on its own instead of wondering whether anything is
  /// still happening. Stops itself the moment the status settles.
  void _syncPolling(TransactionStatus status) {
    if (_isSettled(status)) {
      _pollTimer?.cancel();
      _pollTimer = null;
      return;
    }

    _pollTimer ??= Timer.periodic(_pollInterval, (_) {
      if (!mounted) return;
      ref.invalidate(transactionDetailProvider(widget.reference));
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(transactionDetailProvider(widget.reference));
    detailAsync.whenData((transaction) => _syncPolling(transaction.status));

    return ResponsiveScaffold(
      appBar: AppBar(title: const Text('Transaction Details')),
      body: detailAsync.when(
        loading: () => const AppSpinner(),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          message: 'Could not load this transaction.',
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(transactionDetailProvider(widget.reference)),
        ),
        data: (transaction) {
          final isCredit = transaction.isCredit;
          final color = isCredit ? AppColors.success : AppColors.primary;
          final sign = isCredit ? '+' : '-';
          // Pulled explicitly (rather than left unset) so this always
          // matches the active theme's text color instead of depending on
          // ambient inheritance, which wasn't resolving reliably here.
          final valueColor = Theme.of(context).textTheme.bodyMedium?.color;
          final isSettled = _isSettled(transaction.status);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Column(
                    children: [
                      Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Icon(transactionServiceIcon(transaction.service), color: color, size: 30),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$sign${transaction.amountKobo.toNairaDisplay()}',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: valueColor),
                      ),
                      const SizedBox(height: 8),
                      StatusBadge(status: transaction.status),
                    ],
                  ),
                ),
                if (!isSettled) ...[
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.warning),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "We're still processing this with the provider. This page will update automatically — no need to retry or leave.",
                              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                AppCard(
                  child: Column(
                    children: [
                      _row('Service', transaction.service.label, valueColor),
                      const Divider(height: 24),
                      _row('Description', transaction.description, valueColor),
                      if (transaction.recipient != null) ...[
                        const Divider(height: 24),
                        _row('Recipient', transaction.recipient!, valueColor),
                      ],
                      const Divider(height: 24),
                      _row('Amount', transaction.amountKobo.toNairaDisplay(), valueColor),
                      if (transaction.feeKobo > 0) ...[
                        const Divider(height: 24),
                        _row('Fee', transaction.feeKobo.toNairaDisplay(), valueColor),
                        const Divider(height: 24),
                        _row('Total', transaction.totalKobo.toNairaDisplay(), valueColor),
                      ],
                      const Divider(height: 24),
                      _row('Date', DateFormat('MMM d, y • h:mm a').format(transaction.createdAt), valueColor),
                      if (transaction.narration != null) ...[
                        const Divider(height: 24),
                        _row('Narration', transaction.narration!, valueColor),
                      ],
                      const Divider(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(
                            flex: 2,
                            child: Text('Reference', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ),
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    transaction.reference,
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: valueColor),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: transaction.reference));
                                    context.showSnack('Reference copied');
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Icon(Icons.copy_rounded, size: 16, color: AppColors.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SecondaryButton(
                  label: 'Need help with this transaction?',
                  onPressed: () {
                    context.push(AppRoutes.newSupportTicket, extra: transaction.reference);
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _row(String label, String value, Color? valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: valueColor),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
