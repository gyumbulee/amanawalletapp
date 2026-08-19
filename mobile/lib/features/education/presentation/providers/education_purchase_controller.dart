import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/education_exam_type.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_list_provider.dart';
import '../../../wallet/presentation/providers/wallet_balance_provider.dart';
import 'education_repository_provider.dart';

class EducationPurchaseController extends AsyncNotifier<Transaction?> {
  @override
  Transaction? build() => null;

  Future<void> purchase({
    required EducationExamType examType,
    required String variationCode,
    required String phone,
    required String transactionPin,
    String? profileId,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(educationRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final transaction = await repo.purchase(
        examType: examType,
        variationCode: variationCode,
        phone: phone,
        transactionPin: transactionPin,
        profileId: profileId,
      );
      await ref.read(walletBalanceProvider.notifier).refresh();
      ref.invalidate(transactionListProvider);
      return transaction;
    });
  }

  void reset() => state = const AsyncData(null);
}

final educationPurchaseControllerProvider =
    AsyncNotifierProvider<EducationPurchaseController, Transaction?>(EducationPurchaseController.new);
