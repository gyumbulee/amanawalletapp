import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/global_providers.dart';
import '../../data/datasources/profile_api_service.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';

final profileApiServiceProvider = Provider<ProfileApiService>((ref) {
  return ProfileApiService(ref.watch(dioProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(profileApiServiceProvider));
});
