import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/global_providers.dart';
import '../../../../theme/app_radii.dart';
import '../../domain/entities/promo_banner.dart';
import 'banner_carousel.dart';

/// Shows the current active promo banners as a dismissible popup, at most
/// once per day for a given set of banners. Call this after banners have
/// loaded (e.g. from a `ref.listen` on the banners provider's data case) —
/// safe to call on every load/refresh, since the "already shown today"
/// check makes repeat calls a no-op.
class PromoBannerDialog {
  PromoBannerDialog._();

  static Future<void> maybeShow(
    BuildContext context,
    WidgetRef ref, {
    required List<PromoBanner> banners,
    required ValueChanged<PromoBanner> onTap,
  }) async {
    if (banners.isEmpty) return;

    final storage = ref.read(localStorageProvider);
    final signature = (banners.map((b) => b.id).toList()..sort()).join(',');
    final today = DateTime.now().toIso8601String().split('T').first;

    final alreadyShown =
        storage.getLastPromoSignature() == signature && storage.getLastPromoShownDate() == today;
    if (alreadyShown) return;

    await storage.setLastPromoShown(signature, today);

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: AppRadii.cardRadius,
                child: Material(
                  color: Colors.white,
                  child: BannerCarousel(
                    banners: banners,
                    onTap: (banner) {
                      Navigator.of(context).pop();
                      onTap(banner);
                    },
                  ),
                ),
              ),
              Positioned(
                top: -14,
                right: -14,
                child: _CloseButton(onTap: () => Navigator.of(context).pop()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const Padding(
          padding: EdgeInsets.all(6),
          child: Icon(Icons.close_rounded, size: 20, color: Colors.black87),
        ),
      ),
    );
  }
}
