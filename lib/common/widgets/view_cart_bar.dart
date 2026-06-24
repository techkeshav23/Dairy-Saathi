import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saathi/helper/price_converter.dart';
import 'package:saathi/helper/route_helper.dart';
import 'package:saathi/providers/cart_provider.dart';
import 'package:saathi/util/app_colors.dart';
import 'package:saathi/util/dimensions.dart';
import 'package:saathi/util/styles.dart';

/// Sticky "X items · ₹total — Proceed to cart" bar shown above the bottom edge
/// on catalog screens whenever the cart is non-empty.
class ViewCartBar extends StatelessWidget {
  const ViewCartBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    if (cart.isEmpty) return const SizedBox.shrink();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, RouteHelper.cart),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${cart.totalUnits} items · ${cart.distinctCount} products',
                        style: robotoMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.9), fontSize: 11)),
                    Text(PriceConverter.format(cart.subtotal),
                        style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge)),
                  ],
                ),
                const Spacer(),
                Text('Proceed to cart', style: robotoBold.copyWith(color: Colors.white)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
