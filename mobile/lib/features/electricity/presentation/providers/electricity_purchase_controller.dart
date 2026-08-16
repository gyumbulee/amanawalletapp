import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/electricity_disco.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_list_provider.dart';
import '../../../wallet/presentation/providers/wallet_balance_provider.dart';
import 'electricity_repository_provider.dart';

class ElectricityPurchaseController extends AsyncNotifier<Transaction?> {
  @override
  Transaction? build() => null;

  Future<void> purchase({
    required ElectricityDisco disco,
    required MeterType meterType,
    required String meterNumber,
    required int amountKobo,
    required String phone,
    required String transactionPin,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(electricityRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final transaction = await repo.purchase(
        disco: disco,
        meterType: meterType,
        meterNumber: meterNumber,
        amountKobo: amountKobo,
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

final electricityPurchaseControllerProvider =
    AsyncNotifierProvider<ElectricityPurchaseController, Transaction?>(ElectricityPurchaseController.new);
