import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_order_pro/common/widgets/product_image.dart';
import 'package:my_order_pro/common/widgets/quantity_selector.dart';
import 'package:my_order_pro/data/models/product.dart';
import 'package:my_order_pro/helper/price_converter.dart';
import 'package:my_order_pro/helper/route_helper.dart';
import 'package:my_order_pro/providers/cart_provider.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/dimensions.dart';
import 'package:my_order_pro/util/styles.dart';

/// Vertical catalog card for grids and horizontal rails.
/// Follows the SixamMart grid card: white, radius 15, subtle, with a rectangular
/// discount tag, struck MRP, and a white-circle "+" add control.
class ProductCard extends StatelessWidget {
  final Product product;
  final double width;

  const ProductCard({super.key, required this.product, this.width = double.infinity});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final qty = cart.quantityOf(product.id);
    final discount = product.marginPercent.round();

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, RouteHelper.productDetail, arguments: product),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ProductImage(
                      url: product.image,
                      categoryId: product.categoryId,
                      size: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (discount > 0)
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.discount,
                        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                      ),
                      child: Text('$discount% OFF',
                          style: robotoMedium.copyWith(color: Colors.white, fontSize: 9)),
                    ),
                  ),
                if (!product.inStock)
                  Positioned(
                    left: 0, right: 0, bottom: 0,
                    child: Container(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Text('OUT OF STOCK',
                          textAlign: TextAlign.center,
                          style: robotoMedium.copyWith(color: Colors.white, fontSize: 10)),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.brand.toUpperCase(),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: robotoRegular.copyWith(
                          color: AppColors.textLight, fontSize: 9, letterSpacing: 0.3)),
                  const SizedBox(height: 2),
                  Text(product.name,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, height: 1.2)),
                  const SizedBox(height: 3),
                  Text(product.unit,
                      style: robotoRegular.copyWith(
                          color: AppColors.textLight, fontSize: Dimensions.fontSizeExtraSmall)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  // Price row: struck MRP then current
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(PriceConverter.format(product.basePrice),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: robotoBold.copyWith(
                                color: AppColors.textDark, fontSize: Dimensions.fontSizeDefault)),
                      ),
                      const SizedBox(width: 4),
                      if (product.mrp > product.basePrice)
                        Flexible(
                          child: Text(PriceConverter.format(product.mrp),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: robotoMedium.copyWith(
                                color: AppColors.textLight,
                                fontSize: Dimensions.fontSizeExtraSmall,
                                decoration: TextDecoration.lineThrough,
                              )),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text('MOQ ${product.moq}',
                            style: robotoMedium.copyWith(
                                color: AppColors.textMedium, fontSize: 9)),
                      ),
                      qty == 0
                          ? AddCircleButton(
                              onTap: product.inStock ? () => cart.add(product) : null,
                              size: 30,
                            )
                          : QuantitySelector(
                              quantity: qty,
                              onIncrement: () => cart.increment(product.id),
                              onDecrement: () => cart.decrement(product.id),
                            ),
                    ],
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

class AddCircleButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double size;

  const AddCircleButton({super.key, required this.onTap, this.size = 30});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onTap != null ? AppColors.primary : Colors.grey,
        ),
        child: Icon(Icons.add, color: Colors.white, size: size * 0.6),
      ),
    );
  }
}