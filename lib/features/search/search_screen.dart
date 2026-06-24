import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saathi/common/widgets/empty_state.dart';
import 'package:saathi/common/widgets/loading_shimmer.dart';
import 'package:saathi/common/widgets/product_list_tile.dart';
import 'package:saathi/common/widgets/view_cart_bar.dart';
import 'package:saathi/data/models/product.dart';
import 'package:saathi/providers/catalog_provider.dart';
import 'package:saathi/util/app_colors.dart';
import 'package:saathi/util/dimensions.dart';
import 'package:saathi/util/styles.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<Product>? _results;
  bool _loading = false;

  static const _suggestions = ['Rice', 'Atta', 'Oil', 'Maggi', 'Tea', 'Soap', 'Detergent', 'Biscuits'];

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) {
      setState(() => _results = null);
      return;
    }
    setState(() => _loading = true);
    final res = await context.read<CatalogProvider>().search(q);
    if (!mounted) return;
    setState(() {
      _results = res;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Container(
          height: 42,
          margin: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.textLight, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onChanged: _search,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                  decoration: InputDecoration(
                    hintText: 'Search products, brands...',
                    hintStyle: robotoRegular.copyWith(color: AppColors.textLight),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (_controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _controller.clear();
                    _search('');
                  },
                  child: const Icon(Icons.close, color: AppColors.textLight, size: 18),
                ),
            ],
          ),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: const ViewCartBar(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: ProductListShimmer(),
      );
    }
    if (_results == null) {
      return Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Popular searches', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Wrap(
              spacing: Dimensions.paddingSizeSmall,
              runSpacing: Dimensions.paddingSizeSmall,
              children: _suggestions.map((s) => ActionChip(
                label: Text(s),
                labelStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                backgroundColor: AppColors.primaryLight,
                side: BorderSide.none,
                onPressed: () {
                  _controller.text = s;
                  _search(s);
                },
              )).toList(),
            ),
          ],
        ),
      );
    }
    if (_results!.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No results found',
        message: 'Try a different product name or brand.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      itemCount: _results!.length,
      separatorBuilder: (_, _) => const SizedBox(height: Dimensions.paddingSizeSmall),
      itemBuilder: (_, i) => ProductListTile(product: _results![i]),
    );
  }
}
