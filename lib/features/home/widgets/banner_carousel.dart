import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:my_order_pro/data/models/banner.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/dimensions.dart';
import 'package:my_order_pro/util/styles.dart';

class BannerCarousel extends StatefulWidget {
  final List<BannerModel> banners;
  const BannerCarousel({super.key, required this.banners});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 150,
            viewportFraction: 0.92,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            enlargeCenterPage: true,
            enlargeFactor: 0.14,
            onPageChanged: (i, _) => setState(() => _current = i),
          ),
          items: widget.banners.map(_buildBanner).toList(),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.banners.length, (i) {
            final active = i == _current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 6, height: 6,
              decoration: BoxDecoration(
                color: active ? AppColors.warning : AppColors.warning.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBanner(BannerModel b) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          children: [
            // decorative corner swoosh (top-left)
            Positioned(
              left: -46, top: -52,
              child: Transform.rotate(
                angle: -0.5,
                child: Container(
                  width: 170, height: 96,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [b.accent, AppColors.warning],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Row(
                children: [
                  // product thumbnail
                  Container(
                    width: 92, height: 110,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                      color: AppColors.surface,
                    ),
                    child: b.image.startsWith('http')
                        ? Image.network(b.image, fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(color: AppColors.surface),
                            loadingBuilder: (_, child, progress) =>
                                progress == null ? child : Container(color: AppColors.surface))
                        : Image.asset(b.image, fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(color: AppColors.surface)),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: b.accent,
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                          child: Text(b.tag, style: robotoBold.copyWith(
                              color: Colors.white, fontSize: 9, letterSpacing: 0.5)),
                        ),
                        const SizedBox(height: 8),
                        Text(b.title,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: robotoBold.copyWith(
                                color: b.accent, fontSize: Dimensions.fontSizeExtraLarge, letterSpacing: 0.2)),
                        const SizedBox(height: 3),
                        Text(b.subtitle,
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: robotoMedium.copyWith(
                                color: AppColors.textMedium, fontSize: Dimensions.fontSizeSmall, height: 1.25)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
