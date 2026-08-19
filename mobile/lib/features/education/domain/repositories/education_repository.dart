import '../../../../constants/education_exam_type.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../entities/education_plan.dart';
import '../entities/profile_validation.dart';

abstract class EducationRepository {
  Future<List<EducationPlan>> getPlans({required EducationExamType examType});

  /// Only meaningful for exam types where
  /// [EducationExamType.requiresProfileValidation] is true (JAMB).
  /// Requires [variationCode] since the profile check is tied to the
  /// specific PIN variant (e.g. UTME with/without mock) — the plan must
  /// be selected before validating, not after.
  Future<ProfileValidation> validateProfile({
    required EducationExamType examType,
    required String variationCode,
    required String profileId,
  });

  Future<Transaction> purchase({
    required EducationExamType examType,
    required String variationCode,
    required String phone,
    required String transactionPin,
    String? profileId,
  });
}
