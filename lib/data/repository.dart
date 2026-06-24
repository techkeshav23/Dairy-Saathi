import 'package:saathi/data/mock_data.dart';
import 'package:saathi/data/models/banner.dart';
import 'package:saathi/data/models/category.dart';
import 'package:saathi/data/models/ledger_entry.dart';
import 'package:saathi/data/models/product.dart';

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

  /// Simulated send-OTP. Returns the OTP so the demo can auto-fill it.
  Future<String> requestOtp(String phone);
  Future<bool> verifyOtp(String phone, String otp);
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
  Future<String> requestOtp(String phone) async {
    await _delay(800);
    return '1234'; // demo OTP
  }

  @override
  Future<bool> verifyOtp(String phone, String otp) async {
    await _delay(700);
    return otp == '1234';
  }
}
