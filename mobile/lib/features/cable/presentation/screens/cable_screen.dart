import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/cable_provider.dart';
import '../../../../core/errors/failure.dart';
import '../../../../routing/app_router.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/extensions/string_extensions.dart';
import '../../../../shared/widgets/bill_payment/pin_confirm_sheet.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/secondary_button.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/empty_states/empty_state.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/loaders/app_spinner.dart';
import '../../../../shared/widgets/loaders/skeleton_loader.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/entities/cable_package.dart';
import '../providers/cable_packages_provider.dart';
import '../providers/cable_purchase_controller.dart';
import '../providers/smartcard_validation_controller.dart';
import '../widgets/cable_package_tile.dart';
import '../widgets/cable_provider_selector.dart';

class CableScreen extends ConsumerStatefulWidget {
  const CableScreen({super.key});

  @override
  ConsumerState<CableScreen> createState() => _CableScreenState();
}

class _CableScreenState extends ConsumerState<CableScreen> {
  final _formKey = GlobalKey<FormState>();
  final _smartCardController = TextEditingController();
  final _phoneController = TextEditingController();

  CableProvider _provider = CableProvider.dstv;
  CablePackage? _selectedPackage;
  String? _validatedSmartCard;

  @override
  void dispose() {
    _smartCardController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _resetValidation() {
    if (_validatedSmartCard != null) {
      setState(() => _validatedSmartCard = null);
      ref.read(smartcardValidationControllerProvider.notifier).reset();
    }
  }

  void _onProviderSelected(CableProvider provider) {
    if (provider == _provider) return;
    setState(() {
      _provider = provider;
      _selectedPackage = null;
    });
    _resetValidation();
  }

  Future<void> _onValidate() async {
    final smartCard = _smartCardController.text.trim();
    if (smartCard.length < 5) {
      context.showSnack('Enter a valid smart card number', isError: true);
      return;
    }

    await ref.read(smartcardValidationControllerProvider.notifier).validate(
          provider: _provider,
          smartCardNumber: smartCard,
        );

    if (!mounted) return;
    final state = ref.read(smartcardValidationControllerProvider);
    state.whenOrNull(
      data: (validation) {
        if (validation != null) setState(() => _validatedSmartCard = smartCard);
      },
      error: (error, _) {
        final failure = error is Failure ? error : null;
        context.showSnack(
          failure?.message ?? 'Could not validate this smart card. Please check the number.',
          isError: true,
        );
      },
    );
  }

  Future<void> _onContinue() async {
    final validationState = ref.read(smartcardValidationControllerProvider);
    final validation = validationState.value;
    if (validation == null || _validatedSmartCard != _smartCardController.text.trim()) {
      context.showSnack('Validate the smart card number first', isError: true);
      return;
    }
    if (_selectedPackage == null) {
      context.showSnack('Select a package', isError: true);
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final package = _selectedPackage!;
    final smartCard = _smartCardController.text.trim();
    final phone = _phoneController.text.trim();

    await PinConfirmSheet.show(
      context,
      title: 'Confirm Cable Subscription',
      summaryLines: [
        ('Provider', _provider.label),
        ('Smart Card', smartCard),
        ('Customer', validation.customerName),
        ('Package', package.name),
      ],
      amountKobo: package.priceKobo,
      onConfirm: (pin) async {
        await ref.read(cablePurchaseControllerProvider.notifier).purchase(
              provider: _provider,
              smartCardNumber: smartCard,
              variationCode: package.id,
              phone: phone,
              transactionPin: pin,
            );

        if (!mounted) return;
        final state = ref.read(cablePurchaseControllerProvider);
        state.whenOrNull(
          data: (transaction) {
            if (transaction == null) return;
            Navigator.of(context).pop();
            ref.read(cablePurchaseControllerProvider.notifier).reset();
            context.showSnack('Cable subscription successful');
            context.pushReplacement(AppRoutes.transactionDetail(transaction.id));
          },
          error: (error, _) {
            final failure = error is Failure ? error : null;
            Navigator.of(context).pop();
            ref.read(cablePurchaseControllerProvider.notifier).reset();
            context.showSnack(failure?.message ?? 'Purchase failed. Please try again.', isError: true);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final purchaseState = ref.watch(cablePurchaseControllerProvider);
    final validationState = ref.watch(smartcardValidationControllerProvider);
    final isSubmitting = purchaseState.isLoading;
    final isValidating = validationState.isLoading;
    final validation = validationState.value;
    final isValidated = validation != null && _validatedSmartCard == _smartCardController.text.trim();
    final packagesAsync = ref.watch(cablePackagesProvider(_provider));

    return ResponsiveScaffold(
      appBar: AppBar(title: const Text('Cable TV')),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Select Provider', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 12),
              CableProviderSelector(selected: _provider, onSelected: _onProviderSelected),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Smart Card / IUC Number',
                controller: _smartCardController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.credit_card_rounded,
                onChanged: (_) => _resetValidation(),
                validator: (value) {
                  if (value == null || value.trim().length < 5) return 'Enter a valid smart card number';
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
                        child: Text(
                          validation.customerName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (isValidating) ...[
                const AppSpinner(),
              ] else ...[
                SecondaryButton(label: 'Validate Smart Card', onPressed: _onValidate),
              ],
              const SizedBox(height: 24),
              const Text('Select Package', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 12),
              packagesAsync.when(
                loading: () => Column(
                  children: List.generate(
                    4,
                    (_) => const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: SkeletonLoader(height: 56, borderRadius: BorderRadius.all(Radius.circular(16))),
                    ),
                  ),
                ),
                error: (error, _) => EmptyState(
                  icon: Icons.error_outline_rounded,
                  message: 'Could not load ${_provider.label} packages.',
                  actionLabel: 'Retry',
                  onAction: () => ref.invalidate(cablePackagesProvider(_provider)),
                ),
                data: (packages) {
                  if (packages.isEmpty) {
                    return const EmptyState(
                      icon: Icons.tv_off_rounded,
                      message: 'No packages available for this provider right now.',
                    );
                  }
                  return Column(
                    children: [
                      for (final package in packages)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: CablePackageTile(
                            package: package,
                            isSelected: _selectedPackage?.id == package.id,
                            onTap: () => setState(() => _selectedPackage = package),
                          ),
                        ),
                    ],
                  );
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
