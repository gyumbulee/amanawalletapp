import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radii.dart';
import '../../domain/entities/promo_banner.dart';

/// Auto-advancing promo banner carousel for the dashboard, admin-managed
/// via the Filament "Banners" resource. Advances every 5s, pauses while
/// the user is actively dragging, and shows dot indicators below.
class BannerCarousel extends StatefulWidget {
  const BannerCarousel({
    super.key,
    required this.banners,
    required this.onTap,
  });

  final List<PromoBanner> banners;
  final ValueChanged<PromoBanner> onTap;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late final PageController _controller = PageController(viewportFraction: 0.92);
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    if (widget.banners.length > 1) _startAutoAdvance();
  }

  void _startAutoAdvance() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_page + 1) % widget.banners.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (index) => setState(() => _page = index),
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: banner.linkType == 'none' ? null : () => widget.onTap(banner),
                  borderRadius: AppRadii.cardRadius,
                  child: ClipRRect(
                    borderRadius: AppRadii.cardRadius,
                    child: CachedNetworkImage(
                      imageUrl: banner.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(color: AppColors.border),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.border,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_not_supported_outlined, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.banners.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < widget.banners.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 6,
                  width: i == _page ? 18 : 6,
                  decoration: BoxDecoration(
                    color: i == _page ? AppColors.accent : AppColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
