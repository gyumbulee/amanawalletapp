import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/network_provider.dart';
import '../../domain/entities/data_plan.dart';
import 'data_repository_provider.dart';

/// Plans for a given network, fetched on demand. `.family` keys the cache
/// per network so switching between MTN/Glo/Airtel/9mobile on the same
/// screen doesn't refetch every time the user flips back.
final dataPlansProvider = FutureProvider.family<List<DataPlan>, NetworkProvider>((ref, network) {
  return ref.watch(dataRepositoryProvider).getPlans(network: network);
});
