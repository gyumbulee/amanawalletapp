import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Standard text input. Styling comes from InputDecorationTheme (see
/// theme/app_theme.dart) — this widget just wires up common options so
/// screens don't repeat boilerplate.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.onChanged,
    this.validator,
    this.autofillHints,
    this.maxLines = 1,
    this.minLines,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;

  /// Restricts which characters can be typed/pasted at all (e.g.
  /// digits-only, a max length) — enforced as the user types, not just
  /// flagged after the fact by [validator] on submit.
  final List<TextInputFormatter>? inputFormatters;

  /// Defaults to a single line, same as before this field existed, so
  /// every existing call site is unaffected. Pass a higher value (and
  /// usually a matching [minLines]) for multi-line compose boxes.
  final int? maxLines;
  final int? minLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      enabled: enabled,
      onChanged: onChanged,
      validator: validator,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      maxLines: obscureText ? 1 : maxLines,
      minLines: obscureText ? null : minLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        errorText: errorText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
