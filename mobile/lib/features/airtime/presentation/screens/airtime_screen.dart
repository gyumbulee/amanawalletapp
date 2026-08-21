import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/network_provider.dart';
import '../../../../core/errors/failure.dart';
import '../../../../routing/app_router.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/extensions/currency_extensions.dart';
import '../../../../shared/extensions/string_extensions.dart';
import '../../../../shared/widgets/bill_payment/amount_quick_chips.dart';
import '../../../../shared/widgets/bill_payment/network_selector.dart';
import '../../../../shared/widgets/bill_payment/pin_confirm_sheet.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../theme/app_colors.dart';
import '../providers/airtime_purchase_controller.dart';

const _quickAmountsKobo = [10000, 20000, 50000, 100000, 200000, 500000]; // ₦100 – ₦5,000

class AirtimeScreen extends ConsumerStatefulWidget {
  const AirtimeScreen({super.key});

  @override
  ConsumerState<AirtimeScreen> createState() => _AirtimeScreenState();
}

class _AirtimeScreenState extends ConsumerState<AirtimeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();

  NetworkProvider? _network;
  int? _selectedQuickAmount;

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onPhoneChanged(String value) {
    final detected = NetworkProvider.fromPhonePrefix(value);
    if (detected != null && detected != _network) {
      setState(() => _network = detected);
    }
  }

  int? get _amountKobo {
    final naira = double.tryParse(_amountController.text.trim());
    if (naira == null) return null;
    return naira.toKobo();
  }

  void _onQuickAmountSelected(int kobo) {
    setState(() {
      _selectedQuickAmount = kobo;
      _amountController.text = (kobo / 100).toStringAsFixed(0);
    });
  }

  Future<void> _onContinue() async {
    if (_network == null) {
      context.showSnack('Select a network', isError: true);
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final amount = _amountKobo;
    if (amount == null || amount < 5000) {
      context.showSnack('Enter a valid amount (minimum ₦50)', isError: true);
      return;
    }

    final phone = _phoneController.text.trim();

    await PinConfirmSheet.show(
      context,
      title: 'Confirm Airtime Purchase',
      summaryLines: [('Network', _network!.label), ('Phone', phone)],
      amountKobo: amount,
      onConfirm: (pin) async {
        await ref.read(airtimePurchaseControllerProvider.notifier).purchase(
              network: _network!,
              phone: phone,
              amountKobo: amount,
              transactionPin: pin,
            );

        if (!mounted) return;
        final state = ref.read(airtimePurchaseControllerProvider);
        state.whenOrNull(
          data: (transaction) {
            if (transaction == null) return;
            Navigator.of(context).pop(); // close the PIN sheet
            ref.read(airtimePurchaseControllerProvider.notifier).reset();
            context.showSnack('Airtime purchase successful');
            context.pushReplacement(AppRoutes.transactionDetail(transaction.id));
          },
          error: (error, _) {
            final failure = error is Failure ? error : null;
            Navigator.of(context).pop();
            ref.read(airtimePurchaseControllerProvider.notifier).reset();
            context.showSnack(
              failure?.message ?? 'Purchase failed. Please try again.',
              isError: true,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final purchaseState = ref.watch(airtimePurchaseControllerProvider);
    final isSubmitting = purchaseState.isLoading;

    return ResponsiveScaffold(
      appBar: AppBar(title: const Text('Buy Airtime')),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Select Network', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 12),
              NetworkSelector(
                selected: _network,
                onSelected: (network) => setState(() => _network = network),
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: 'Phone Number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.phone_iphone_rounded,
                hintText: '080XXXXXXXX',
                onChanged: _onPhoneChanged,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Phone number is required';
                  if (!value.isValidNigerianPhone) return 'Enter a valid Nigerian phone number';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text('Amount', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 12),
              AmountQuickChips(
                amountsKobo: _quickAmountsKobo,
                selectedKobo: _selectedQuickAmount,
                onSelected: _onQuickAmountSelected,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Amount (₦)',
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
                prefixIcon: Icons.payments_outlined,
                onChanged: (_) => setState(() => _selectedQuickAmount = null),
                validator: (value) {
                  final naira = double.tryParse((value ?? '').trim());
                  if (naira == null || naira < 50) return 'Minimum amount is ₦50';
                  return null;
                },
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'Continue',
                isLoading: isSubmitting,
                onPressed: isSubmitting ? null : _onContinue,
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Your transaction PIN will be required on the next step.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
