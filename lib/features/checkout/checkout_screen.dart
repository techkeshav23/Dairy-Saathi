import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:my_order_pro/common/widgets/custom_button.dart';
import 'package:my_order_pro/common/widgets/order_summary_card.dart';
import 'package:my_order_pro/data/models/order.dart';
import 'package:my_order_pro/data/services/order_service.dart';
import 'package:my_order_pro/helper/price_converter.dart';
import 'package:my_order_pro/helper/route_helper.dart';
import 'package:my_order_pro/providers/auth_provider.dart';
import 'package:my_order_pro/providers/cart_provider.dart';
import 'package:my_order_pro/providers/order_provider.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/dimensions.dart';
import 'package:my_order_pro/util/styles.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  PaymentMode _payment = PaymentMode.cod;
  bool _placing = false;
  File? _paymentScreenshot;
  final ImagePicker _picker = ImagePicker();

  String? _qrImageUrl;
  String? _upiId;

  @override
  void initState() {
    super.initState();
    _loadMerchantQr();
  }

  /// Fetch the distributor's UPI id + QR image (set in the admin Settings) so the
  /// retailer scans the real merchant QR, not a placeholder.
  Future<void> _loadMerchantQr() async {
    try {
      final row = await Supabase.instance.client
          .from('store_settings')
          .select('upi_id, qr_image_url')
          .eq('id', 1)
          .maybeSingle();
      if (!mounted || row == null) return;
      setState(() {
        _upiId = (row['upi_id'] as String?)?.trim();
        _qrImageUrl = (row['qr_image_url'] as String?)?.trim();
      });
    } catch (_) {
      // non-fatal — the QR section falls back to a generic prompt
    }
  }

  Future<void> _pickScreenshot() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _paymentScreenshot = File(image.path);
      });
    }
  }

  Future<void> _placeOrder() async {
    if (_placing) return;

    final cart = context.read<CartProvider>();
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty! Please add items to place an order.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final user = context.read<AuthProvider>().user;
    if (user?.address.isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a valid delivery address before placing an order.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final orders = context.read<OrderProvider>();
    if (_payment == PaymentMode.credit && cart.grandTotal > orders.usableCredit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient credit limit to place this order.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_payment == PaymentMode.qr && _paymentScreenshot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a screenshot of your payment.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _placing = true);

    try {
      String? screenshotUrl;
      if (_payment == PaymentMode.qr && _paymentScreenshot != null) {
        final fileName = 'qr_payment_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await Supabase.instance.client.storage
            .from('payment_screenshots')
            .upload(fileName, _paymentScreenshot!);
        screenshotUrl = Supabase.instance.client.storage
            .from('payment_screenshots')
            .getPublicUrl(fileName);
      }
      final address = user!.address;

      // Map cart items for the order service. Piece/KG lines send pieces (EA); a crate line
      // sends the crate count + unit='crate' so the server prices per crate and removes
      // `qty × ea_per_crate` pieces from stock. See CartItem.toJson().
      final itemsData = cart.items.map((item) => item.toJson()).toList();

      // Call the external OrderService
      final orderId = await OrderService().placeOrder(
        total: cart.grandTotal,
        items: itemsData,
        paymentMode: _payment.name,
        screenshotUrl: screenshotUrl,
      );

      if (orderId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to place order. Please try again.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      await Future.delayed(const Duration(milliseconds: 700)); // simulate API

      // Continue existing local provider logic
      final order = orders.placeOrder(
        id: orderId,
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _placing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final user = context.watch<AuthProvider>().user;
    final address = (user?.address.isNotEmpty ?? false)
        ? user!.address
        : 'No address added. Please add an address.';

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
                  onPressed: _placing ? null : () => Navigator.pushNamed(context, RouteHelper.profile),
                  child: Text('Change', style: robotoMedium.copyWith(
                      color: _placing ? AppColors.textMedium : AppColors.primary)),
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
          _paymentTile(PaymentMode.qr, Icons.qr_code_scanner_rounded, 'Pay via QR Code & upload screenshot'),
          
          if (_payment == PaymentMode.qr)
            Container(
              margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: _boxDeco(context),
              child: Column(
                children: [
                  const Text(
                    'Scan to Pay',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  // Real merchant QR from the distributor's settings (falls back to a
                  // prompt if not configured yet).
                  Container(
                    width: 170,
                    height: 170,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: (_qrImageUrl != null && _qrImageUrl!.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            child: Image.network(_qrImageUrl!, fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => const Center(
                                    child: Icon(Icons.qr_code_2, size: 90, color: Colors.black38)),
                                loadingBuilder: (_, child, progress) => progress == null
                                    ? child
                                    : const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.qr_code_2, size: 70, color: Colors.grey[400]),
                                const SizedBox(height: 6),
                                Text('QR not set up yet',
                                    style: robotoRegular.copyWith(
                                        color: AppColors.textLight, fontSize: Dimensions.fontSizeExtraSmall)),
                              ],
                            ),
                          ),
                  ),
                  if (_upiId != null && _upiId!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text('UPI: $_upiId',
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: AppColors.textDark)),
                  ],
                  const SizedBox(height: 16),
                  if (_paymentScreenshot != null)
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_paymentScreenshot!, height: 100, width: 80, fit: BoxFit.cover),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _paymentScreenshot = null),
                          child: Container(
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    )
                  else
                    CustomButton(
                      text: 'Upload Screenshot',
                      icon: Icons.upload_file,
                      onPressed: _pickScreenshot,
                    ),
                ],
              ),
            ),

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
        child: Text(t, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
      );

  Widget _paymentTile(PaymentMode mode, IconData icon, String subtitle) {
    final isSelected = _payment == mode;
    
    String title = '';
    switch (mode) {
      case PaymentMode.cod:
        title = 'Cash on Delivery';
        break;
      case PaymentMode.online:
        title = 'Pay Online';
        break;
      case PaymentMode.credit:
        title = 'Pay Later (Khata)';
        break;
      case PaymentMode.qr:
        title = 'Pay via QR Code';
        break;
    }

    return GestureDetector(
      onTap: _placing ? null : () => setState(() => _payment = mode),
      child: Container(
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: _boxDeco(context).copyWith(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border.withValues(alpha: 0.6),
            width: isSelected ? 1.5 : 1,
          ),
          color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.3) : Theme.of(context).cardColor,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? Colors.white : AppColors.textMedium, size: 20),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: robotoSemiBold.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: robotoRegular.copyWith(
                      color: AppColors.textMedium, fontSize: Dimensions.fontSizeSmall)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  BoxDecoration _boxDeco(BuildContext context) => BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      );
}