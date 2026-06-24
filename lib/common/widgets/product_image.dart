import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:saathi/data/mock_data.dart';

/// Renders a product image. Supports bundled assets ("assets/...") and network
/// URLs (cached). Falls back to a clean, neutral grey tile (never a coloured
/// block) so the catalog always looks like a real app.
class ProductImage extends StatelessWidget {
  final String url;
  final String categoryId;
  final double size;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.url,
    required this.categoryId,
    this.size = 80,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final icon = MockData.iconForCategory(categoryId);

    Widget fallback() => Container(
          color: const Color(0xFFF1F2F4),
          alignment: Alignment.center,
          child: Icon(icon, color: const Color(0xFFC5C9D1), size: size * 0.4),
        );

    Widget child;
    if (url.isEmpty) {
      child = fallback();
    } else if (url.startsWith('assets/')) {
      child = Image.asset(
        url,
        fit: fit,
        width: size,
        height: size,
        errorBuilder: (_, _, _) => fallback(),
      );
    } else {
      child = CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        placeholder: (_, _) => fallback(),
        errorWidget: (_, _, _) => fallback(),
        fadeInDuration: const Duration(milliseconds: 250),
      );
    }

    return SizedBox(width: size, height: size, child: child);
  }
}
