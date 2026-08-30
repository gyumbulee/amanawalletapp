import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/network_provider.dart';
import '../../domain/entities/data_plan_category_info.dart';
import 'data_repository_provider.dart';

/// Categories (SME, Gifting, ...) available for a network, so the user
/// picks one before browsing plans instead of scrolling a flat list.
final dataCategoriesProvider =
    FutureProvider.family<List<DataPlanCategoryInfo>, NetworkProvider>((ref, network) {
  return ref.watch(dataRepositoryProvider).getCategories(network: network);
});
