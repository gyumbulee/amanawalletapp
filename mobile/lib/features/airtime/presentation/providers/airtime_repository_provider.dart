import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/global_providers.dart';
import '../../data/datasources/airtime_api_service.dart';
import '../../data/repositories/airtime_repository_impl.dart';
import '../../domain/repositories/airtime_repository.dart';

final airtimeApiServiceProvider = Provider<AirtimeApiService>((ref) {
  return AirtimeApiService(ref.watch(dioProvider));
});

final airtimeRepositoryProvider = Provider<AirtimeRepository>((ref) {
  return AirtimeRepositoryImpl(ref.watch(airtimeApiServiceProvider));
});
