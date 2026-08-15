import 'package:flutter/material.dart';
import '../../../shared/extensions/currency_extensions.dart';
import '../../../theme/app_colors.dart';
import '../inputs/pin_input.dart';
import '../loaders/app_spinner.dart';

/// Final confirmation step for every bill-payment flow (airtime, data,
/// electricity, cable, education): shows a summary of what's being paid
/// for, collects the 4-digit transaction PIN, and calls [onConfirm] once
/// complete. The caller owns the actual purchase API call and loading
/// state — this sheet just collects the PIN and reflects [isSubmitting].
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

  static Future<void> show(
    BuildContext context, {
    required String title,
    required List<(String, String)> summaryLines,
    required int amountKobo,
    required ValueChanged<String> onConfirm,
    bool isSubmitting = false,
    String? errorText,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: !isSubmitting,
      enableDrag: !isSubmitting,
      builder: (context) => PinConfirmSheet(
        title: title,
        summaryLines: summaryLines,
        amountKobo: amountKobo,
        onConfirm: onConfirm,
        isSubmitting: isSubmitting,
        errorText: errorText,
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
              child: AppSpinner(),
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
