import '../../../../constants/education_exam_type.dart';
import '../../domain/entities/education_plan.dart';

/// JSON <-> [EducationPlan] mapping.
///
/// Assumed VTpass-style shape (matching the confirmed `/data/plans` shape):
/// `{ "variation_code": "jamb-utme", "name": "JAMB UTME", "amount": 700 }`
/// with amount in plain Naira, converted to kobo here.
class EducationPlanModel {
  static EducationPlan fromJson(Map<String, dynamic> json, EducationExamType examType) {
    return EducationPlan(
      id: (json['variation_code'] ?? json['id']).toString(),
      examType: examType,
      name: json['name'] as String? ?? '',
      priceKobo: _nairaToKobo(json['amount'] ?? json['price']),
    );
  }

  static int _nairaToKobo(dynamic raw) {
    if (raw == null) return 0;
    final naira = raw is num ? raw : num.tryParse(raw.toString()) ?? 0;
    return (naira * 100).round();
  }
}
