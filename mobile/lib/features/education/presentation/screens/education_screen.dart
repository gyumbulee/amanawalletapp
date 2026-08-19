import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/education_exam_type.dart';
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
import '../../domain/entities/education_plan.dart';
import '../providers/education_plans_provider.dart';
import '../providers/education_purchase_controller.dart';
import '../providers/profile_validation_controller.dart';
import '../widgets/education_plan_tile.dart';
import '../widgets/exam_type_selector.dart';

/// For JAMB, the profile-ID validate call is tied to the specific PIN
/// variant (e.g. UTME with/without mock), so the flow here is: exam type
/// -> plan -> (JAMB only) profile ID + validate -> phone -> continue.
/// WAEC/NECO/NABTEB skip the profile step entirely.
class EducationScreen extends ConsumerStatefulWidget {
  const EducationScreen({super.key});

  @override
  ConsumerState<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends ConsumerState<EducationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profileIdController = TextEditingController();
  final _phoneController = TextEditingController();

  EducationExamType _examType = EducationExamType.waec;
  EducationPlan? _selectedPlan;
  String? _validatedProfileId;
  String? _validatedPlanId;

  @override
  void dispose() {
    _profileIdController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool get _requiresValidation => _examType.requiresProfileValidation;

  void _resetValidation() {
    if (_validatedProfileId != null || _validatedPlanId != null) {
      setState(() {
        _validatedProfileId = null;
        _validatedPlanId = null;
      });
      ref.read(profileValidationControllerProvider.notifier).reset();
    }
  }

  void _onExamTypeSelected(EducationExamType examType) {
    if (examType == _examType) return;
    setState(() {
      _examType = examType;
      _selectedPlan = null;
    });
    _resetValidation();
  }

  void _onPlanSelected(EducationPlan plan) {
    if (_selectedPlan?.id == plan.id) return;
    setState(() => _selectedPlan = plan);
    // A plan change invalidates any prior JAMB profile validation, since
    // it was checked against the previously selected variation code.
    _resetValidation();
  }

  Future<void> _onValidate() async {
    if (_selectedPlan == null) {
      context.showSnack('Select a plan first', isError: true);
      return;
    }
    final profileId = _profileIdController.text.trim();
    if (profileId.length < 4) {
      context.showSnack('Enter a valid JAMB profile ID', isError: true);
      return;
    }

    await ref.read(profileValidationControllerProvider.notifier).validate(
          examType: _examType,
          variationCode: _selectedPlan!.id,
          profileId: profileId,
        );

    if (!mounted) return;
    final state = ref.read(profileValidationControllerProvider);
    state.whenOrNull(
      data: (validation) {
        if (validation != null) {
          setState(() {
            _validatedProfileId = profileId;
            _validatedPlanId = _selectedPlan!.id;
          });
        }
      },
      error: (error, _) {
        final failure = error is Failure ? error : null;
        context.showSnack(
          failure?.message ?? 'Could not validate this profile ID. Please check and try again.',
          isError: true,
        );
      },
    );
  }

  Future<void> _onContinue() async {
    if (_selectedPlan == null) {
      context.showSnack('Select a plan', isError: true);
      return;
    }
    if (_requiresValidation) {
      final validationState = ref.read(profileValidationControllerProvider);
      final validation = validationState.value;
      final isValidated = validation != null &&
          _validatedProfileId == _profileIdController.text.trim() &&
          _validatedPlanId == _selectedPlan!.id;
      if (!isValidated) {
        context.showSnack('Validate the profile ID first', isError: true);
        return;
      }
    }
    if (!_formKey.currentState!.validate()) return;

    final plan = _selectedPlan!;
    final phone = _phoneController.text.trim();
    final profileId = _requiresValidation ? _profileIdController.text.trim() : null;
    final validation = ref.read(profileValidationControllerProvider).value;

    await PinConfirmSheet.show(
      context,
      title: 'Confirm Education PIN Purchase',
      summaryLines: [
        ('Exam', _examType.label),
        if (profileId != null) ('Profile ID', profileId),
        if (validation != null) ('Candidate', validation.candidateName),
        ('Plan', plan.name),
      ],
      amountKobo: plan.priceKobo,
      onConfirm: (pin) async {
        await ref.read(educationPurchaseControllerProvider.notifier).purchase(
              examType: _examType,
              variationCode: plan.id,
              phone: phone,
              transactionPin: pin,
              profileId: profileId,
            );

        if (!mounted) return;
        final state = ref.read(educationPurchaseControllerProvider);
        state.whenOrNull(
          data: (transaction) {
            if (transaction == null) return;
            Navigator.of(context).pop();
            ref.read(educationPurchaseControllerProvider.notifier).reset();
            context.showSnack('Education PIN purchase successful');
            context.pushReplacement(AppRoutes.transactionDetail(transaction.reference));
          },
          error: (error, _) {
            final failure = error is Failure ? error : null;
            Navigator.of(context).pop();
            ref.read(educationPurchaseControllerProvider.notifier).reset();
            context.showSnack(failure?.message ?? 'Purchase failed. Please try again.', isError: true);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final purchaseState = ref.watch(educationPurchaseControllerProvider);
    final validationState = ref.watch(profileValidationControllerProvider);
    final isSubmitting = purchaseState.isLoading;
    final isValidating = validationState.isLoading;
    final validation = validationState.value;
    final isValidated = validation != null &&
        _validatedProfileId == _profileIdController.text.trim() &&
        _validatedPlanId == _selectedPlan?.id;
    final plansAsync = ref.watch(educationPlansProvider(_examType));

    return ResponsiveScaffold(
      appBar: AppBar(title: const Text('Education PIN')),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Select Exam', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 12),
              ExamTypeSelector(selected: _examType, onSelected: _onExamTypeSelected),
              const SizedBox(height: 24),
              const Text('Select Plan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 12),
              plansAsync.when(
                loading: () => Column(
                  children: List.generate(
                    3,
                    (_) => const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: SkeletonLoader(height: 56, borderRadius: BorderRadius.all(Radius.circular(16))),
                    ),
                  ),
                ),
                error: (error, _) => EmptyState(
                  icon: Icons.error_outline_rounded,
                  message: 'Could not load ${_examType.label} plans.',
                  actionLabel: 'Retry',
                  onAction: () => ref.invalidate(educationPlansProvider(_examType)),
                ),
                data: (plans) {
                  if (plans.isEmpty) {
                    return const EmptyState(
                      icon: Icons.school_outlined,
                      message: 'No plans available for this exam right now.',
                    );
                  }
                  return Column(
                    children: [
                      for (final plan in plans)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: EducationPlanTile(
                            plan: plan,
                            isSelected: _selectedPlan?.id == plan.id,
                            onTap: () => _onPlanSelected(plan),
                          ),
                        ),
                    ],
                  );
                },
              ),
              if (_requiresValidation) ...[
                const SizedBox(height: 24),
                AppTextField(
                  label: 'JAMB Profile ID',
                  controller: _profileIdController,
                  prefixIcon: Icons.badge_outlined,
                  onChanged: (_) => _resetValidation(),
                  validator: (value) {
                    if (value == null || value.trim().length < 4) return 'Enter a valid profile ID';
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
                            validation.candidateName,
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
                  SecondaryButton(
                    label: _selectedPlan == null ? 'Select a plan first' : 'Validate Profile ID',
                    onPressed: _selectedPlan == null ? null : _onValidate,
                  ),
                ],
              ],
              const SizedBox(height: 24),
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
