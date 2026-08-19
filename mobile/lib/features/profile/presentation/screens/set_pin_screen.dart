import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failure.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/inputs/pin_input.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../theme/app_colors.dart';
import '../providers/set_pin_controller.dart';

/// Two-step PIN entry: enter, then confirm. This is the screen deferred
/// all the way back at registration, since users register without a PIN
/// and every bill-payment purchase flow needs one to exist server-side
/// before it can succeed.
class SetPinScreen extends ConsumerStatefulWidget {
  const SetPinScreen({super.key});

  @override
  ConsumerState<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends ConsumerState<SetPinScreen> {
  String? _firstPin;
  bool get _isConfirmStep => _firstPin != null;

  void _onPinCompleted(String pin) {
    if (!_isConfirmStep) {
      setState(() => _firstPin = pin);
      return;
    }

    if (pin != _firstPin) {
      context.showSnack("PINs don't match. Please try again.", isError: true);
      setState(() => _firstPin = null);
      return;
    }

    _submit(pin);
  }

  Future<void> _submit(String pin) async {
    await ref.read(setPinControllerProvider.notifier).submit(pin: pin, pinConfirmation: pin);
    if (!mounted) return;
    final state = ref.read(setPinControllerProvider);
    state.whenOrNull(
      data: (success) {
        if (success) {
          context.showSnack('Transaction PIN set successfully');
          context.pop();
        }
      },
      error: (error, _) {
        final failure = error is Failure ? error : null;
        context.showSnack(failure?.message ?? 'Could not set your PIN. Please try again.', isError: true);
        setState(() => _firstPin = null);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(setPinControllerProvider);
    final isSubmitting = state.isLoading;

    return ResponsiveScaffold(
      appBar: AppBar(title: const Text('Transaction PIN')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Text(
            _isConfirmStep ? 'Confirm your new PIN' : 'Create a 4-digit transaction PIN',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            "You'll use this PIN to confirm every purchase — airtime, data, "
            'electricity, cable, and education.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 32),
          if (isSubmitting)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            PinInput(
              key: ValueKey(_isConfirmStep), // fresh widget/state per step
              onCompleted: _onPinCompleted,
            ),
          if (_isConfirmStep && !isSubmitting) ...[
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => setState(() => _firstPin = null),
                child: const Text('Start over'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
