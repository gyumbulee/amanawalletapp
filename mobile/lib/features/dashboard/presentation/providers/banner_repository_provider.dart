import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/global_providers.dart';
import '../../data/datasources/banner_api_service.dart';
import '../../data/repositories/banner_repository_impl.dart';
import '../../domain/repositories/banner_repository.dart';

final bannerApiServiceProvider = Provider<BannerApiService>((ref) {
  return BannerApiService(ref.watch(dioProvider));
});

final bannerRepositoryProvider = Provider<BannerRepository>((ref) {
  return BannerRepositoryImpl(ref.watch(bannerApiServiceProvider));
});
