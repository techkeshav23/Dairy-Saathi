import 'package:flutter/material.dart';
import 'package:saathi/common/widgets/custom_button.dart';
import 'package:saathi/data/models/order.dart';
import 'package:saathi/features/dashboard/dashboard_screen.dart';
import 'package:saathi/helper/price_converter.dart';
import 'package:saathi/helper/route_helper.dart';
import 'package:saathi/util/app_colors.dart';
import 'package:saathi/util/dimensions.dart';
import 'package:saathi/util/styles.dart';

class OrderSuccessScreen extends StatelessWidget {
  final OrderModel order;
  const OrderSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            children: [
              const Spacer(),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                builder: (_, v, child) => Transform.scale(scale: v, child: child),
                child: Container(
                  width: 120, height: 120,
                  decoration: const BoxDecoration(color: AppColors.successLight, shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 84),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),
              Text('Order Placed!', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge)),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text('Your wholesale order has been placed successfully and will be confirmed shortly.',
                  textAlign: TextAlign.center,
                  style: robotoRegular.copyWith(color: AppColors.textMedium, height: 1.45)),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _row('Order ID', '#${order.id}'),
                    const Divider(),
                    _row('Items', '${order.itemCount} units'),
                    const Divider(),
                    _row('Amount', PriceConverter.format(order.total)),
                    const Divider(),
                    _row('Payment', order.paymentMode.label),
                  ],
                ),
              ),
              const Spacer(),
              CustomButton(
                text: 'Track Order',
                icon: Icons.local_shipping_outlined,
                onPressed: () => Navigator.pushReplacementNamed(
                    context, RouteHelper.orderDetail, arguments: order),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              CustomButton(
                text: 'Continue Shopping',
                outlined: true,
                onPressed: () {
                  Navigator.popUntil(context, (r) => r.settings.name == RouteHelper.dashboard);
                  DashboardScreen.switchTab(context, 0);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
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
