import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_order_pro/common/widgets/custom_button.dart';
import 'package:my_order_pro/common/widgets/product_image.dart';
import 'package:my_order_pro/common/widgets/quantity_selector.dart';
import 'package:my_order_pro/data/models/product.dart';
import 'package:my_order_pro/helper/price_converter.dart';
import 'package:my_order_pro/providers/cart_provider.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/dimensions.dart';
import 'package:my_order_pro/util/styles.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final qtyInCart = cart.quantityOf(product.id);
    final effectiveQty = qtyInCart > 0 ? qtyInCart : product.moq;
    final unitPrice = product.priceForQty(effectiveQty);
    final discount = product.marginPercent.round();
    final marginPerUnit = product.mrp - product.basePrice;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.brand, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Hero image
          Container(
            color: Colors.white,
            height: 280,
            width: double.infinity,
            child: ProductImage(
                url: product.image, categoryId: product.categoryId, size: 280, fit: BoxFit.cover),
          ),

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.brand.toUpperCase(),
                    style: robotoMedium.copyWith(
                        color: AppColors.textLight, fontSize: Dimensions.fontSizeSmall, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(product.name,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge, height: 1.25)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 16, color: AppColors.textMedium),
                    const SizedBox(width: 4),
                    Text(product.unit, style: robotoRegular.copyWith(color: AppColors.textMedium)),
                    const SizedBox(width: Dimensions.paddingSizeDefault),
                    _stockChip(product.inStock, product.stock),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                // Price block
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(PriceConverter.format(product.basePrice),
                        style: robotoBlack.copyWith(
                            fontSize: Dimensions.fontSizeOverLarge, color: AppColors.textDark)),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(PriceConverter.format(product.mrp),
                          style: robotoRegular.copyWith(
                            color: AppColors.textLight,
                            fontSize: Dimensions.fontSizeLarge,
                            decoration: TextDecoration.lineThrough,
                          )),
                    ),
                    const SizedBox(width: 8),
                    if (discount > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                          child: Text('$discount% OFF MRP',
                              style: robotoBold.copyWith(
                                  color: AppColors.success, fontSize: Dimensions.fontSizeSmall)),
                        ),
                      ),
                  ],
                ),
                Text('Price shown is per unit (excl. GST)',
                    style: robotoRegular.copyWith(
                        color: AppColors.textLight, fontSize: Dimensions.fontSizeExtraSmall)),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                // Bulk pricing slabs — the wholesale highlight
                _SlabTable(product: product, effectiveQty: effectiveQty),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                // Margin calculator
                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.savings_outlined, color: AppColors.success),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Your margin on resale',
                                style: robotoMedium.copyWith(
                                    color: AppColors.success, fontSize: Dimensions.fontSizeSmall)),
                            const SizedBox(height: 2),
                            Text('Earn ${PriceConverter.format(marginPerUnit)} per unit selling at MRP',
                                style: robotoBold.copyWith(
                                    color: AppColors.textDark, fontSize: Dimensions.fontSizeDefault)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                // Description
                if (product.description.isNotEmpty) ...[
                  Text('Product Details', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Text(product.description,
                      style: robotoRegular.copyWith(color: AppColors.textMedium, height: 1.5)),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                ],

                _infoRow('Minimum Order Qty', '${product.moq} units'),
                _infoRow('Pack / Unit', product.unit),
                _infoRow('In Stock', '${product.stock} units'),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),

      // Sticky bottom add-to-cart bar
      bottomNavigationBar: _BottomBar(
        product: product, qtyInCart: qtyInCart, unitPrice: unitPrice),
    );
  }

  Widget _stockChip(bool inStock, int stock) {
    final color = inStock ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(inStock ? Icons.check_circle : Icons.cancel, size: 13, color: color),
          const SizedBox(width: 4),
          Text(inStock ? 'In Stock' : 'Out of Stock',
              style: robotoMedium.copyWith(color: color, fontSize: Dimensions.fontSizeExtraSmall)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: robotoRegular.copyWith(color: AppColors.textMedium)),
            Text(value, style: robotoSemiBold),
          ],
        ),
      );
}

class _SlabTable extends StatelessWidget {
  final Product product;
  final int effectiveQty;
  const _SlabTable({required this.product, required this.effectiveQty});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.radiusDefault)),
            ),
            child: Row(
              children: [
                const Icon(Icons.trending_down_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text('Bulk Pricing — buy more, save more',
                    style: robotoBold.copyWith(
                        color: AppColors.primary, fontSize: Dimensions.fontSizeDefault)),
              ],
            ),
          ),
          ...List.generate(product.slabs.length, (i) {
            final slab = product.slabs[i];
            final next = i + 1 < product.slabs.length ? product.slabs[i + 1] : null;
            final range = next != null ? '${slab.minQty}–${next.minQty - 1} units' : '${slab.minQty}+ units';
            final isActive = effectiveQty >= slab.minQty &&
                (next == null || effectiveQty < next.minQty);
            return Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary.withValues(alpha: 0.06) : null,
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  Icon(isActive ? Icons.radio_button_checked : Icons.radio_button_off,
                      size: 16, color: isActive ? AppColors.primary : AppColors.textLight),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Text(range, style: (isActive ? robotoSemiBold : robotoRegular)
                        .copyWith(fontSize: Dimensions.fontSizeDefault)),
                  ),
                  Text('${PriceConverter.format(slab.pricePerUnit)}/unit',
                      style: robotoBold.copyWith(
                          color: isActive ? AppColors.primary : AppColors.textDark,
                          fontSize: Dimensions.fontSizeDefault)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final Product product;
  final int qtyInCart;
  final double unitPrice;
  const _BottomBar({required this.product, required this.qtyInCart, required this.unitPrice});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Container(
      padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall,
          Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: qtyInCart == 0
            ? CustomButton(
                text: product.inStock ? 'Add to Cart' : 'Out of Stock',
                icon: product.inStock ? Icons.add_shopping_cart : null,
                onPressed: product.inStock ? () => cart.add(product) : null,
              )
            : Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Subtotal', style: robotoRegular.copyWith(
                          color: AppColors.textMedium, fontSize: Dimensions.fontSizeSmall)),
                      Text(PriceConverter.format(unitPrice * qtyInCart),
                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                    ],
                  ),
                  const Spacer(),
                  QuantitySelector(
                    quantity: qtyInCart,
                    compact: false,
                    onIncrement: () => cart.increment(product.id),
                    onDecrement: () => cart.decrement(product.id),
                  ),
                ],
              ),
      ),
    );
  }
}
