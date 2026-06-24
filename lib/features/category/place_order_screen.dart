import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saathi/common/widgets/empty_state.dart';
import 'package:saathi/common/widgets/loading_shimmer.dart';
import 'package:saathi/common/widgets/product_list_tile.dart';
import 'package:saathi/common/widgets/view_cart_bar.dart';
import 'package:saathi/data/mock_data.dart';
import 'package:saathi/data/models/category.dart';
import 'package:saathi/data/models/product.dart';
import 'package:saathi/helper/route_helper.dart';
import 'package:saathi/providers/catalog_provider.dart';
import 'package:saathi/util/app_colors.dart';
import 'package:saathi/util/dimensions.dart';
import 'package:saathi/util/styles.dart';

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
      final catalog = context.read<CatalogProvider>();
      if (catalog.categories.isEmpty) {
        catalog.loadHome().then((_) => _selectFirst());
      } else {
        _selectFirst();
      }
    });
  }

  void _selectFirst() {
    final cats = context.read<CatalogProvider>().categories;
    if (cats.isNotEmpty) _select(cats.first);
  }

  void _select(CategoryModel c) {
    setState(() {
      _selectedId = c.id;
      _future = context.read<CatalogProvider>().productsForCategory(c.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CatalogProvider>().categories;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('Place Order', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, RouteHelper.search),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Left category rail
                Container(
                  width: 86,
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
                      // "Choose Type" dropdown
                      Padding(
                        padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeSmall,
                            Dimensions.paddingSizeSmall, Dimensions.paddingSizeSmall, 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Choose Type', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                              const SizedBox(width: 6),
                              const Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.textDark),
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
                                  if (!snap.hasData) {
                                    return const Padding(
                                      padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                                      child: ProductListShimmer(),
                                    );
                                  }
                                  final items = snap.data!;
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
      child: Container(
        color: selected ? Theme.of(context).cardColor : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        child: Row(
          children: [
            Container(
              width: 3, height: 56,
              color: selected ? AppColors.primary : Colors.transparent,
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: 50, height: 50,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Image.asset(
                      MockData.categoryImage(category.id),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: AppColors.primaryLight,
                        child: Icon(category.icon, color: AppColors.primary, size: 22),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(category.name,
                      maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,
                      style: (selected ? robotoBold : robotoRegular).copyWith(
                          fontSize: 9,
                          color: selected ? AppColors.primary : AppColors.textMedium,
                          height: 1.05)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
