import '../entities/promo_banner.dart';

abstract class BannerRepository {
  Future<List<PromoBanner>> getBanners();
}
