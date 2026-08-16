import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/electricity_disco.dart';
import '../../../../core/errors/failure.dart';
import '../../../../routing/app_router.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/extensions/currency_extensions.dart';
import '../../../../shared/extensions/string_extensions.dart';
import '../../../../shared/widgets/bill_payment/amount_quick_chips.dart';
import '../../../../shared/widgets/bill_payment/pin_confirm_sheet.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/secondary_button.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/loaders/app_spinner.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../theme/app_colors.dart';
import '../providers/electricity_purchase_controller.dart';
import '../providers/meter_validation_controller.dart';
import '../widgets/disco_selector.dart';
import '../widgets/meter_type_toggle.dart';

const _quickAmountsKobo = [100000, 200000, 500000, 1000000, 2000000]; // ₦1,000 – ₦20,000

class ElectricityScreen extends ConsumerStatefulWidget {
  const ElectricityScreen({super.key});

  @override
  ConsumerState<ElectricityScreen> createState() => _ElectricityScreenState();
}

class _ElectricityScreenState extends ConsumerState<ElectricityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _meterNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();

  ElectricityDisco? _disco;
  MeterType _meterType = MeterType.prepaid;
  int? _selectedQuickAmount;
  String? _validatedMeterNumber;

  @override
  void dispose() {
    _meterNumberController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _resetValidation() {
    if (_validatedMeterNumber != null) {
      setState(() => _validatedMeterNumber = null);
      ref.read(meterValidationControllerProvider.notifier).reset();
    }
  }

  Future<void> _onValidate() async {
    if (_disco == null) {
      context.showSnack('Select a distribution company', isError: true);
      return;
    }
    final meterNumber = _meterNumberController.text.trim();
    if (meterNumber.length < 6) {
      context.showSnack('Enter a valid meter number', isError: true);
      return;
    }

    await ref.read(meterValidationControllerProvider.notifier).validate(
          disco: _disco!,
          meterType: _meterType,
          meterNumber: meterNumber,
        );

    if (!mounted) return;
    final state = ref.read(meterValidationControllerProvider);
    state.whenOrNull(
      data: (validation) {
        if (validation != null) setState(() => _validatedMeterNumber = meterNumber);
      },
      error: (error, _) {
        final failure = error is Failure ? error : null;
        context.showSnack(
          failure?.message ?? 'Could not validate this meter. Please check the details.',
          isError: true,
        );
      },
    );
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
    final validationState = ref.read(meterValidationControllerProvider);
    final validation = validationState.value;
    if (validation == null || _validatedMeterNumber != _meterNumberController.text.trim()) {
      context.showSnack('Validate the meter number first', isError: true);
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final amount = _amountKobo;
    if (amount == null || amount < 50000) {
      context.showSnack('Enter a valid amount (minimum ₦500)', isError: true);
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      context.showSnack('Enter a phone number for the receipt', isError: true);
      return;
    }

    final disco = _disco!;
    final meterNumber = _meterNumberController.text.trim();
    final phone = _phoneController.text.trim();

    await PinConfirmSheet.show(
      context,
      title: 'Confirm Electricity Purchase',
      summaryLines: [
        ('Disco', disco.label),
        ('Meter Type', _meterType.label),
        ('Meter No.', meterNumber),
        ('Customer', validation.customerName),
      ],
      amountKobo: amount,
      onConfirm: (pin) async {
        await ref.read(electricityPurchaseControllerProvider.notifier).purchase(
              disco: disco,
              meterType: _meterType,
              meterNumber: meterNumber,
              amountKobo: amount,
              phone: phone,
              transactionPin: pin,
            );

        if (!mounted) return;
        final state = ref.read(electricityPurchaseControllerProvider);
        state.whenOrNull(
          data: (transaction) {
            if (transaction == null) return;
            Navigator.of(context).pop();
            ref.read(electricityPurchaseControllerProvider.notifier).reset();
            context.showSnack('Electricity purchase successful');
            context.pushReplacement(AppRoutes.transactionDetail(transaction.reference));
          },
          error: (error, _) {
            final failure = error is Failure ? error : null;
            Navigator.of(context).pop();
            ref.read(electricityPurchaseControllerProvider.notifier).reset();
            context.showSnack(failure?.message ?? 'Purchase failed. Please try again.', isError: true);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final purchaseState = ref.watch(electricityPurchaseControllerProvider);
    final validationState = ref.watch(meterValidationControllerProvider);
    final isSubmitting = purchaseState.isLoading;
    final isValidating = validationState.isLoading;
    final validation = validationState.value;
    final isValidated = validation != null && _validatedMeterNumber == _meterNumberController.text.trim();

    return ResponsiveScaffold(
      appBar: AppBar(title: const Text('Buy Electricity')),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DiscoSelector(
                selected: _disco,
                onChanged: (disco) {
                  setState(() => _disco = disco);
                  _resetValidation();
                },
              ),
              const SizedBox(height: 16),
              const Text('Meter Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              MeterTypeToggle(
                selected: _meterType,
                onChanged: (type) {
                  setState(() => _meterType = type);
                  _resetValidation();
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Meter Number',
                controller: _meterNumberController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.numbers_rounded,
                onChanged: (_) => _resetValidation(),
                validator: (value) {
                  if (value == null || value.trim().length < 6) return 'Enter a valid meter number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Phone Number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_iphone_rounded,
                hintText: '080XXXXXXXX',
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Phone number is required';
                  if (!value.isValidNigerianPhone) return 'Enter a valid Nigerian phone number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              if (isValidated) ...[
                AppCard(
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.success),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              validation.customerName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                            if (validation.customerAddress != null)
                              Text(
                                validation.customerAddress!,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (isValidating) ...[
                const AppSpinner(),
              ] else ...[
                SecondaryButton(label: 'Validate Meter', onPressed: _onValidate),
              ],
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
                prefixIcon: Icons.payments_outlined,
                onChanged: (_) => setState(() => _selectedQuickAmount = null),
                validator: (value) {
                  final naira = double.tryParse((value ?? '').trim());
                  if (naira == null || naira < 500) return 'Minimum amount is ₦500';
                  return null;
                },
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'Continue',
                isLoading: isSubmitting,
                onPressed: isSubmitting ? null : _onContinue,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
