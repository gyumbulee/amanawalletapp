import '../../../../constants/network_provider.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../entities/data_plan.dart';
import '../entities/data_plan_category_info.dart';

abstract class DataRepository {
  Future<List<DataPlanCategoryInfo>> getCategories({required NetworkProvider network});

  Future<List<DataPlan>> getPlans({required NetworkProvider network, String? category});

  Future<Transaction> purchase({
    required NetworkProvider network,
    required String variationCode,
    required String phone,
    required String transactionPin,
    required String idempotencyKey,
  });
}
