import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saathi/common/widgets/custom_button.dart';
import 'package:saathi/common/widgets/empty_state.dart';
import 'package:saathi/common/widgets/order_summary_card.dart';
import 'package:saathi/common/widgets/product_image.dart';
import 'package:saathi/common/widgets/quantity_selector.dart';
import 'package:saathi/data/models/cart_item.dart';
import 'package:saathi/helper/price_converter.dart';
import 'package:saathi/helper/route_helper.dart';
import 'package:saathi/providers/cart_provider.dart';
import 'package:saathi/util/app_colors.dart';
import 'package:saathi/util/app_constants.dart';
import 'package:saathi/util/dimensions.dart';
import 'package:saathi/util/styles.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: () => cart.clear(),
              child: Text('Clear', style: robotoMedium.copyWith(color: AppColors.error)),
            ),
        ],
      ),
      body: cart.isEmpty
          ? EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              message: 'Add wholesale products to start your order.',
              actionText: 'Start Shopping',
              onAction: () => Navigator.pop(context),
            )
          : ListView(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              children: [
                // Free delivery progress
                _DeliveryProgress(subtotal: cart.subtotal),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                ...cart.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                      child: _CartItemTile(item: item),
                    )),

                const SizedBox(height: Dimensions.paddingSizeSmall),
                OrderSummaryCard(
                  subtotal: cart.subtotal,
                  gst: cart.gst,
                  deliveryCharge: cart.deliveryCharge,
                  total: cart.grandTotal,
                  savings: cart.totalSavings,
                ),
                const SizedBox(height: 90),
              ],
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -2))],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Total', style: robotoRegular.copyWith(
                            color: AppColors.textMedium, fontSize: Dimensions.fontSizeSmall)),
                        Text(PriceConverter.format(cart.grandTotal),
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                      ],
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),
                    Expanded(
                      child: CustomButton(
                        text: 'Checkout',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () => Navigator.pushNamed(context, RouteHelper.checkout),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _DeliveryProgress extends StatelessWidget {
  final double subtotal;
  const _DeliveryProgress({required this.subtotal});

  @override
  Widget build(BuildContext context) {
    final threshold = AppConstants.freeDeliveryThreshold;
    final remaining = threshold - subtotal;
    final progress = (subtotal / threshold).clamp(0.0, 1.0);
    final unlocked = remaining <= 0;

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: unlocked ? AppColors.successLight : AppColors.accentLight,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(unlocked ? Icons.check_circle : Icons.local_shipping_outlined,
                  size: 18, color: unlocked ? AppColors.success : AppColors.accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  unlocked
                      ? 'Yay! You unlocked FREE delivery'
                      : 'Add ${PriceConverter.format(remaining)} more for FREE delivery',
                  style: robotoSemiBold.copyWith(
                      color: unlocked ? AppColors.success : AppColors.accent,
                      fontSize: Dimensions.fontSizeSmall),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation(unlocked ? AppColors.success : AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final p = item.product;
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
            child: ProductImage(url: p.image, categoryId: p.categoryId, size: 70),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: robotoSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault, height: 1.2)),
                Text(p.unit, style: robotoRegular.copyWith(
                    color: AppColors.textMedium, fontSize: Dimensions.fontSizeSmall)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('${PriceConverter.format(item.unitPrice)}/unit',
                        style: robotoMedium.copyWith(
                            color: AppColors.primary, fontSize: Dimensions.fontSizeSmall)),
                    if (item.savings > 0) ...[
                      const SizedBox(width: 6),
                      Text('save ${PriceConverter.format(item.savings)}',
                          style: robotoMedium.copyWith(
                              color: AppColors.success, fontSize: Dimensions.fontSizeExtraSmall)),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    QuantitySelector(
                      quantity: item.quantity,
                      onIncrement: () => cart.increment(p.id),
                      onDecrement: () => cart.decrement(p.id),
                    ),
                    Text(PriceConverter.format(item.totalPrice),
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
