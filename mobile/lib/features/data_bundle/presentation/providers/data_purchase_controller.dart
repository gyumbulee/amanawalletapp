import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/network_provider.dart';
import '../../../../core/utils/idempotency_key_generator.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_list_provider.dart';
import '../../../wallet/presentation/providers/wallet_balance_provider.dart';
import 'data_repository_provider.dart';

class DataPurchaseController extends AsyncNotifier<Transaction?> {
  String _idempotencyKey = IdempotencyKeyGenerator.generate();

  @override
  Transaction? build() => null;

  Future<void> purchase({
    required NetworkProvider network,
    required String variationCode,
    required String phone,
    required String transactionPin,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(dataRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final transaction = await repo.purchase(
        network: network,
        variationCode: variationCode,
        phone: phone,
        transactionPin: transactionPin,
        idempotencyKey: _idempotencyKey,
      );
      await ref.read(walletBalanceProvider.notifier).refresh();
      ref.invalidate(transactionListProvider);
      return transaction;
    });
  }

  void reset() {
    state = const AsyncData(null);
    _idempotencyKey = IdempotencyKeyGenerator.generate();
  }
}

final dataPurchaseControllerProvider =
    AsyncNotifierProvider<DataPurchaseController, Transaction?>(DataPurchaseController.new);
