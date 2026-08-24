import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/global_providers.dart';
import '../../data/datasources/support_api_service.dart';
import '../../data/repositories/support_repository_impl.dart';
import '../../domain/repositories/support_repository.dart';

final supportApiServiceProvider = Provider<SupportApiService>((ref) {
  return SupportApiService(ref.watch(dioProvider));
});

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  return SupportRepositoryImpl(ref.watch(supportApiServiceProvider));
});
