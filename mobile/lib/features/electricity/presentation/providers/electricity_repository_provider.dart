import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/global_providers.dart';
import '../../data/datasources/electricity_api_service.dart';
import '../../data/repositories/electricity_repository_impl.dart';
import '../../domain/repositories/electricity_repository.dart';

final electricityApiServiceProvider = Provider<ElectricityApiService>((ref) {
  return ElectricityApiService(ref.watch(dioProvider));
});

final electricityRepositoryProvider = Provider<ElectricityRepository>((ref) {
  return ElectricityRepositoryImpl(ref.watch(electricityApiServiceProvider));
});
