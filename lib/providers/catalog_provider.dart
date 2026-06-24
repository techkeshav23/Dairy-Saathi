import 'package:flutter/material.dart';
import 'package:saathi/data/models/banner.dart';
import 'package:saathi/data/models/category.dart';
import 'package:saathi/data/models/product.dart';
import 'package:saathi/data/repository.dart';

class CatalogProvider extends ChangeNotifier {
  final Repository repository;
  CatalogProvider({required this.repository});

  bool _loading = false;
  bool get loading => _loading;

  List<CategoryModel> categories = [];
  List<BannerModel> banners = [];
  List<Product> featured = [];
  List<Product> popular = [];

  Future<void> loadHome() async {
    _loading = true;
    notifyListeners();
    final results = await Future.wait([
      repository.getCategories(),
      repository.getBanners(),
      repository.getFeatured(),
      repository.getPopular(),
    ]);
    categories = results[0] as List<CategoryModel>;
    banners = results[1] as List<BannerModel>;
    featured = results[2] as List<Product>;
    popular = results[3] as List<Product>;
    _loading = false;
    notifyListeners();
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
