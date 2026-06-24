import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saathi/common/widgets/custom_button.dart';
import 'package:saathi/common/widgets/order_summary_card.dart';
import 'package:saathi/data/models/order.dart';
import 'package:saathi/helper/price_converter.dart';
import 'package:saathi/helper/route_helper.dart';
import 'package:saathi/providers/auth_provider.dart';
import 'package:saathi/providers/cart_provider.dart';
import 'package:saathi/providers/order_provider.dart';
import 'package:saathi/util/app_colors.dart';
import 'package:saathi/util/dimensions.dart';
import 'package:saathi/util/styles.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  PaymentMode _payment = PaymentMode.cod;
  bool _placing = false;

  Future<void> _placeOrder() async {
    setState(() => _placing = true);
    final cart = context.read<CartProvider>();
    final orders = context.read<OrderProvider>();
    final user = context.read<AuthProvider>().user;
    final address = (user?.address.isNotEmpty ?? false)
        ? user!.address
        : '${user?.shopName ?? "My Shop"}, Main Bazaar, India';

    await Future.delayed(const Duration(milliseconds: 700)); // simulate API

    final order = orders.placeOrder(
      cartItems: cart.items,
      subtotal: cart.subtotal,
      gst: cart.gst,
      deliveryCharge: cart.deliveryCharge,
      total: cart.grandTotal,
      savings: cart.totalSavings,
      paymentMode: _payment,
      address: address,
    );
    cart.clear();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteHelper.orderSuccess,
      (r) => r.settings.name == RouteHelper.dashboard,
      arguments: order,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final user = context.watch<AuthProvider>().user;
    final address = (user?.address.isNotEmpty ?? false)
        ? user!.address
        : '${user?.shopName ?? "My Shop"}, Main Bazaar, India';

    return Scaffold(
      appBar: AppBar(title: Text('Checkout', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge))),
      body: ListView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        children: [
          // Delivery address
          _sectionTitle('Delivery Address'),
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: _boxDeco(context),
            child: Row(
              children: [
                const Icon(Icons.storefront_rounded, color: AppColors.primary),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.shopName ?? 'My Shop', style: robotoSemiBold),
                      const SizedBox(height: 2),
                      Text(address, style: robotoRegular.copyWith(
                          color: AppColors.textMedium, fontSize: Dimensions.fontSizeSmall)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, RouteHelper.profile),
                  child: Text('Change', style: robotoMedium.copyWith(color: AppColors.primary)),
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // Payment mode
          _sectionTitle('Payment Method'),
          _paymentTile(PaymentMode.cod, Icons.payments_outlined, 'Pay cash when stock is delivered'),
          _paymentTile(PaymentMode.online, Icons.account_balance_outlined, 'UPI, cards, net-banking'),
          _paymentTile(PaymentMode.credit, Icons.account_balance_wallet_outlined, 'Add to khata, settle in 15 days'),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          _sectionTitle('Order Summary'),
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
      bottomNavigationBar: Container(
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
                  Text('To Pay', style: robotoRegular.copyWith(
                      color: AppColors.textMedium, fontSize: Dimensions.fontSizeSmall)),
                  Text(PriceConverter.format(cart.grandTotal),
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                ],
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: CustomButton(
                  text: 'Place Order',
                  isLoading: _placing,
                  onPressed: _placeOrder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        child: Text(t, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
      );

  BoxDecoration _boxDeco(BuildContext context) => BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      );

  Widget _paymentTile(PaymentMode mode, IconData icon, String subtitle) {
    final selected = _payment == mode;
    return GestureDetector(
      onTap: () => setState(() => _payment = mode),
      child: Container(
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border.withValues(alpha: 0.6),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.primary : AppColors.textMedium),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mode.label, style: robotoSemiBold.copyWith(
                      color: selected ? AppColors.primary : AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: robotoRegular.copyWith(
                      color: AppColors.textMedium, fontSize: Dimensions.fontSizeSmall)),
                ],
              ),
            ),
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.primary : AppColors.textLight, size: 20),
          ],
        ),
      ),
    );
  }
}
