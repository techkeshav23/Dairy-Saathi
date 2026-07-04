import 'package:flutter/material.dart';
import 'package:my_order_pro/common/widgets/custom_button.dart';
import 'package:my_order_pro/data/models/order.dart';
import 'package:my_order_pro/features/dashboard/dashboard_screen.dart';
import 'package:my_order_pro/helper/price_converter.dart';
import 'package:my_order_pro/helper/route_helper.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/dimensions.dart';
import 'package:my_order_pro/util/styles.dart';

class OrderSuccessScreen extends StatefulWidget {
  final OrderModel order;
  const OrderSuccessScreen({super.key, required this.order});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _checkScaleAnimation;
  late Animation<double> _checkFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _buttonSlideAnimation;
  late Animation<double> _buttonFadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _checkScaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
    );
    
    _checkFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    );

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
    ));
    
    _contentFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.7, curve: Curves.easeIn),
    );

    _buttonSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
    ));
    
    _buttonFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            children: [
              const Spacer(),
              FadeTransition(
                opacity: _checkFadeAnimation,
                child: ScaleTransition(
                  scale: _checkScaleAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: AppColors.successLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 84,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),
              FadeTransition(
                opacity: _contentFadeAnimation,
                child: SlideTransition(
                  position: _contentSlideAnimation,
                  child: Column(
                    children: [
                      Text(
                        'Order Placed!',
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Text(
                        'Your wholesale order has been placed successfully and will be confirmed shortly.',
                        textAlign: TextAlign.center,
                        style: robotoRegular.copyWith(
                          color: AppColors.textMedium,
                          height: 1.45,
                        ),
                      ),
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
                            _row('Order ID', '#${widget.order.id}'),
                            const Divider(),
                            _row('Items', '${widget.order.itemCount} units'),
                            const Divider(),
                            _row('Amount', PriceConverter.format(widget.order.total)),
                            const Divider(),
                            _row('Payment', widget.order.paymentMode.label),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              FadeTransition(
                opacity: _buttonFadeAnimation,
                child: SlideTransition(
                  position: _buttonSlideAnimation,
                  child: Column(
                    children: [
                      CustomButton(
                        text: 'Continue Shopping',
                        icon: Icons.shopping_bag_outlined,
                        onPressed: () {
                          Navigator.popUntil(
                            context,
                            (r) => r.settings.name == RouteHelper.dashboard,
                          );
                          DashboardScreen.switchTab(context, 0);
                        },
                      ),
                    ],
                  ),
                ),
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