import 'package:flutter/material.dart';

/// A home promo banner: the uploaded image fills the whole card as a background,
/// with an optional colour overlay (tint) and the title/subtitle/tag on top —
/// matching the admin panel's banner preview.
class BannerModel {
  final String title;
  final String subtitle;
  final String tag;
  final String image; // full-bleed background (network URL or asset path)
  final Color? accent; // colour overlay tint; null = image only (dark scrim)

  const BannerModel({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.image,
    this.accent,
  });
}
