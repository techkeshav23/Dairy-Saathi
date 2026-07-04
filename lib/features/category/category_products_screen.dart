import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_order_pro/common/widgets/empty_state.dart';
import 'package:my_order_pro/common/widgets/loading_shimmer.dart';
import 'package:my_order_pro/common/widgets/product_list_tile.dart';
import 'package:my_order_pro/common/widgets/view_cart_bar.dart';
import 'package:my_order_pro/data/models/category.dart';
import 'package:my_order_pro/data/models/product.dart';
import 'package:my_order_pro/providers/catalog_provider.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/dimensions.dart';
import 'package:my_order_pro/util/styles.dart';

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
    _loadData();
  }

  void _loadData() {
    setState(() {
      _future = context.read<CatalogProvider>().productsForCategory(widget.category.id);
    });
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
        list.sort((a, b) {
          if (a.isPopular && !b.isPopular) return -1;
          if (!a.isPopular && b.isPopular) return 1;
          return 0;
        });
        break;
    }
    return list;
  }

  String _getSortLabel(_Sort sort) {
    switch (sort) {
      case _Sort.popular: return 'Popular';
      case _Sort.priceLow: return 'Price: Low to High';
      case _Sort.priceHigh: return 'Price: High to Low';
      case _Sort.discount: return 'Best Discount';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.category.name, style: robotoBold.copyWith(color: AppColors.textDark, fontSize: Dimensions.fontSizeLarge)),
            Text('Category', style: robotoRegular.copyWith(color: AppColors.textMedium, fontSize: Dimensions.fontSizeSmall)),
          ],
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark),
        actions: [
          PopupMenuButton<_Sort>(
            icon: const Icon(Icons.sort_rounded, color: AppColors.textDark),
            tooltip: 'Sort Products',
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
            onSelected: (s) => setState(() => _sort = s),
            itemBuilder: (_) => _Sort.values.map((sort) {
              return PopupMenuItem(
                value: sort,
                child: Row(
                  children: [
                    Icon(
                      _sort == sort ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: _sort == sort ? AppColors.primary : AppColors.textLight,
                      size: 20,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Text(_getSortLabel(sort), style: robotoMedium.copyWith(
                      color: _sort == sort ? AppColors.primary : AppColors.textDark,
                    )),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        color: AppColors.primary,
        child: FutureBuilder<List<Product>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: ProductListShimmer(),
              );
            }
            if (snapshot.hasError) {
              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          Text('Failed to load products', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          ElevatedButton(
                            onPressed: _loadData,
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                            child: const Text('Retry', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            final items = _applySort(snapshot.data ?? []);
            if (items.isEmpty) {
              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: const EmptyState(
                      icon: Icons.inventory_2_outlined,
                      title: 'No products yet',
                      message: 'Products in this category will appear here soon.',
                    ),
                  ),
                ],
              );
            }
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  color: AppColors.primaryLight.withValues(alpha: 0.3),
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${items.length} wholesale products',
                          style: robotoMedium.copyWith(
                              color: AppColors.primary, fontSize: Dimensions.fontSizeSmall)),
                      Row(
                        children: [
                          const Icon(Icons.sort, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(_getSortLabel(_sort),
                              style: robotoMedium.copyWith(
                                  color: AppColors.primary, fontSize: Dimensions.fontSizeSmall)),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
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
      ),
      bottomNavigationBar: const ViewCartBar(),
    );
  }
}