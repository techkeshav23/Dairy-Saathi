/// Lifecycle states a wholesale order moves through.
enum OrderStatus { placed, confirmed, packed, dispatched, delivered, cancelled }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.packed:
        return 'Packed';
      case OrderStatus.dispatched:
        return 'Dispatched';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// A snapshot of one ordered line (denormalised so order history stays stable
/// even if the catalog price later changes).
class OrderLine {
  final String productId;
  final String name;
  final String unit;
  final String imageUrl;
  final int quantity;
  final double unitPrice;

  /// How the line was ordered: 'ea' (qty = pieces) or 'crate' (qty = crates).
  final String orderedUnit;

  const OrderLine({
    required this.productId,
    required this.name,
    required this.unit,
    required this.imageUrl,
    required this.quantity,
    required this.unitPrice,
    this.orderedUnit = 'ea',
  });

  double get total => unitPrice * quantity;

  /// Quantity label including the unit, e.g. "2 crates" or "10".
  String get qtyLabel =>
      orderedUnit == 'crate' ? '$quantity crate${quantity == 1 ? '' : 's'}' : '$quantity';
}

enum PaymentMode { cod, online, credit, qr }

extension PaymentModeX on PaymentMode {
  String get label {
    switch (this) {
      case PaymentMode.cod:
        return 'Cash on Delivery';
      case PaymentMode.online:
        return 'Online / UPI';
      case PaymentMode.credit:
        return 'Pay Later (Khata)';
      case PaymentMode.qr:
        return 'Pay via QR Code';
    }
  }
}

class OrderModel {
  final String id;
  final DateTime placedAt;
  final List<OrderLine> lines;
  final double subtotal;
  final double gst;
  final double deliveryCharge;
  final double total;
  final double savings;
  final OrderStatus status;
  final PaymentMode paymentMode;
  final String address;

  const OrderModel({
    required this.id,
    required this.placedAt,
    required this.lines,
    required this.subtotal,
    required this.gst,
    required this.deliveryCharge,
    required this.total,
    required this.savings,
    required this.status,
    required this.paymentMode,
    required this.address,
  });

  int get itemCount => lines.fold(0, (sum, l) => sum + l.quantity);
}
