import 'package:flutter/material.dart';
import 'package:my_order_pro/helper/price_converter.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/app_constants.dart';
import 'package:my_order_pro/util/dimensions.dart';
import 'package:my_order_pro/util/styles.dart';

/// Bill breakdown card reused on cart, checkout and order detail.
class OrderSummaryCard extends StatelessWidget {
  final double subtotal;
  final double gst;
  final double deliveryCharge;
  final double total;
  final double savings;

  const OrderSummaryCard({
    super.key,
    required this.subtotal,
    required this.gst,
    required this.deliveryCharge,
    required this.total,
    required this.savings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('Bill Details', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          _row('Item Total', PriceConverter.format(subtotal)),
          _row('GST (${AppConstants.gstPercent.toStringAsFixed(0)}%)', PriceConverter.format(gst)),
          _row('Delivery Charge',
              deliveryCharge == 0 ? 'FREE' : PriceConverter.format(deliveryCharge),
              valueColor: deliveryCharge == 0 ? AppColors.success : null),
          const Divider(height: Dimensions.paddingSizeLarge),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('To Pay', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              Text(PriceConverter.format(total),
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: AppColors.primary)),
            ],
          ),
          if (savings > 0) ...[
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
              child: Text('🎉 You save ${PriceConverter.format(savings)} vs MRP on this order',
                  textAlign: TextAlign.center,
                  style: robotoSemiBold.copyWith(
                      color: AppColors.success, fontSize: Dimensions.fontSizeSmall)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: robotoRegular.copyWith(color: AppColors.textMedium)),
            Text(value, style: robotoSemiBold.copyWith(color: valueColor)),
          ],
        ),
      );
}
