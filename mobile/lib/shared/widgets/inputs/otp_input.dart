import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';

/// 6-digit OTP entry — used for email verification during registration
/// and for OTP-based password reset confirmation.
class OtpInput extends StatelessWidget {
  const OtpInput({
    super.key,
    required this.onCompleted,
    this.onChanged,
    this.length = 6,
    this.autoFocus = true,
  });

  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final int length;
  final bool autoFocus;

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      length: length,
      autoFocus: autoFocus,
      obscureText: false,
      keyboardType: TextInputType.number,
      animationType: AnimationType.fade,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: AppRadii.inputRadius,
        fieldHeight: 52,
        fieldWidth: 44,
        activeColor: AppColors.accent,
        selectedColor: AppColors.accent,
        inactiveColor: AppColors.border,
        activeFillColor: AppColors.surface,
        selectedFillColor: AppColors.surface,
        inactiveFillColor: AppColors.surface,
      ),
      enableActiveFill: true,
      onChanged: onChanged ?? (_) {},
      onCompleted: onCompleted,
    );
  }
}
