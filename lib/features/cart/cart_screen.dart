import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_order_pro/common/widgets/custom_button.dart';
import 'package:my_order_pro/common/widgets/empty_state.dart';
import 'package:my_order_pro/common/widgets/order_summary_card.dart';
import 'package:my_order_pro/common/widgets/product_image.dart';
import 'package:my_order_pro/common/widgets/quantity_selector.dart';
import 'package:my_order_pro/data/models/cart_item.dart';
import 'package:my_order_pro/helper/price_converter.dart';
import 'package:my_order_pro/helper/route_helper.dart';
import 'package:my_order_pro/providers/auth_provider.dart';
import 'package:my_order_pro/providers/cart_provider.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/dimensions.dart';
import 'package:my_order_pro/util/styles.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Distributor (Bill From / Ship From) details + the order window, from store_settings.
  String _billFromName = '';
  String _billFromAddress = '';
  String _billFromGst = '';
  String _shipFrom = '';
  String _openTime = '';
  String _cutoffTime = '';

  @override
  void initState() {
    super.initState();
    _loadStore();
  }

  Future<void> _loadStore() async {
    try {
      final row = await Supabase.instance.client
          .from('store_settings')
          .select('business_name, address, gstin, ship_from_address, order_open_time, order_cutoff_time')
          .eq('id', 1)
          .maybeSingle();
      if (!mounted || row == null) return;
      setState(() {
        _billFromName = (row['business_name'] ?? '').toString();
        _billFromAddress = (row['address'] ?? '').toString();
        _billFromGst = (row['gstin'] ?? '').toString();
        _shipFrom = (row['ship_from_address'] ?? '').toString();
        _openTime = (row['order_open_time'] ?? '').toString();
        _cutoffTime = (row['order_cutoff_time'] ?? '').toString();
      });
    } catch (_) {/* non-fatal */}
  }

  int? _minutes(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }

  /// True when the current time is outside the distributor's ordering window.
  bool get _orderClosed {
    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;
    final open = _minutes(_openTime);
    final cut = _minutes(_cutoffTime);
    if (open != null && nowMin < open) return true;
    if (cut != null && nowMin > cut) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final closed = _orderClosed;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Cart', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
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
                _sectionStrip('Item Summary (${cart.distinctCount})'),
                const SizedBox(height: Dimensions.paddingSizeSmall),
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
                const SizedBox(height: Dimensions.paddingSizeDefault),

                _partyCard(
                  section: 'Bill From',
                  name: _billFromName.isNotEmpty ? _billFromName : 'Your Distributor',
                  address: _billFromAddress,
                  tag: 'Distributor',
                  idLine: _billFromGst.isNotEmpty ? 'GST  :  $_billFromGst' : '',
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                _billToCard(context),
                if (_shipFrom.isNotEmpty) ...[
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  _partyCard(section: 'Ship From', name: _billFromName, address: _shipFrom, tag: 'Plant', idLine: ''),
                ],
                const SizedBox(height: 100),
              ],
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (closed)
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFFDECEA),
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_off_outlined, color: Color(0xFFD23B3B), size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Order taking time is over. You can't proceed now.",
                                  style: robotoBold.copyWith(color: const Color(0xFFD23B3B), fontSize: Dimensions.fontSizeSmall)),
                              if (_cutoffTime.isNotEmpty)
                                Text('CLOSED AT - $_cutoffTime',
                                    style: robotoRegular.copyWith(color: const Color(0xFF8A8A8A), fontSize: Dimensions.fontSizeExtraSmall)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
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
                            Text('${cart.distinctCount} Items', style: robotoRegular.copyWith(
                                color: AppColors.textMedium, fontSize: Dimensions.fontSizeSmall)),
                            Text(PriceConverter.format(cart.grandTotal),
                                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                          ],
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),
                        Expanded(
                          child: Opacity(
                            opacity: closed ? 0.55 : 1,
                            child: CustomButton(
                              text: closed ? 'Order Closed' : 'Proceed',
                              icon: closed ? Icons.lock_outline : Icons.arrow_forward_rounded,
                              onPressed: closed
                                  ? () {}
                                  : () => Navigator.pushNamed(context, RouteHelper.checkout),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _sectionStrip(String t) => Text(t, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge));

  Widget _partyCard({
    required String section,
    required String name,
    required String address,
    required String tag,
    required String idLine,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
            ),
            child: Text(section, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
          ),
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (name.isNotEmpty)
                  Text(name, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                if (address.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(address, style: robotoRegular.copyWith(
                      color: const Color(0xFF555B61), fontSize: Dimensions.fontSizeSmall, height: 1.35)),
                ],
                const SizedBox(height: 6),
                Text(tag, style: robotoBold.copyWith(color: AppColors.link, fontSize: Dimensions.fontSizeSmall)),
                if (idLine.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(idLine, style: robotoMedium.copyWith(
                      color: const Color(0xFF333A3D), fontSize: Dimensions.fontSizeSmall)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _billToCard(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    final addressParts = [
      if ((user?.address ?? '').isNotEmpty) user!.address,
      if ((user?.area ?? '').isNotEmpty) user!.area,
    ];
    return _partyCard(
      section: 'Bill To',
      name: (user?.shopName.isNotEmpty ?? false) ? user!.shopName : 'Your Shop',
      address: addressParts.join(', '),
      tag: user?.typeLabel ?? 'Retailer',
      idLine: user?.idLabel ?? '',
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  const _CartItemTile({required this.item});

  double _perUnit(double perEa) =>
      item.unit == 'kg' && item.product.eaPerKg > 0 ? perEa * item.product.eaPerKg : perEa;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final p = item.product;
    final mrp = _perUnit(p.mrp);
    final rate = item.displayUnitPrice;
    final resale = _perUnit(p.resalePrice);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          // Header: image + name + price columns
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Row(
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
                      Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, height: 1.2)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _priceCol('MRP', mrp, strike: true, color: AppColors.textLight),
                          _priceCol('Rate', rate, color: AppColors.textDark),
                          _priceCol('Resale', resale, color: AppColors.success),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3C9C9)),
          // Controls: EA/KG toggle + qty
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (p.hasKg)
                  _unitToggle(cart, p.id)
                else
                  const SizedBox.shrink(),
                QuantitySelector(
                  quantity: item.quantity,
                  onIncrement: () => cart.increment(p.id),
                  onDecrement: () => cart.decrement(p.id),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3C9C9)),
          // Footer: unit conversion / UOM / total
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 10),
            child: Row(
              children: [
                _footCol('Unit', p.hasKg ? '1 KG = ${p.eaPerKg.toStringAsFixed(1)} EA' : (p.unit.isEmpty ? '1 EA' : p.unit)),
                _footCol('UOM', item.uomLabel, color: AppColors.success),
                _footCol('Total Amt', PriceConverter.format(item.totalPrice), bold: true, alignEnd: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceCol(String label, double value, {bool strike = false, required Color color}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: robotoRegular.copyWith(color: AppColors.textLight, fontSize: Dimensions.fontSizeExtraSmall)),
          const SizedBox(height: 2),
          Text(PriceConverter.format(value),
              style: robotoBold.copyWith(
                  color: color, fontSize: Dimensions.fontSizeSmall,
                  decoration: strike ? TextDecoration.lineThrough : null)),
        ],
      ),
    );
  }

  Widget _unitToggle(CartProvider cart, String pid) {
    Widget seg(String label, String value) {
      final selected = item.unit == value;
      return GestureDetector(
        onTap: () => cart.setUnit(pid, value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.success : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(label, style: robotoBold.copyWith(
              color: selected ? Colors.white : AppColors.textMedium, fontSize: Dimensions.fontSizeSmall)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.success),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [seg('EA', 'ea'), seg('KG', 'kg')]),
    );
  }

  Widget _footCol(String label, String value, {bool bold = false, bool alignEnd = false, Color? color}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(label, style: robotoRegular.copyWith(color: AppColors.textLight, fontSize: Dimensions.fontSizeExtraSmall)),
          const SizedBox(height: 2),
          Text(value, style: (bold ? robotoBold : robotoMedium).copyWith(
              color: color ?? AppColors.textDark, fontSize: Dimensions.fontSizeSmall)),
        ],
      ),
    );
  }
}
