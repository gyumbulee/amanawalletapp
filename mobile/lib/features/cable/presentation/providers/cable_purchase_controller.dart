import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/cable_provider.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_list_provider.dart';
import '../../../wallet/presentation/providers/wallet_balance_provider.dart';
import 'cable_repository_provider.dart';

class CablePurchaseController extends AsyncNotifier<Transaction?> {
  @override
  Transaction? build() => null;

  Future<void> purchase({
    required CableProvider provider,
    required String smartCardNumber,
    required String variationCode,
    required String phone,
    required String transactionPin,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(cableRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final transaction = await repo.purchase(
        provider: provider,
        smartCardNumber: smartCardNumber,
        variationCode: variationCode,
        phone: phone,
        transactionPin: transactionPin,
      );
      await ref.read(walletBalanceProvider.notifier).refresh();
      ref.invalidate(transactionListProvider);
      return transaction;
    });
  }

  void reset() => state = const AsyncData(null);
}

final cablePurchaseControllerProvider =
    AsyncNotifierProvider<CablePurchaseController, Transaction?>(CablePurchaseController.new);
