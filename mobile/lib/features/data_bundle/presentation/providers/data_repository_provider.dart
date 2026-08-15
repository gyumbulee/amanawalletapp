import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/global_providers.dart';
import '../../data/datasources/data_api_service.dart';
import '../../data/repositories/data_repository_impl.dart';
import '../../domain/repositories/data_repository.dart';

final dataApiServiceProvider = Provider<DataApiService>((ref) {
  return DataApiService(ref.watch(dioProvider));
});

final dataRepositoryProvider = Provider<DataRepository>((ref) {
  return DataRepositoryImpl(ref.watch(dataApiServiceProvider));
});
