import 'package:my_order_pro/data/models/product.dart';

/// A line in the retailer's order cart. Holds the product plus chosen quantity;
/// per-unit price is derived live from the product's bulk slabs.
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});

  /// Per-unit price at the current quantity (auto-applies the right bulk slab).
  double get unitPrice => product.priceForQty(quantity);

  double get totalPrice => unitPrice * quantity;

  /// MRP-based line total — used to show total savings.
  double get mrpTotal => product.mrp * quantity;

  double get savings => mrpTotal - totalPrice;

  Map<String, dynamic> toJson() => {
        'product_id': product.id,
        'quantity': quantity,
      };
}
