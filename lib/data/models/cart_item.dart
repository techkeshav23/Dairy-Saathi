import 'package:my_order_pro/data/models/product.dart';

/// A line in the retailer's order cart. Holds the product, the chosen quantity, and the
/// unit it is ordered in ('ea' = piece/pack, 'kg'). Pricing always resolves to the base
/// EA price; a KG line is simply `ea_per_kg` pieces, so the order sent to the server is
/// always in EA (the server prices/stocks in EA).
class CartItem {
  final Product product;
  int quantity;
  String unit; // 'ea' | 'kg'

  CartItem({required this.product, required this.quantity, this.unit = 'ea'});

  /// The order quantity expressed in base units (EA/pack) — used for pricing, stock and
  /// the order payload. A KG line multiplies by the product's ea_per_kg conversion.
  int get baseQty => unit == 'kg' && product.eaPerKg > 0
      ? (quantity * product.eaPerKg).round()
      : quantity;

  /// Per-EA price at the current (base) quantity — auto-applies the right bulk slab.
  double get unitPrice => product.priceForQty(baseQty);

  /// Per-unit price for the *displayed* unit (per-KG when the KG unit is selected).
  double get displayUnitPrice =>
      unit == 'kg' && product.eaPerKg > 0 ? unitPrice * product.eaPerKg : unitPrice;

  double get totalPrice => unitPrice * baseQty;

  /// MRP-based line total (MRP is per EA) — used to show total savings.
  double get mrpTotal => product.mrp * baseQty;

  double get savings => mrpTotal - totalPrice;

  /// Human label for the unit line, e.g. "2.00 KG" or "3 EA".
  String get uomLabel =>
      unit == 'kg' ? '${quantity.toStringAsFixed(2)} KG' : '$quantity EA';

  Map<String, dynamic> toJson() => {
        'product_id': product.id,
        'quantity': baseQty,
      };
}
