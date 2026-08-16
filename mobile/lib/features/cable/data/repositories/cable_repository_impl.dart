import '../../../../constants/cable_provider.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../domain/entities/cable_package.dart';
import '../../domain/entities/smartcard_validation.dart';
import '../../domain/repositories/cable_repository.dart';
import '../datasources/cable_api_service.dart';
import '../models/cable_package_model.dart';
import '../models/smartcard_validation_model.dart';

class CableRepositoryImpl implements CableRepository {
  CableRepositoryImpl(this._api);
  final CableApiService _api;

  @override
  Future<List<CablePackage>> getPackages({required CableProvider provider}) async {
    try {
      final response = await _api.getPackages(provider: provider.apiValue);
      final raw = response.data;
      final List<dynamic> rawList = raw is List
          ? raw
          : (raw is Map<String, dynamic>
              ? (raw['data'] ?? raw['plans'] ?? raw['packages'] ?? const []) as List
              : const []);
      return rawList
          .map((e) => CablePackageModel.fromJson(e as Map<String, dynamic>, provider))
          .toList();
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<SmartcardValidation> validateSmartcard({
    required CableProvider provider,
    required String smartCardNumber,
  }) async {
    try {
      final response = await _api.validateSmartcard(
        provider: provider.apiValue,
        smartCardNumber: smartCardNumber,
      );
      final data = response.data as Map<String, dynamic>;
      final payload = data['data'] is Map ? data['data'] as Map<String, dynamic> : data;
      return SmartcardValidationModel.fromJson(payload);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<Transaction> purchase({
    required CableProvider provider,
    required String smartCardNumber,
    required String variationCode,
    required String phone,
    required String transactionPin,
  }) async {
    try {
      final response = await _api.purchase(
        provider: provider.apiValue,
        smartCardNumber: smartCardNumber,
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
