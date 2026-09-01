import 'package:equatable/equatable.dart';

/// Admin-managed promotional banner shown in the dashboard carousel.
/// linkType is 'none' | 'service' | 'url'; linkValue is a route name
/// (e.g. 'airtime') for 'service', or a full URL for 'url'.
class PromoBanner extends Equatable {
  const PromoBanner({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.linkType,
    this.linkValue,
  });

  final int id;
  final String title;
  final String imageUrl;
  final String linkType;
  final String? linkValue;

  @override
  List<Object?> get props => [id, title, imageUrl, linkType, linkValue];
}
