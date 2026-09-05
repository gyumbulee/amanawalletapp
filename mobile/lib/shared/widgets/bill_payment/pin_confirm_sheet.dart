import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/failure.dart';
import '../../../shared/extensions/currency_extensions.dart';
import '../../../theme/app_colors.dart';
import '../inputs/pin_input.dart';
import '../loaders/app_spinner.dart';

/// True while the given purchase-controller AsyncValue is mid-request.
bool isPurchaseSubmitting(AsyncValue value) => value.isLoading;

/// User-facing message for the given purchase-controller AsyncValue's
/// error, or null if it isn't currently in an error state.
String? purchaseErrorMessage(AsyncValue value) {
  final error = value.error;
  if (error == null) return null;
  return error is Failure ? error.message : 'Purchase failed. Please try again.';
}

/// Final confirmation step for every bill-payment flow (airtime, data,
/// electricity, cable, education): shows a summary of what's being paid
/// for, collects the 4-digit transaction PIN, and calls [onConfirm] once
/// complete.
///
/// [isSubmitting] and [errorText] are driven live from the calling
/// screen's purchase controller via [show]'s [controller] parameter — the
/// sheet is wrapped in a [Consumer] internally, so it reacts the instant
/// the controller's AsyncValue changes (e.g. the moment [onConfirm]'s
/// purchase call starts), rather than being frozen at whatever those
/// values were when the sheet first opened.
class PinConfirmSheet extends StatefulWidget {
  const PinConfirmSheet({
    super.key,
    required this.title,
    required this.summaryLines,
    required this.amountKobo,
    required this.onConfirm,
    this.isSubmitting = false,
    this.errorText,
  });

  final String title;

  /// Label/value pairs shown above the PIN pad, e.g.
  /// [('Network', 'MTN'), ('Phone', '0803...')].
  final List<(String, String)> summaryLines;
  final int amountKobo;
  final ValueChanged<String> onConfirm;
  final bool isSubmitting;
  final String? errorText;

  /// [controller] is the calling screen's own purchase controller provider
  /// (e.g. `airtimePurchaseControllerProvider`) — pass it directly, not a
  /// snapshotted `.isLoading`/error value, so the sheet can watch it live.
  static Future<void> show<T>(
    BuildContext context, {
    required String title,
    required List<(String, String)> summaryLines,
    required int amountKobo,
    required ValueChanged<String> onConfirm,
    required ProviderListenable<AsyncValue<T>> controller,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(controller);
          return PopScope(
            canPop: !state.isLoading,
            child: PinConfirmSheet(
              title: title,
              summaryLines: summaryLines,
              amountKobo: amountKobo,
              onConfirm: onConfirm,
              isSubmitting: isPurchaseSubmitting(state),
              errorText: purchaseErrorMessage(state),
            ),
          );
        },
      ),
    );
  }

  @override
  State<PinConfirmSheet> createState() => _PinConfirmSheetState();
}

class _PinConfirmSheetState extends State<PinConfirmSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (final line in widget.summaryLines) ...[
                  _summaryRow(line.$1, line.$2),
                  const SizedBox(height: 6),
                ],
                _summaryRow('Amount', widget.amountKobo.toNairaDisplay(), emphasize: true),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Enter your 4-digit transaction PIN',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          if (widget.isSubmitting)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  AppSpinner(),
                  SizedBox(height: 12),
                  Text(
                    'Processing your payment…',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            )
          else
            PinInput(
              onCompleted: widget.onConfirm,
              autoFocus: true,
            ),
          if (widget.errorText != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.errorText!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool emphasize = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            fontSize: emphasize ? 16 : 13,
            fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
