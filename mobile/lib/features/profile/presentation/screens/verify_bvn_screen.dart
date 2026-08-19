import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failure.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/extensions/failure_extensions.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../theme/app_colors.dart';
import '../providers/verify_bvn_controller.dart';

class VerifyBvnScreen extends ConsumerStatefulWidget {
  const VerifyBvnScreen({super.key});

  @override
  ConsumerState<VerifyBvnScreen> createState() => _VerifyBvnScreenState();
}

class _VerifyBvnScreenState extends ConsumerState<VerifyBvnScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bvnController = TextEditingController();

  @override
  void dispose() {
    _bvnController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(verifyBvnControllerProvider.notifier).submit(bvn: _bvnController.text.trim());

    if (!mounted) return;
    final state = ref.read(verifyBvnControllerProvider);
    state.whenOrNull(
      data: (success) {
        if (success) {
          context.showSnack('BVN submitted for verification');
          context.pop();
        }
      },
      error: (error, _) {
        final failure = error is Failure ? error : null;
        context.showSnack(failure?.message ?? 'Could not verify your BVN. Please try again.', isError: true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(verifyBvnControllerProvider);
    final isSubmitting = state.isLoading;
    final failure = state.hasError ? state.error as Failure? : null;

    return ResponsiveScaffold(
      appBar: AppBar(title: const Text('Verify BVN')),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Verifying your BVN activates your dedicated virtual account for wallet funding.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: 'BVN',
                controller: _bvnController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.badge_outlined,
                hintText: '11-digit Bank Verification Number',
                errorText: failure.fieldError('bvn'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'BVN is required';
                  if (!RegExp(r'^\d{11}$').hasMatch(value)) return 'BVN must be exactly 11 digits';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Verify BVN',
                isLoading: isSubmitting,
                onPressed: isSubmitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
