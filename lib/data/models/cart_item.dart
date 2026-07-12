import 'package:my_order_pro/data/models/product.dart';

/// A line in the retailer's order cart. Holds the product, the chosen quantity, and the
/// unit it is ordered in:
///   'ea'    -> quantity is pieces; priced per piece (bulk slabs apply).
///   'kg'    -> quantity is KG; resolved to `ea_per_kg` pieces, priced per piece.
///   'crate' -> quantity is crates; priced at the product's crate_price. A crate is a
///              bundle of `ea_per_crate` pieces, so it removes that many pieces from stock.
class CartItem {
  final Product product;
  int quantity;
  String unit; // 'ea' | 'kg' | 'crate'

  CartItem({required this.product, required this.quantity, this.unit = 'ea'});

  bool get isCrate => unit == 'crate';

  /// The line expressed in base PIECES (EA) — used for per-piece pricing and stock.
  /// A crate line is `ea_per_crate` pieces; a KG line is `ea_per_kg` pieces.
  int get baseQty {
    if (isCrate && product.eaPerCrate > 0) return quantity * product.eaPerCrate;
    if (unit == 'kg' && product.eaPerKg > 0) return (quantity * product.eaPerKg).round();
    return quantity;
  }

  /// Per-EA (piece) wholesale price at the current piece quantity — auto-applies slabs.
  double get _eaPrice => product.priceForQty(baseQty);

  /// Price of ONE ordered unit (one crate for a crate line, else one piece).
  double get unitPrice => isCrate ? product.cratePrice : _eaPrice;

  /// Per-unit price for the *displayed* unit (per-crate, per-KG, or per-piece).
  double get displayUnitPrice {
    if (isCrate) return product.cratePrice;
    if (unit == 'kg' && product.eaPerKg > 0) return _eaPrice * product.eaPerKg;
    return _eaPrice;
  }

  /// Line total — crate lines are crates × crate price; otherwise pieces × per-piece price.
  double get totalPrice => isCrate ? product.cratePrice * quantity : _eaPrice * baseQty;

  /// MRP-based line total (MRP is per EA) — used to show total savings.
  double get mrpTotal => product.mrp * baseQty;

  double get savings => mrpTotal - totalPrice;

  /// Human label for the unit line, e.g. "2 crates", "2.00 KG" or "3 EA".
  String get uomLabel {
    if (isCrate) return '$quantity crate${quantity == 1 ? '' : 's'}';
    if (unit == 'kg') return '${quantity.toStringAsFixed(2)} KG';
    return '$quantity EA';
  }

  /// Order payload line. A crate line sends the crate count + unit so the server prices
  /// per crate and removes `qty × ea_per_crate` pieces from stock; other lines send pieces.
  Map<String, dynamic> toJson() => isCrate
      ? {'product_id': product.id, 'qty': quantity, 'unit': 'crate', 'unit_price': product.cratePrice}
      : {'product_id': product.id, 'qty': baseQty, 'unit': 'ea', 'unit_price': unitPrice};
}
