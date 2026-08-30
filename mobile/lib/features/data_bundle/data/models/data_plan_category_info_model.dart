import '../../domain/entities/data_plan_category_info.dart';

class DataPlanCategoryInfoModel {
  static DataPlanCategoryInfo fromJson(Map<String, dynamic> json) {
    return DataPlanCategoryInfo(
      key: json['key'] as String? ?? 'other',
      label: json['label'] as String? ?? 'Other',
      planCount: (json['plan_count'] as num?)?.toInt() ?? 0,
    );
  }
}
