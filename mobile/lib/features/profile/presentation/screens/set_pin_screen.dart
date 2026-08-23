import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failure.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/inputs/pin_input.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../theme/app_colors.dart';
import '../../../wallet/presentation/providers/wallet_balance_provider.dart';
import '../providers/set_pin_controller.dart';

enum _PinStep { currentPin, newPin, confirmPin }

/// Handles both "create a PIN" and "change my PIN" with the same screen,
/// branching on WalletBalance.hasPin — the only reliable source of truth
/// (it lives on the wallet record server-side, not on AuthUser).
///
/// - No PIN yet: newPin -> confirmPin (2 steps), current_pin omitted.
/// - PIN already set: currentPin -> newPin -> confirmPin (3 steps),
///   current_pin sent so the backend can verify it before allowing a change.
class SetPinScreen extends ConsumerStatefulWidget {
  const SetPinScreen({super.key});

  @override
  ConsumerState<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends ConsumerState<SetPinScreen> {
  _PinStep _step = _PinStep.newPin;
  String? _currentPin;
  String? _firstPin;
  bool _initialized = false;

  void _initStep(bool hasPin) {
    if (_initialized) return;
    _initialized = true;
    _step = hasPin ? _PinStep.currentPin : _PinStep.newPin;
  }

  void _startOver(bool hasPin) {
    setState(() {
      _currentPin = null;
      _firstPin = null;
      _step = hasPin ? _PinStep.currentPin : _PinStep.newPin;
    });
  }

  void _onPinCompleted(String pin, bool hasPin) {
    switch (_step) {
      case _PinStep.currentPin:
        setState(() {
          _currentPin = pin;
          _step = _PinStep.newPin;
        });
        return;

      case _PinStep.newPin:
        setState(() {
          _firstPin = pin;
          _step = _PinStep.confirmPin;
        });
        return;

      case _PinStep.confirmPin:
        if (pin != _firstPin) {
          context.showSnack("PINs don't match. Please try again.", isError: true);
          setState(() {
            _firstPin = null;
            _step = _PinStep.newPin;
          });
          return;
        }
        _submit(pin, hasPin);
        return;
    }
  }

  Future<void> _submit(String pin, bool hasPin) async {
    await ref.read(setPinControllerProvider.notifier).submit(
          pin: pin,
          pinConfirmation: pin,
          currentPin: _currentPin,
        );
    if (!mounted) return;
    final state = ref.read(setPinControllerProvider);
    state.whenOrNull(
      data: (success) {
        if (success) {
          context.showSnack(hasPin ? 'Transaction PIN changed successfully' : 'Transaction PIN set successfully');
          context.pop();
        }
      },
      error: (error, _) {
        final failure = error is Failure ? error : null;
        final fieldMessage =
            failure is ValidationFailure ? failure.errors['current_pin']?.first ?? failure.errors['pin']?.first : null;
        final message = fieldMessage ??
            failure?.message ??
            (hasPin ? 'Could not change your PIN. Please try again.' : 'Could not set your PIN. Please try again.');
        context.showSnack(message, isError: true);
        // A wrong current PIN should only send the user back to that step,
        // not force them to redo the new-PIN entry they already got right.
        setState(() {
          _firstPin = null;
          _step = hasPin ? _PinStep.currentPin : _PinStep.newPin;
          if (hasPin) _currentPin = null;
        });
      },
    );
  }

  String _title(_PinStep step, bool hasPin) {
    switch (step) {
      case _PinStep.currentPin:
        return 'Enter your current PIN';
      case _PinStep.newPin:
        return hasPin ? 'Create your new PIN' : 'Create a 4-digit transaction PIN';
      case _PinStep.confirmPin:
        return 'Confirm your new PIN';
    }
  }

  String _subtitle(_PinStep step, bool hasPin) {
    switch (step) {
      case _PinStep.currentPin:
        return 'Verify your existing transaction PIN to continue.';
      case _PinStep.newPin:
      case _PinStep.confirmPin:
        return "You'll use this PIN to confirm every purchase — airtime, data, "
            'electricity, cable, and education.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletBalanceProvider);
    final pinState = ref.watch(setPinControllerProvider);
    final isSubmitting = pinState.isLoading;

    return walletState.when(
      loading: () => const ResponsiveScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => ResponsiveScaffold(
        appBar: AppBar(title: const Text('Transaction PIN')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Could not check your PIN status.'),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.read(walletBalanceProvider.notifier).refresh(),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
      data: (wallet) {
        final hasPin = wallet.hasPin;
        _initStep(hasPin);

        return ResponsiveScaffold(
          appBar: AppBar(title: Text(hasPin ? 'Change Transaction PIN' : 'Set Transaction PIN')),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Text(
                _title(_step, hasPin),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                _subtitle(_step, hasPin),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 32),
              if (isSubmitting)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                PinInput(
                  key: ValueKey(_step), // fresh widget/state per step
                  onCompleted: (pin) => _onPinCompleted(pin, hasPin),
                ),
              if (_step != (hasPin ? _PinStep.currentPin : _PinStep.newPin) && !isSubmitting) ...[
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => _startOver(hasPin),
                    child: const Text('Start over'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
