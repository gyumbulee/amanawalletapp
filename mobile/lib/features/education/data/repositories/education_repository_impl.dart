import '../../../../constants/education_exam_type.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../domain/entities/education_plan.dart';
import '../../domain/entities/profile_validation.dart';
import '../../domain/repositories/education_repository.dart';
import '../datasources/education_api_service.dart';
import '../models/education_plan_model.dart';
import '../models/profile_validation_model.dart';

class EducationRepositoryImpl implements EducationRepository {
  EducationRepositoryImpl(this._api);
  final EducationApiService _api;

  @override
  Future<List<EducationPlan>> getPlans({required EducationExamType examType}) async {
    try {
      final response = await _api.getPlans(examType: examType.apiValue);
      final raw = response.data;
      final List<dynamic> rawList = raw is List
          ? raw
          : (raw is Map<String, dynamic>
              ? (raw['data'] ?? raw['plans'] ?? raw['packages'] ?? const []) as List
              : const []);
      return rawList
          .map((e) => EducationPlanModel.fromJson(e as Map<String, dynamic>, examType))
          .toList();
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<ProfileValidation> validateProfile({
    required EducationExamType examType,
    required String variationCode,
    required String profileId,
  }) async {
    try {
      final response = await _api.validateProfile(
        examType: examType.apiValue,
        variationCode: variationCode,
        profileId: profileId,
      );
      final data = response.data as Map<String, dynamic>;
      final payload = data['data'] is Map ? data['data'] as Map<String, dynamic> : data;
      return ProfileValidationModel.fromJson(payload);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<Transaction> purchase({
    required EducationExamType examType,
    required String variationCode,
    required String phone,
    required String transactionPin,
    String? profileId,
  }) async {
    try {
      final response = await _api.purchase(
        examType: examType.apiValue,
        variationCode: variationCode,
        phone: phone,
        transactionPin: transactionPin,
        profileId: profileId,
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
