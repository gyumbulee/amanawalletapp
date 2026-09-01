import '../../domain/entities/promo_banner.dart';

class PromoBannerModel {
  static PromoBanner fromJson(Map<String, dynamic> json) {
    return PromoBanner(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      linkType: json['link_type'] as String? ?? 'none',
      linkValue: json['link_value'] as String?,
    );
  }
}
