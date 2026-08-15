import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/network_provider.dart';
import '../../../../core/errors/failure.dart';
import '../../../../routing/app_router.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/extensions/string_extensions.dart';
import '../../../../shared/widgets/bill_payment/network_selector.dart';
import '../../../../shared/widgets/bill_payment/pin_confirm_sheet.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/empty_states/empty_state.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/loaders/skeleton_loader.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../domain/entities/data_plan.dart';
import '../providers/data_plans_provider.dart';
import '../providers/data_purchase_controller.dart';
import '../widgets/data_plan_tile.dart';

class DataScreen extends ConsumerStatefulWidget {
  const DataScreen({super.key});

  @override
  ConsumerState<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends ConsumerState<DataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  NetworkProvider _network = NetworkProvider.mtn;
  DataPlan? _selectedPlan;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onPhoneChanged(String value) {
    final detected = NetworkProvider.fromPhonePrefix(value);
    if (detected != null && detected != _network) {
      setState(() {
        _network = detected;
        _selectedPlan = null; // plan list changes with network
      });
    }
  }

  void _onNetworkSelected(NetworkProvider network) {
    if (network == _network) return;
    setState(() {
      _network = network;
      _selectedPlan = null;
    });
  }

  Future<void> _onContinue() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPlan == null) {
      context.showSnack('Select a data plan', isError: true);
      return;
    }

    final plan = _selectedPlan!;
    final phone = _phoneController.text.trim();

    await PinConfirmSheet.show(
      context,
      title: 'Confirm Data Purchase',
      summaryLines: [
        ('Network', _network.label),
        ('Phone', phone),
        ('Plan', '${plan.sizeLabel} • ${plan.validityLabel}'),
      ],
      amountKobo: plan.priceKobo,
      onConfirm: (pin) async {
        await ref.read(dataPurchaseControllerProvider.notifier).purchase(
              network: _network,
              variationCode: plan.id,
              phone: phone,
              transactionPin: pin,
            );

        if (!mounted) return;
        final state = ref.read(dataPurchaseControllerProvider);
        state.whenOrNull(
          data: (transaction) {
            if (transaction == null) return;
            Navigator.of(context).pop();
            ref.read(dataPurchaseControllerProvider.notifier).reset();
            context.showSnack('Data purchase successful');
            context.pushReplacement(AppRoutes.transactionDetail(transaction.reference));
          },
          error: (error, _) {
            final failure = error is Failure ? error : null;
            Navigator.of(context).pop();
            ref.read(dataPurchaseControllerProvider.notifier).reset();
            context.showSnack(failure?.message ?? 'Purchase failed. Please try again.', isError: true);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final purchaseState = ref.watch(dataPurchaseControllerProvider);
    final isSubmitting = purchaseState.isLoading;
    final plansAsync = ref.watch(dataPlansProvider(_network));

    return ResponsiveScaffold(
      appBar: AppBar(title: const Text('Buy Data')),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Select Network', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 12),
              NetworkSelector(selected: _network, onSelected: _onNetworkSelected),
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
              const Text('Select Plan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 12),
              plansAsync.when(
                loading: () => Column(
                  children: List.generate(
                    4,
                    (_) => const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: SkeletonLoader(height: 64, borderRadius: BorderRadius.all(Radius.circular(16))),
                    ),
                  ),
                ),
                error: (error, _) => EmptyState(
                  icon: Icons.error_outline_rounded,
                  message: 'Could not load ${_network.label} data plans.',
                  actionLabel: 'Retry',
                  onAction: () => ref.invalidate(dataPlansProvider(_network)),
                ),
                data: (plans) {
                  if (plans.isEmpty) {
                    return const EmptyState(
                      icon: Icons.wifi_off_rounded,
                      message: 'No data plans available for this network right now.',
                    );
                  }
                  return Column(
                    children: [
                      for (final plan in plans)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: DataPlanTile(
                            plan: plan,
                            isSelected: _selectedPlan?.id == plan.id,
                            onTap: () => setState(() => _selectedPlan = plan),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
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
