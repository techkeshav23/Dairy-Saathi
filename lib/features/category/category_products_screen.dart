import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saathi/common/widgets/empty_state.dart';
import 'package:saathi/common/widgets/loading_shimmer.dart';
import 'package:saathi/common/widgets/product_list_tile.dart';
import 'package:saathi/common/widgets/view_cart_bar.dart';
import 'package:saathi/data/models/category.dart';
import 'package:saathi/data/models/product.dart';
import 'package:saathi/providers/catalog_provider.dart';
import 'package:saathi/util/app_colors.dart';
import 'package:saathi/util/dimensions.dart';
import 'package:saathi/util/styles.dart';

enum _Sort { popular, priceLow, priceHigh, discount }

class CategoryProductsScreen extends StatefulWidget {
  final CategoryModel category;
  const CategoryProductsScreen({super.key, required this.category});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  late Future<List<Product>> _future;
  _Sort _sort = _Sort.popular;

  @override
  void initState() {
    super.initState();
    _future = context.read<CatalogProvider>().productsForCategory(widget.category.id);
  }

  List<Product> _applySort(List<Product> items) {
    final list = [...items];
    switch (_sort) {
      case _Sort.priceLow:
        list.sort((a, b) => a.basePrice.compareTo(b.basePrice));
        break;
      case _Sort.priceHigh:
        list.sort((a, b) => b.basePrice.compareTo(a.basePrice));
        break;
      case _Sort.discount:
        list.sort((a, b) => b.marginPercent.compareTo(a.marginPercent));
        break;
      case _Sort.popular:
        list.sort((a, b) => (b.isPopular ? 1 : 0).compareTo(a.isPopular ? 1 : 0));
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
        actions: [
          PopupMenuButton<_Sort>(
            icon: const Icon(Icons.sort_rounded),
            onSelected: (s) => setState(() => _sort = s),
            itemBuilder: (_) => const [
              PopupMenuItem(value: _Sort.popular, child: Text('Popular')),
              PopupMenuItem(value: _Sort.priceLow, child: Text('Price: Low to High')),
              PopupMenuItem(value: _Sort.priceHigh, child: Text('Price: High to Low')),
              PopupMenuItem(value: _Sort.discount, child: Text('Best Discount')),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: ProductListShimmer(),
            );
          }
          final items = _applySort(snapshot.data!);
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No products yet',
              message: 'Products in this category will appear here soon.',
            );
          }
          return Column(
            children: [
              Container(
                width: double.infinity,
                color: AppColors.primaryLight,
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                child: Text('${items.length} wholesale products available',
                    style: robotoMedium.copyWith(
                        color: AppColors.primary, fontSize: Dimensions.fontSizeSmall)),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: Dimensions.paddingSizeSmall),
                  itemBuilder: (_, i) => ProductListTile(product: items[i]),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const ViewCartBar(),
    );
  }
}
