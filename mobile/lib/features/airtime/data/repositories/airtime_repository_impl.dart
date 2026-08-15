import '../../../../constants/network_provider.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../domain/repositories/airtime_repository.dart';
import '../datasources/airtime_api_service.dart';

/// Assumes the purchase response looks like:
/// `{ "message": "...", "transaction": { ...same shape as GET /transactions/:ref... } }`
/// (also accepts "data" or a flat body, same defensive pattern used
/// elsewhere in the app).
class AirtimeRepositoryImpl implements AirtimeRepository {
  AirtimeRepositoryImpl(this._api);
  final AirtimeApiService _api;

  @override
  Future<Transaction> purchase({
    required NetworkProvider network,
    required String phone,
    required int amountKobo,
    required String transactionPin,
  }) async {
    try {
      final response = await _api.purchase(
        network: network.apiValue,
        phone: phone,
        amountKobo: amountKobo,
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
