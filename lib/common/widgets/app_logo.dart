import 'package:flutter/material.dart';
import 'package:saathi/util/app_colors.dart';
import 'package:saathi/util/styles.dart';

/// Programmatic brand mark — a rounded square with a shopping-bag glyph and the
/// "S" monogram. No image asset needed, scales crisply at any size.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;
  const AppLogo({super.key, this.size = 72, this.showWordmark = false});

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: Icon(Icons.storefront_rounded, color: Colors.white, size: size * 0.55),
    );

    if (!showWordmark) return mark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(height: size * 0.22),
        Text('DAIRY DEMO', style: robotoBlack.copyWith(
          fontSize: size * 0.34, color: AppColors.primary, letterSpacing: 1.0)),
        Text('Aapka Wholesale Partner', style: robotoMedium.copyWith(
          fontSize: size * 0.17, color: AppColors.textMedium)),
      ],
    );
  }
}
