import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failure.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/extensions/failure_extensions.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../providers/change_password_controller.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(changePasswordControllerProvider.notifier).submit(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
          newPasswordConfirmation: _confirmPasswordController.text,
        );

    if (!mounted) return;
    final state = ref.read(changePasswordControllerProvider);
    state.whenOrNull(
      data: (success) {
        if (success) {
          context.showSnack('Password changed successfully');
          context.pop();
        }
      },
      error: (error, _) {
        final failure = error is Failure ? error : null;
        context.showSnack(failure?.message ?? 'Could not change your password. Please try again.', isError: true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(changePasswordControllerProvider);
    final isSubmitting = state.isLoading;
    final failure = state.hasError ? state.error as Failure? : null;

    return ResponsiveScaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'Current Password',
                controller: _currentPasswordController,
                obscureText: _obscureCurrent,
                prefixIcon: Icons.lock_outline_rounded,
                errorText: failure.fieldError('current_password'),
                suffixIcon: IconButton(
                  icon: Icon(_obscureCurrent ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Enter your current password' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'New Password',
                controller: _newPasswordController,
                obscureText: _obscureNew,
                prefixIcon: Icons.lock_outline_rounded,
                errorText: failure.fieldError('password'),
                suffixIcon: IconButton(
                  icon: Icon(_obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
                validator: (value) {
                  if (value == null || value.length < 8) return 'Password must be at least 8 characters';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Confirm New Password',
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                prefixIcon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                validator: (value) {
                  if (value != _newPasswordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Change Password',
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
