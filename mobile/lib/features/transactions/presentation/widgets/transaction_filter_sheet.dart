import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/secondary_button.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_filter.dart';
import '../providers/transaction_filter_provider.dart';

/// Opened from the transactions screen's filter icon. Applies to
/// [transactionFilterProvider] on confirm, which the list controller
/// watches directly — no separate "apply" plumbing needed.
class TransactionFilterSheet extends ConsumerStatefulWidget {
  const TransactionFilterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const TransactionFilterSheet(),
    );
  }

  @override
  ConsumerState<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends ConsumerState<TransactionFilterSheet> {
  TransactionService? _service;
  TransactionStatus? _status;

  @override
  void initState() {
    super.initState();
    final current = ref.read(transactionFilterProvider);
    _service = current.service;
    _status = current.status;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filter Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          const Text('Service', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(label: 'All', selected: _service == null, onTap: () => setState(() => _service = null)),
              for (final service in TransactionService.values.where((s) => s != TransactionService.unknown))
                _chip(
                  label: service.label,
                  selected: _service == service,
                  onTap: () => setState(() => _service = service),
                ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Status', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(label: 'All', selected: _status == null, onTap: () => setState(() => _status = null)),
              for (final status in TransactionStatus.values)
                _chip(
                  label: status.label,
                  selected: _status == status,
                  onTap: () => setState(() => _status = status),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Clear',
                  onPressed: () {
                    ref.read(transactionFilterProvider.notifier).state = const TransactionFilter();
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  label: 'Apply',
                  onPressed: () {
                    final current = ref.read(transactionFilterProvider);
                    ref.read(transactionFilterProvider.notifier).state = current.copyWith(
                      service: _service,
                      clearService: _service == null,
                      status: _status,
                      clearStatus: _status == null,
                    );
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip({required String label, required bool selected, required VoidCallback onTap}) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.accent.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: selected ? AppColors.accent : AppColors.textPrimary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        fontSize: 13,
      ),
      backgroundColor: AppColors.background,
      side: BorderSide(color: selected ? AppColors.accent : AppColors.border),
    );
  }
}
