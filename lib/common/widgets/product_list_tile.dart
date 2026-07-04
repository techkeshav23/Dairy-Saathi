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

/// Ananda "Place Order" product card: image + name, a 3-column MRP/Rate/Resale
/// price row, an EA/CRT unit toggle, a blue Add control, and a Unit/UOM/Total strip.
class ProductListTile extends StatefulWidget {
  final Product product;
  const ProductListTile({super.key, required this.product});

  @override
  State<ProductListTile> createState() => _ProductListTileState();
}

class _ProductListTileState extends State<ProductListTile> {
  bool _crt = true; // CRT (carton) active by default, like the real app

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final cart = context.watch<CartProvider>();
    final qty = cart.quantityOf(p.id);
    final lineTotal = p.priceForQty(qty == 0 ? p.moq : qty) * qty;
    const green = Color(0xFF27AE60);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, RouteHelper.productDetail, arguments: p),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                        child: ProductImage(url: p.image, categoryId: p.categoryId, size: 64),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name.toUpperCase(),
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, height: 1.2)),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            Row(
                              children: [
                                _priceCol('MRP', PriceConverter.formatPrecise(p.mrp), AppColors.textLight, struck: true),
                                _vd(),
                                _priceCol('Rate', PriceConverter.formatPrecise(p.basePrice), AppColors.textDark),
                                _vd(),
                                _priceCol('Resale', PriceConverter.formatPrecise(p.resalePrice), green),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Row(
                    children: [
                      // EA / CRT toggle
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: green),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _seg('EA', !_crt, green),
                            _seg('CRT', _crt, green),
                          ],
                        ),
                      ),
                      const Spacer(),
                      qty == 0
                          ? OutlinedButton(
                              onPressed: p.inStock ? () => cart.add(p) : null,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.link,
                                side: const BorderSide(color: AppColors.link, width: 1.4),
                                padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                              ),
                              child: Text(p.inStock ? 'Add' : 'N/A',
                                  style: robotoBold.copyWith(
                                      color: p.inStock ? AppColors.link : AppColors.textLight,
                                      fontSize: Dimensions.fontSizeDefault)),
                            )
                          : QuantitySelector(
                              quantity: qty,
                              onIncrement: () => cart.increment(p.id),
                              onDecrement: () => cart.decrement(p.id),
                            ),
                    ],
                  ),
                ],
              ),
            ),
            // Unit / UOM / Total strip
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF1F2F4),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(Dimensions.radiusMedium)),
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: Dimensions.paddingSizeSmall),
              child: Row(
                children: [
                  _stripCol('Unit', _crt ? '1 CRT=${p.moq} EA' : '1 EA'),
                  _stripCol('UOM', '-'),
                  _stripCol('Total Amt', PriceConverter.format(lineTotal),
                      valueColor: lineTotal > 0 ? AppColors.textDark : AppColors.textMedium, bold: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _seg(String t, bool active, Color green) => GestureDetector(
        onTap: () => setState(() => _crt = t == 'CRT'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: active ? green : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(t, style: robotoBold.copyWith(
              color: active ? Colors.white : AppColors.textLight, fontSize: Dimensions.fontSizeSmall)),
        ),
      );

  Widget _priceCol(String label, String value, Color color, {bool struck = false}) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: robotoRegular.copyWith(color: AppColors.textLight, fontSize: 10)),
            const SizedBox(height: 1),
            Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: robotoBold.copyWith(
                    color: color, fontSize: Dimensions.fontSizeSmall,
                    decoration: struck ? TextDecoration.lineThrough : null)),
          ],
        ),
      );

  Widget _vd() => Container(width: 1, height: 26, color: const Color(0xFFE0E0E0), margin: const EdgeInsets.symmetric(horizontal: 6));

  Widget _stripCol(String label, String value, {Color valueColor = const Color(0xFF3C3C3C), bool bold = false}) => Expanded(
        child: Column(
          children: [
            Text(label, style: robotoRegular.copyWith(color: const Color(0xFF8A8A8A), fontSize: 10)),
            const SizedBox(height: 1),
            Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: (bold ? robotoBold : robotoMedium).copyWith(color: valueColor, fontSize: Dimensions.fontSizeSmall)),
          ],
        ),
      );
}
