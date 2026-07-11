import 'package:my_order_pro/data/mock_data.dart';
import 'package:my_order_pro/data/models/banner.dart';
import 'package:my_order_pro/data/models/category.dart';
import 'package:my_order_pro/data/models/ledger_entry.dart';
import 'package:my_order_pro/data/models/order.dart';
import 'package:my_order_pro/data/models/product.dart';

/// Data access contract. Today backed by [MockRepository]; swap in an
/// `ApiRepository` (Laravel/REST) later without touching the UI layer.
abstract class Repository {
  Future<List<CategoryModel>> getCategories();
  Future<List<Product>> getProducts({String? categoryId, String? query});
  Future<List<Product>> getFeatured();
  Future<List<Product>> getPopular();
  Future<Product?> getProduct(String id);
  Future<List<BannerModel>> getBanners();
  Future<List<LedgerEntry>> getLedger();

  /// The signed-in retailer's own order history (most recent first).
  Future<List<OrderModel>> getOrders();
}

class MockRepository implements Repository {
  // Network-ish latency so shimmers and loaders are visible.
  Future<void> _delay([int ms = 450]) =>
      Future.delayed(Duration(milliseconds: ms));

  @override
  Future<List<CategoryModel>> getCategories() async {
    await _delay();
    return MockData.categories;
  }

  @override
  Future<List<Product>> getProducts({String? categoryId, String? query}) async {
    await _delay();
    Iterable<Product> result = MockData.products;
    if (categoryId != null && categoryId.isNotEmpty) {
      result = result.where((p) => p.categoryId == categoryId);
    }
    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      result = result.where((p) =>
          p.name.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q));
    }
    return result.toList();
  }

  @override
  Future<List<Product>> getFeatured() async {
    await _delay();
    return MockData.products.where((p) => p.isFeatured).toList();
  }

  @override
  Future<List<Product>> getPopular() async {
    await _delay();
    return MockData.products.where((p) => p.isPopular).toList();
  }

  @override
  Future<Product?> getProduct(String id) async {
    await _delay(200);
    final match = MockData.products.where((p) => p.id == id);
    return match.isNotEmpty ? match.first : null;
  }

  @override
  Future<List<BannerModel>> getBanners() async {
    await _delay(200);
    return MockData.banners;
  }

  @override
  Future<List<LedgerEntry>> getLedger() async {
    await _delay();
    return MockData.ledger(DateTime.now());
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    await _delay();
    // Mock mode keeps order history in-session only (see OrderProvider).
    return const [];
  }
}
