import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/global_providers.dart';
import '../../data/datasources/education_api_service.dart';
import '../../data/repositories/education_repository_impl.dart';
import '../../domain/repositories/education_repository.dart';

final educationApiServiceProvider = Provider<EducationApiService>((ref) {
  return EducationApiService(ref.watch(dioProvider));
});

final educationRepositoryProvider = Provider<EducationRepository>((ref) {
  return EducationRepositoryImpl(ref.watch(educationApiServiceProvider));
});
