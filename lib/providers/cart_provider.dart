import 'package:flutter/material.dart';
import 'package:my_order_pro/data/models/cart_item.dart';
import 'package:my_order_pro/data/models/product.dart';
import 'package:my_order_pro/util/app_constants.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;
  int get distinctCount => _items.length;

  int get totalUnits => _items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => _items.fold(0, (sum, i) => sum + i.totalPrice);

  double get totalSavings => _items.fold(0, (sum, i) => sum + i.savings);

  double get gst => subtotal * AppConstants.gstPercent / 100;

  double get deliveryCharge =>
      subtotal >= AppConstants.freeDeliveryThreshold || subtotal == 0
          ? 0
          : AppConstants.deliveryCharge;

  double get grandTotal => subtotal + gst + deliveryCharge;

  int quantityOf(String productId) {
    final match = _items.where((i) => i.product.id == productId);
    return match.isNotEmpty ? match.first.quantity : 0;
  }

  CartItem? _find(String productId) {
    final match = _items.where((i) => i.product.id == productId);
    return match.isNotEmpty ? match.first : null;
  }

  /// Add the product at its MOQ (or bump by one step if already in cart).
  void add(Product product) {
    final existing = _find(product.id);
    if (existing == null) {
      _items.add(CartItem(product: product, quantity: product.moq));
    } else {
      existing.quantity += 1;
    }
    notifyListeners();
  }

  void increment(String productId) {
    final item = _find(productId);
    if (item != null) {
      item.quantity += 1;
      notifyListeners();
    }
  }

  /// Decrement by one; drops below MOQ removes the line.
  void decrement(String productId) {
    final item = _find(productId);
    if (item == null) return;
    if (item.quantity - 1 < item.product.moq) {
      _items.remove(item);
    } else {
      item.quantity -= 1;
    }
    notifyListeners();
  }

  /// Switch a line between EA and KG. Resets qty to 1 so the number always reads in the
  /// newly-selected unit (5 EA is not 5 KG). No-op if the product has no KG conversion.
  void setUnit(String productId, String unit) {
    final item = _find(productId);
    if (item == null) return;
    if (unit == 'kg' && !item.product.hasKg) return;
    if (item.unit == unit) return;
    item.unit = unit;
    item.quantity = 1;
    notifyListeners();
  }

  void setQuantity(String productId, int qty) {
    final item = _find(productId);
    if (item == null) return;
    
    if (qty <= 0) {
      _items.remove(item);
    } else {
      item.quantity = qty < item.product.moq ? item.product.moq : qty;
    }
    notifyListeners();
  }

  void remove(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}