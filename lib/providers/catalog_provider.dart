import 'package:flutter/material.dart';
import 'package:my_order_pro/data/models/banner.dart';
import 'package:my_order_pro/data/models/category.dart';
import 'package:my_order_pro/data/models/product.dart';
import 'package:my_order_pro/data/repository.dart';

class CatalogProvider extends ChangeNotifier {
  final Repository repository;
  CatalogProvider({required this.repository});

  bool _loading = false;
  bool get loading => _loading;
  bool get isLoading => _loading;

  List<CategoryModel> categories = [];
  List<BannerModel> banners = [];
  List<Product> featured = [];
  List<Product> popular = [];

  Future<void> loadHome() async {
    _loading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        repository.getCategories().catchError((e) {
          debugPrint('Error loading categories: $e');
          return <CategoryModel>[];
        }),
        repository.getBanners().catchError((e) {
          debugPrint('Error loading banners: $e');
          return <BannerModel>[];
        }),
        repository.getFeatured().catchError((e) {
          debugPrint('Error loading featured: $e');
          return <Product>[];
        }),
        repository.getPopular().catchError((e) {
          debugPrint('Error loading popular: $e');
          return <Product>[];
        }),
      ]);
      categories = results[0] as List<CategoryModel>;
      banners = results[1] as List<BannerModel>;
      featured = results[2] as List<Product>;
      popular = results[3] as List<Product>;
    } catch (e) {
      debugPrint('Error loading catalog: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<List<Product>> productsForCategory(String categoryId) =>
      repository.getProducts(categoryId: categoryId);

  Future<List<Product>> search(String query) =>
      repository.getProducts(query: query);

  CategoryModel? categoryById(String id) {
    final match = categories.where((c) => c.id == id);
    return match.isNotEmpty ? match.first : null;
  }
}