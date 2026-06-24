import 'package:flutter/material.dart';

/// A product category shown in the catalog grid (e.g. Groceries, Beverages).
/// [icon] is a Material icon used for the programmatic tile artwork.
class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final int itemCount;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.itemCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'].toString(),
        name: json['name'] ?? '',
        icon: Icons.category_outlined,
        color: const Color(0xFF1C6DD0),
        itemCount: int.tryParse('${json['item_count']}') ?? 0,
      );
}
