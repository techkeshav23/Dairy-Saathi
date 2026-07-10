import 'package:flutter/material.dart';
import 'package:my_order_pro/data/models/cart_item.dart';
import 'package:my_order_pro/data/models/ledger_entry.dart';
import 'package:my_order_pro/data/models/order.dart';
import 'package:my_order_pro/data/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderProvider extends ChangeNotifier {
  final Repository repository;
  final SharedPreferences prefs;
  OrderProvider({required this.repository, required this.prefs});

  final List<OrderModel> _orders = [];
  List<OrderModel> get orders => List.unmodifiable(_orders);

  List<LedgerEntry> _ledger = [];
  List<LedgerEntry> get ledger => _ledger;

  int _seq = 10232;
  bool _ledgerLoaded = false;
  bool _ordersLoaded = false;

  /// Dynamic credit limit fetched from the backend (or default 50k).
  double get creditLimit => prefs.getDouble('saathi_credit_limit') ?? 50000.0;

  /// Outstanding khata balance = the running total of the loaded ledger
  /// (debits add, credits subtract). The server ledger is the source of truth
  /// once loaded; falls back to the cached server value until it is.
  double get outstanding {
    if (_ledger.isEmpty) {
      final cached = prefs.getDouble('saathi_outstanding') ?? 0.0;
      return cached < 0 ? 0 : cached;
    }
    double bal = 0;
    for (final e in _ledger) {
      bal += e.isDebit ? e.amount : -e.amount;
    }
    return bal < 0 ? 0 : bal;
  }

  /// Remaining credit the retailer can still spend on khata.
  double get usableCredit => (creditLimit - outstanding).clamp(0, creditLimit);

  /// Loads the retailer's order history from the backend (once). New orders placed
  /// in-session via [placeOrder] stay on top; this fills in previously-placed orders.
  Future<void> loadOrders() async {
    if (_ordersLoaded) return;
    try {
      final server = await repository.getOrders();
      // keep any in-session orders first, then append server history (de-duped by id)
      final existingIds = _orders.map((o) => o.id).toSet();
      _orders.addAll(server.where((o) => !existingIds.contains(o.id)));
      _ordersLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading orders: $e');
    }
  }

  /// Force a live re-fetch of order history (pull-to-refresh).
  Future<void> refreshOrders() async {
    try {
      final server = await repository.getOrders();
      final sessionOnly = _orders.where((o) => o.id.startsWith('SA')).toList();
      _orders
        ..clear()
        ..addAll(sessionOnly)
        ..addAll(server.where((s) => !sessionOnly.any((o) => o.id == s.id)));
      _ordersLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing orders: $e');
    }
  }

  Future<void> loadLedger() async {
    if (_ledgerLoaded) return;
    try {
      _ledger = await repository.getLedger();
      _ledgerLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading ledger: $e');
    }
  }

  /// Force a live re-fetch of the ledger from the backend (pull-to-refresh),
  /// so entries posted server-side (e.g. by place_order) show up immediately.
  Future<void> refreshLedger() async {
    try {
      _ledger = await repository.getLedger();
      _ledgerLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing ledger: $e');
    }
  }

  /// Builds an order from the current cart lines and prepends it to history.
  OrderModel placeOrder({
    String? id,
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
      id: id ?? 'SA${_seq++}',
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