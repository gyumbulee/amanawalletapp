import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../wallet/presentation/providers/wallet_balance_provider.dart';
import 'profile_repository_provider.dart';

class SetPinController extends AsyncNotifier<bool> {
  @override
  bool build() => false;

  Future<void> submit({required String pin, required String pinConfirmation}) async {
    state = const AsyncLoading();
    final repo = ref.read(profileRepositoryProvider);
    state = await AsyncValue.guard(() async {
      await repo.setTransactionPin(pin: pin, pinConfirmation: pinConfirmation);
      // hasPin lives on the wallet record on the backend, not the user —
      // refresh the wallet so the Profile screen's status reflects the
      // real value rather than an optimistic guess on AuthUser.
      await ref.read(walletBalanceProvider.notifier).refresh();
      return true;
    });
  }
}

final setPinControllerProvider = AsyncNotifierProvider<SetPinController, bool>(SetPinController.new);
