import '../../../../constants/electricity_disco.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../domain/entities/meter_validation.dart';
import '../../domain/repositories/electricity_repository.dart';
import '../datasources/electricity_api_service.dart';
import '../models/meter_validation_model.dart';

class ElectricityRepositoryImpl implements ElectricityRepository {
  ElectricityRepositoryImpl(this._api);
  final ElectricityApiService _api;

  @override
  Future<MeterValidation> validateMeter({
    required ElectricityDisco disco,
    required MeterType meterType,
    required String meterNumber,
  }) async {
    try {
      final response = await _api.validateMeter(
        disco: disco.apiValue,
        meterType: meterType.apiValue,
        meterNumber: meterNumber,
      );
      final data = response.data as Map<String, dynamic>;
      final payload = data['data'] is Map ? data['data'] as Map<String, dynamic> : data;
      return MeterValidationModel.fromJson(payload);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<Transaction> purchase({
    required ElectricityDisco disco,
    required MeterType meterType,
    required String meterNumber,
    required int amountKobo,
    required String phone,
    required String transactionPin,
  }) async {
    try {
      final response = await _api.purchase(
        disco: disco.apiValue,
        meterType: meterType.apiValue,
        meterNumber: meterNumber,
        amountKobo: amountKobo,
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
