import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_order_pro/common/widgets/empty_state.dart';
import 'package:my_order_pro/common/widgets/loading_shimmer.dart';
import 'package:my_order_pro/common/widgets/product_list_tile.dart';
import 'package:my_order_pro/common/widgets/view_cart_bar.dart';
import 'package:my_order_pro/data/mock_data.dart';
import 'package:my_order_pro/data/models/category.dart';
import 'package:my_order_pro/data/models/product.dart';
import 'package:my_order_pro/helper/route_helper.dart';
import 'package:my_order_pro/providers/catalog_provider.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/dimensions.dart';
import 'package:my_order_pro/util/styles.dart';

/// The catalog/ordering screen — left vertical category rail + right product
/// list, modelled on the Ananda "Place Order" screen.
class PlaceOrderScreen extends StatefulWidget {
  const PlaceOrderScreen({super.key});

  @override
  State<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  String? _selectedId;
  Future<List<Product>>? _future;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final catalog = context.read<CatalogProvider>();
      if (catalog.categories.isEmpty) {
        catalog.loadHome().then((_) {
          if (mounted) _selectFirst();
        });
      } else {
        _selectFirst();
      }
    });
  }

  void _selectFirst() {
    if (!mounted) return;
    final cats = context.read<CatalogProvider>().categories;
    if (cats.isNotEmpty) _select(cats.first);
  }

  void _select(CategoryModel c) {
    if (!mounted) return;
    setState(() {
      _selectedId = c.id;
      _future = context.read<CatalogProvider>().productsForCategory(c.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final categories = catalog.categories;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: AppColors.card,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: Text('Place Order', style: robotoBold.copyWith(color: AppColors.textDark, fontSize: Dimensions.fontSizeLarge)),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, RouteHelper.search),
            icon: const Icon(Icons.search, color: AppColors.textDark),
            tooltip: 'Search Products',
          ),
        ],
      ),
      body: catalog.isLoading && categories.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : categories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.category_outlined, size: 64, color: AppColors.textLight.withValues(alpha: 0.5)),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      Text('No categories found', style: robotoMedium.copyWith(color: AppColors.textMedium, fontSize: Dimensions.fontSizeLarge)),
                    ],
                  ),
                )
              : Row(
                  children: [
                    // Left category rail
                    Container(
                      width: 90,
                      color: AppColors.surface,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                        itemCount: categories.length,
                        itemBuilder: (_, i) => _RailItem(
                          category: categories[i],
                          selected: categories[i].id == _selectedId,
                          onTap: () => _select(categories[i]),
                        ),
                      ),
                    ),
                    // Right product list
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // "Choose Type" dropdown (Mocked UI)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeSmall,
                                Dimensions.paddingSizeSmall, Dimensions.paddingSizeSmall, 0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Choose Type', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: AppColors.textDark)),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.textDark),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: _future == null
                                ? const SizedBox.shrink()
                                : FutureBuilder<List<Product>>(
                                    future: _future,
                                    builder: (context, snap) {
                                      if (snap.connectionState == ConnectionState.waiting) {
                                        return const Padding(
                                          padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                                          child: ProductListShimmer(),
                                        );
                                      }
                                      if (snap.hasError) {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                                              const SizedBox(height: Dimensions.paddingSizeSmall),
                                              Text('Error loading products', style: robotoMedium.copyWith(color: AppColors.error)),
                                              TextButton(
                                                onPressed: () {
                                                  if (_selectedId != null) {
                                                    final cat = categories.firstWhere((c) => c.id == _selectedId);
                                                    _select(cat);
                                                  }
                                                },
                                                child: const Text('Retry'),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      final items = snap.data ?? [];
                                      if (items.isEmpty) {
                                        return const EmptyState(
                                          icon: Icons.inventory_2_outlined,
                                          title: 'No products',
                                          message: 'Products will appear here soon.',
                                        );
                                      }
                                      return ListView.separated(
                                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                        itemCount: items.length,
                                        separatorBuilder: (_, _) => const SizedBox(height: Dimensions.paddingSizeSmall),
                                        itemBuilder: (_, i) => ProductListTile(product: items[i]),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: const ViewCartBar(),
    );
  }
}

class _RailItem extends StatelessWidget {
  final CategoryModel category;
  final bool selected;
  final VoidCallback onTap;
  const _RailItem({required this.category, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: selected ? AppColors.background : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        child: Row(
          children: [
            Container(
              width: 4, 
              height: 56,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50, height: 50,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.card,
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                        width: selected ? 2 : 1,
                      ),
                      boxShadow: selected ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ] : null,
                    ),
                    child: Image.asset(
                      MockData.categoryImage(category.id),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: selected ? AppColors.primaryLight.withValues(alpha: 0.3) : AppColors.surface,
                        child: Icon(category.icon, color: selected ? AppColors.primary : AppColors.textLight, size: 24),
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      category.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: selected 
                          ? robotoBold.copyWith(fontSize: 10, color: AppColors.primary)
                          : robotoRegular.copyWith(fontSize: 10, color: AppColors.textMedium),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}