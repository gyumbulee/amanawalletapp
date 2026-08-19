import 'package:equatable/equatable.dart';
import '../../../../constants/education_exam_type.dart';

/// A purchasable PIN option for an exam board (e.g. "JAMB UTME", "WAEC
/// Result Checker"). Fixed price per plan, same as data bundles/cable
/// packages.
class EducationPlan extends Equatable {
  const EducationPlan({
    required this.id,
    required this.examType,
    required this.name,
    required this.priceKobo,
  });

  final String id;
  final EducationExamType examType;
  final String name;
  final int priceKobo;

  @override
  List<Object?> get props => [id, examType, name, priceKobo];
}
