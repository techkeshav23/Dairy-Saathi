import 'package:flutter/material.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/styles.dart';

/// MY ORDER PRO brand mark — the app icon (assets/brand/app_icon.png) with an
/// optional wordmark. Falls back to a simple painted mark if the asset is missing.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;
  const AppLogo({super.key, this.size = 72, this.showWordmark = false});

  @override
  Widget build(BuildContext context) {
    final mark = ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.24),
      child: Image.asset(
        'assets/brand/app_icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(size * 0.24),
          ),
          child: Icon(Icons.shopping_bag_rounded, color: Colors.white, size: size * 0.55),
        ),
      ),
    );

    if (!showWordmark) return mark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(height: size * 0.22),
        Text('MY ORDER PRO', style: robotoBlack.copyWith(
          fontSize: size * 0.30, color: AppColors.textDark, letterSpacing: 1.0)),
        Text('Wholesale ordering, simplified', style: robotoMedium.copyWith(
          fontSize: size * 0.15, color: AppColors.textMedium)),
      ],
    );
  }
}
