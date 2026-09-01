import '../../../../core/network/error_mapper.dart';
import '../../domain/entities/promo_banner.dart';
import '../../domain/repositories/banner_repository.dart';
import '../datasources/banner_api_service.dart';
import '../models/promo_banner_model.dart';

class BannerRepositoryImpl implements BannerRepository {
  BannerRepositoryImpl(this._api);
  final BannerApiService _api;

  @override
  Future<List<PromoBanner>> getBanners() async {
    try {
      final response = await _api.getBanners();
      final raw = response.data;
      final List<dynamic> rawList =
          raw is Map<String, dynamic> ? (raw['banners'] ?? const []) as List : const [];
      return rawList.map((e) => PromoBannerModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }
}
