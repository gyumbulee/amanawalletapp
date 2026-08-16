import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/global_providers.dart';
import '../../data/datasources/cable_api_service.dart';
import '../../data/repositories/cable_repository_impl.dart';
import '../../domain/repositories/cable_repository.dart';

final cableApiServiceProvider = Provider<CableApiService>((ref) {
  return CableApiService(ref.watch(dioProvider));
});

final cableRepositoryProvider = Provider<CableRepository>((ref) {
  return CableRepositoryImpl(ref.watch(cableApiServiceProvider));
});
