/// A bulk pricing tier. The lower the slab the cheaper the per-unit price —
/// the heart of B2B wholesale: "more you buy, less you pay".
class PriceSlab {
  final int minQty;
  final double pricePerUnit;

  const PriceSlab({required this.minQty, required this.pricePerUnit});

  factory PriceSlab.fromJson(Map<String, dynamic> json) => PriceSlab(
        minQty: int.tryParse('${json['min_qty']}') ?? 1,
        pricePerUnit: double.tryParse('${json['price']}') ?? 0,
      );

  Map<String, dynamic> toJson() => {'min_qty': minQty, 'price': pricePerUnit};
}

/// A wholesale catalog item.
class Product {
  final String id;
  final String name;
  final String brand;
  final String categoryId;
  final String imageUrl;

  /// Sale unit description e.g. "1 kg", "Pack of 24", "500 ml".
  final String unit;

  /// MRP (printed retail price) used to show the retailer their margin.
  final double mrp;

  /// Bulk pricing tiers, sorted ascending by [minQty].
  final List<PriceSlab> slabs;

  /// Minimum order quantity (cases/units a retailer must buy).
  final int moq;

  final int stock;
  final bool isPopular;
  final bool isFeatured;
  final String description;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.categoryId,
    required this.imageUrl,
    required this.unit,
    required this.mrp,
    required this.slabs,
    this.moq = 1,
    this.stock = 0,
    this.isPopular = false,
    this.isFeatured = false,
    this.description = '',
  });

  /// The remote image URL for this product. Falls back to a placeholder if empty.
  String get image => imageUrl.isNotEmpty ? imageUrl : 'https://your-fallback-image-url.com/placeholder.png';

  bool get inStock => stock > 0;

  /// Base (highest) wholesale price — what you pay at the smallest slab.
  double get basePrice => slabs.isNotEmpty ? slabs.first.pricePerUnit : mrp;

  /// Best achievable wholesale price (largest-volume slab).
  double get bestPrice => slabs.isNotEmpty ? slabs.last.pricePerUnit : mrp;

  /// Suggested resale price for the retailer (between wholesale Rate and MRP).
  double get resalePrice {
    final suggested = mrp * 0.92;
    return suggested > basePrice ? suggested.roundToDouble() : mrp;
  }

  /// The per-unit price for a given order quantity, picking the right slab.
  double priceForQty(int qty) {
    double price = basePrice;
    for (final slab in slabs) {
      if (qty >= slab.minQty) price = slab.pricePerUnit;
    }
    return price;
  }

  /// Retailer's margin % at the base wholesale price vs MRP.
  double get marginPercent {
    if (mrp <= 0) return 0;
    return ((mrp - basePrice) / mrp) * 100;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final parsedSlabs = (json['slabs'] as List? ?? [])
        .map((e) => PriceSlab.fromJson(e))
        .toList();
    
    // Sort slabs ascending by minQty so basePrice, bestPrice, and priceForQty work correctly
    parsedSlabs.sort((a, b) => a.minQty.compareTo(b.minQty));

    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      categoryId: json['category_id'].toString(),
      imageUrl: json['image_url'] ?? json['image'] ?? '',
      unit: json['unit'] ?? '',
      mrp: double.tryParse('${json['mrp']}') ?? 0,
      slabs: parsedSlabs,
      moq: int.tryParse('${json['moq']}') ?? 1,
      stock: int.tryParse('${json['stock']}') ?? 0,
      isPopular: json['is_popular'] == true,
      isFeatured: json['is_featured'] == true,
      description: json['description'] ?? '',
    );
  }
}