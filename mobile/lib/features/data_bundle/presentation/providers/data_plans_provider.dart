import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/network_provider.dart';
import '../../domain/entities/data_plan.dart';
import 'data_repository_provider.dart';

/// Plans for a given (network, category), fetched on demand. Keyed by a
/// record so switching network OR category reuses the cache correctly —
/// category is nullable only as a safety fallback; the screen always
/// picks a category before this is watched.
typedef DataPlansQuery = ({NetworkProvider network, String? category});

final dataPlansProvider = FutureProvider.family<List<DataPlan>, DataPlansQuery>((ref, query) {
  return ref.watch(dataRepositoryProvider).getPlans(network: query.network, category: query.category);
});
