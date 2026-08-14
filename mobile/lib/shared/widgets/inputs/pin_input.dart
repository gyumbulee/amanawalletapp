import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';

/// 4-digit transaction PIN entry — used for confirming purchases (airtime,
/// data, electricity, cable, education) and for setting/changing the PIN
/// in the profile module.
class PinInput extends StatelessWidget {
  const PinInput({
    super.key,
    required this.onCompleted,
    this.onChanged,
    this.length = 4,
    this.autoFocus = true,
    this.obscure = true,
  });

  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final int length;
  final bool autoFocus;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      length: length,
      autoFocus: autoFocus,
      obscureText: obscure,
      obscuringCharacter: '●',
      keyboardType: TextInputType.number,
      animationType: AnimationType.fade,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: AppRadii.inputRadius,
        fieldHeight: 56,
        fieldWidth: 52,
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
