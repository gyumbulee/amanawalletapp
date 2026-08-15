import '../../../../constants/network_provider.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../entities/data_plan.dart';

abstract class DataRepository {
  Future<List<DataPlan>> getPlans({required NetworkProvider network});

  Future<Transaction> purchase({
    required NetworkProvider network,
    required String variationCode,
    required String phone,
    required String transactionPin,
  });
}
