import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/network_provider.dart';
import '../../../../core/utils/idempotency_key_generator.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_list_provider.dart';
import '../../../wallet/presentation/providers/wallet_balance_provider.dart';
import 'airtime_repository_provider.dart';

class AirtimePurchaseController extends AsyncNotifier<Transaction?> {
  // Held for the lifetime of this controller (i.e. this screen visit) so
  // that retrying after a dropped connection reuses the SAME key — that's
  // what lets the backend recognise "this is a retry" instead of charging
  // twice. Only rotates in reset(), i.e. after a successful purchase or
  // when the user explicitly starts over.
  String _idempotencyKey = IdempotencyKeyGenerator.generate();

  @override
  Transaction? build() => null;

  Future<void> purchase({
    required NetworkProvider network,
    required String phone,
    required int amountKobo,
    required String transactionPin,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(airtimeRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final transaction = await repo.purchase(
        network: network,
        phone: phone,
        amountKobo: amountKobo,
        transactionPin: transactionPin,
        idempotencyKey: _idempotencyKey,
      );
      // Refresh wallet balance and the transactions list so the dashboard,
      // wallet screen, and transactions screen all reflect this purchase
      // without the user needing to pull-to-refresh manually.
      await ref.read(walletBalanceProvider.notifier).refresh();
      ref.invalidate(transactionListProvider);
      return transaction;
    });
  }

  void reset() {
    state = const AsyncData(null);
    // Fresh attempt from here means a genuinely new purchase, not a retry.
    _idempotencyKey = IdempotencyKeyGenerator.generate();
  }
}

final airtimePurchaseControllerProvider =
    AsyncNotifierProvider<AirtimePurchaseController, Transaction?>(AirtimePurchaseController.new);
