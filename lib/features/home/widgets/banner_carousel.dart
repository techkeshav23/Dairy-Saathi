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
    final Color? accent = b.accent;
    final bool hasImage = b.image.isNotEmpty;
    const shadow = [Shadow(color: Color(0x99000000), blurRadius: 4, offset: Offset(0, 1))];

    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1) full-bleed background — the uploaded image (or a gradient if none)
          if (hasImage)
            b.image.startsWith('http')
                ? Image.network(b.image, fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _fallbackBg(accent),
                    loadingBuilder: (_, child, progress) =>
                        progress == null ? child : _fallbackBg(accent))
                : Image.asset(b.image, fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _fallbackBg(accent))
          else
            _fallbackBg(accent),

          // 2) overlay — colour tint if an accent is set, else a dark scrim for legibility
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: accent != null
                  ? LinearGradient(
                      begin: Alignment.centerLeft, end: Alignment.centerRight,
                      colors: [
                        accent.withValues(alpha: 0.94),
                        accent.withValues(alpha: 0.66),
                        accent.withValues(alpha: 0.30),
                      ],
                    )
                  : const LinearGradient(
                      begin: Alignment.bottomLeft, end: Alignment.topRight,
                      colors: [Color(0xD9000000), Color(0x40000000), Color(0x00000000)],
                    ),
            ),
          ),

          // 3) content
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (b.tag.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.24),
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    child: Text(b.tag, style: robotoBold.copyWith(
                        color: Colors.white, fontSize: 9.5, letterSpacing: 0.6)),
                  ),
                  const SizedBox(height: 9),
                ],
                Text(b.title,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: robotoBold.copyWith(
                        color: Colors.white, fontSize: Dimensions.fontSizeExtraLarge,
                        letterSpacing: 0.2, shadows: shadow)),
                const SizedBox(height: 4),
                Text(b.subtitle,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: robotoMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.94),
                        fontSize: Dimensions.fontSizeSmall, height: 1.25, shadows: shadow)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Background used when there's no image (or it fails to load): a diagonal gradient
  /// from the banner's accent colour (falls back to slate when no accent).
  Widget _fallbackBg(Color? accent) {
    final c = accent ?? const Color(0xFF334155);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [c, Color.lerp(c, Colors.black, 0.35) ?? c],
        ),
      ),
    );
  }
}
