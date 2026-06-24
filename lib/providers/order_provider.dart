import 'package:flutter/material.dart';
import 'package:saathi/data/models/cart_item.dart';
import 'package:saathi/data/models/ledger_entry.dart';
import 'package:saathi/data/models/order.dart';
import 'package:saathi/data/repository.dart';

class OrderProvider extends ChangeNotifier {
  final Repository repository;
  OrderProvider({required this.repository});

  final List<OrderModel> _orders = [];
  List<OrderModel> get orders => List.unmodifiable(_orders);

  List<LedgerEntry> _ledger = [];
  List<LedgerEntry> get ledger => _ledger;

  int _seq = 10232;
  bool _ledgerLoaded = false;

  /// Demo credit line extended to this retailer (Ananda-style "Credit Limit").
  final double creditLimit = 50000;

  double get outstanding {
    double bal = 0;
    for (final e in _ledger) {
      bal += e.isDebit ? e.amount : -e.amount;
    }
    return bal;
  }

  /// Remaining credit the retailer can still spend on khata.
  double get usableCredit => (creditLimit - outstanding).clamp(0, creditLimit);

  Future<void> loadLedger() async {
    if (_ledgerLoaded) return;
    _ledger = await repository.getLedger();
    _ledgerLoaded = true;
    notifyListeners();
  }

  /// Builds an order from the current cart lines and prepends it to history.
  OrderModel placeOrder({
    required List<CartItem> cartItems,
    required double subtotal,
    required double gst,
    required double deliveryCharge,
    required double total,
    required double savings,
    required PaymentMode paymentMode,
    required String address,
  }) {
    final order = OrderModel(
      id: 'SA${_seq++}',
      placedAt: DateTime.now(),
      lines: cartItems
          .map((i) => OrderLine(
                productId: i.product.id,
                name: i.product.name,
                unit: i.product.unit,
                imageUrl: i.product.image,
                quantity: i.quantity,
                unitPrice: i.unitPrice,
              ))
          .toList(),
      subtotal: subtotal,
      gst: gst,
      deliveryCharge: deliveryCharge,
      total: total,
      savings: savings,
      status: OrderStatus.placed,
      paymentMode: paymentMode,
      address: address,
    );
    _orders.insert(0, order);

    // Pay-later orders add to the khata balance.
    if (paymentMode == PaymentMode.credit) {
      _ledger = [
        LedgerEntry(
          id: 'l_${order.id}',
          date: order.placedAt,
          title: 'Order #${order.id} (Khata)',
          amount: total,
          isDebit: true,
        ),
        ..._ledger,
      ];
    }
    notifyListeners();
    return order;
  }

  OrderModel? orderById(String id) {
    final match = _orders.where((o) => o.id == id);
    return match.isNotEmpty ? match.first : null;
  }
}
