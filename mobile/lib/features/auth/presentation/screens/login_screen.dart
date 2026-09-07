import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failure.dart';
import '../../../../routing/app_router.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/extensions/failure_extensions.dart';
import '../../../../shared/extensions/string_extensions.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../theme/app_colors.dart';
import '../providers/login_controller.dart';
import '../widgets/auth_header.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(loginControllerProvider.notifier).login(
          login: _loginController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;
    final state = ref.read(loginControllerProvider);
    state.whenOrNull(
      data: (result) {
        if (result == null) return;
        if (result.requiresOtpVerification) {
          context.showSnack('Please verify your email to continue. A new code has been sent.');
          context.push(AppRoutes.verifyOtp, extra: result.user.email);
        } else {
          context.go(AppRoutes.dashboard);
        }
      },
      error: (error, _) {
        final failure = error is Failure ? error : null;
        context.showSnack(failure?.message ?? 'Something went wrong. Please try again.', isError: true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);
    final isLoading = loginState.isLoading;
    final failure = loginState.hasError ? loginState.error as Failure? : null;

    return ResponsiveScaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const AuthHeader(
                title: 'Welcome back',
                subtitle: 'Log in to continue to your Amana Wallet',
              ),
              AppTextField(
                label: 'Email or Phone Number',
                controller: _loginController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.person_outline_rounded,
                autofillHints: const [AutofillHints.email, AutofillHints.telephoneNumber],
                errorText: failure.fieldError('login'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Email or phone number is required';
                  final trimmed = value.trim();
                  final looksLikeEmail = trimmed.contains('@');
                  if (looksLikeEmail && !trimmed.isValidEmail) return 'Enter a valid email address';
                  if (!looksLikeEmail && !trimmed.isValidNigerianPhone) {
                    return 'Enter a valid email or Nigerian phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Password',
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                prefixIcon: Icons.lock_outline_rounded,
                autofillHints: const [AutofillHints.password],
                errorText: failure.fieldError('password'),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Password is required';
                  return null;
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push(AppRoutes.forgotPassword),
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: 8),
              PrimaryButton(label: 'Log In', isLoading: isLoading, onPressed: _submit),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?", style: TextStyle(color: AppColors.textSecondary)),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.register),
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
