import '../../../../constants/network_provider.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../domain/entities/data_plan.dart';
import '../../domain/repositories/data_repository.dart';
import '../datasources/data_api_service.dart';
import '../models/data_plan_model.dart';

class DataRepositoryImpl implements DataRepository {
  DataRepositoryImpl(this._api);
  final DataApiService _api;

  @override
  Future<List<DataPlan>> getPlans({required NetworkProvider network}) async {
    try {
      final response = await _api.getPlans(network: network.apiValue);
      final raw = response.data;
      // Accept a bare list, or a map wrapped under "data"/"plans".
      final List<dynamic> rawList = raw is List
          ? raw
          : (raw is Map<String, dynamic>
              ? (raw['data'] ?? raw['plans'] ?? const []) as List
              : const []);
      return rawList
          .map((e) => DataPlanModel.fromJson(e as Map<String, dynamic>, network))
          .toList();
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<Transaction> purchase({
    required NetworkProvider network,
    required String variationCode,
    required String phone,
    required String transactionPin,
  }) async {
    try {
      final response = await _api.purchase(
        network: network.apiValue,
        variationCode: variationCode,
        phone: phone,
        transactionPin: transactionPin,
      );
      final data = response.data as Map<String, dynamic>;
      final payload = data['transaction'] is Map
          ? data['transaction'] as Map<String, dynamic>
          : (data['data'] is Map ? data['data'] as Map<String, dynamic> : data);
      return TransactionModel.fromJson(payload);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }
}
