import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/promo_banner.dart';
import 'banner_repository_provider.dart';

final bannersProvider = FutureProvider<List<PromoBanner>>((ref) {
  return ref.watch(bannerRepositoryProvider).getBanners();
});
