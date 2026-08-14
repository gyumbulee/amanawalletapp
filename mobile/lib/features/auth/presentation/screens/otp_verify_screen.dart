import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/app_constants.dart';
import '../../../../core/errors/failure.dart';
import '../../../../routing/app_router.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/otp_input.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../theme/app_colors.dart';
import '../providers/otp_verify_controller.dart';
import '../widgets/auth_header.dart';

/// Reached after register or an unverified login attempt. Expects the
/// target email passed via `context.push(AppRoutes.verifyOtp, extra: email)`.
class OtpVerifyScreen extends ConsumerStatefulWidget {
  const OtpVerifyScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  String _otp = '';
  Timer? _cooldownTimer;
  int _secondsLeft = AppConstants.otpResendCooldown.inSeconds;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _secondsLeft = AppConstants.otpResendCooldown.inSeconds;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _verify() async {
    if (_otp.length != AppConstants.otpLength) {
      context.showSnack('Enter the ${AppConstants.otpLength}-digit code', isError: true);
      return;
    }
    await ref.read(otpVerifyControllerProvider.notifier).verify(email: widget.email, otp: _otp);

    if (!mounted) return;
    final state = ref.read(otpVerifyControllerProvider);
    state.whenOrNull(
      data: (verified) {
        if (verified) context.go(AppRoutes.dashboard);
      },
      error: (error, _) {
        final failure = error is Failure ? error : null;
        context.showSnack(failure?.message ?? 'Invalid or expired code. Please try again.', isError: true);
      },
    );
  }

  Future<void> _resend() async {
    await ref.read(resendOtpControllerProvider.notifier).resend(email: widget.email);
    if (!mounted) return;
    final state = ref.read(resendOtpControllerProvider);
    if (state.hasError) {
      final failure = state.error is Failure ? state.error as Failure : null;
      context.showSnack(failure?.message ?? 'Could not resend code. Please try again.', isError: true);
    } else {
      context.showSnack('A new code has been sent to ${widget.email}');
      _startCooldown();
    }
  }

  @override
  Widget build(BuildContext context) {
    final verifyState = ref.watch(otpVerifyControllerProvider);
    final resendState = ref.watch(resendOtpControllerProvider);
    final isVerifying = verifyState.isLoading;
    final isResending = resendState.isLoading;

    return ResponsiveScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          AuthHeader(
            title: 'Verify your email',
            subtitle: 'Enter the ${AppConstants.otpLength}-digit code sent to ${widget.email}',
          ),
          OtpInput(
            length: AppConstants.otpLength,
            onChanged: (value) => _otp = value,
            onCompleted: (value) {
              _otp = value;
              _verify();
            },
          ),
          const SizedBox(height: 28),
          PrimaryButton(label: 'Verify', isLoading: isVerifying, onPressed: _verify),
          const SizedBox(height: 20),
          Center(
            child: _secondsLeft > 0
                ? Text(
                    'Resend code in ${_secondsLeft}s',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  )
                : TextButton(
                    onPressed: isResending ? null : _resend,
                    child: Text(isResending ? 'Sending...' : 'Resend Code'),
                  ),
          ),
        ],
      ),
    );
  }
}
