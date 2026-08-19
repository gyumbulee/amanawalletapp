import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/education_exam_type.dart';
import '../../domain/entities/education_plan.dart';
import 'education_repository_provider.dart';

final educationPlansProvider =
    FutureProvider.family<List<EducationPlan>, EducationExamType>((ref, examType) {
  return ref.watch(educationRepositoryProvider).getPlans(examType: examType);
});
