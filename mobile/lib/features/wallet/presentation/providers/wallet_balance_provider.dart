import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/wallet_balance.dart';
import 'wallet_repository_provider.dart';

/// Wallet balance as an [AsyncNotifier] (rather than a plain FutureProvider)
/// so the dashboard and wallet screen can call `.refresh()` explicitly —
/// e.g. after a successful bill payment, or on pull-to-refresh — without
/// needing to `ref.invalidate` from an unrelated widget.
class WalletBalanceController extends AsyncNotifier<WalletBalance> {
  @override
  Future<WalletBalance> build() {
    return ref.read(walletRepositoryProvider).getBalance();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(walletRepositoryProvider).getBalance());
  }
}

final walletBalanceProvider =
    AsyncNotifierProvider<WalletBalanceController, WalletBalance>(WalletBalanceController.new);
