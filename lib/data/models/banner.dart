import 'package:flutter/material.dart';

/// A home promo banner rendered as a bright "designed" card: white background,
/// a coloured corner swoosh, a product thumbnail and a bold headline — matching
/// the Ananda "STOCK AVAILABLE / Place Demand Now" promo style.
class BannerModel {
  final String title;
  final String subtitle;
  final String tag;
  final String image; // product thumbnail asset
  final Color accent;

  const BannerModel({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.image,
    required this.accent,
  });
}
