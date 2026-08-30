import 'package:equatable/equatable.dart';

/// One entry from `GET /data/categories?network=...` — e.g. SME, Gifting,
/// Corporate Gifting, Data Transfer. Lets the user narrow down a network's
/// plan list before browsing, instead of scrolling everything at once.
class DataPlanCategoryInfo extends Equatable {
  const DataPlanCategoryInfo({
    required this.key,
    required this.label,
    required this.planCount,
  });

  final String key;
  final String label;
  final int planCount;

  @override
  List<Object?> get props => [key, label, planCount];
}
