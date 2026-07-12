import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_order_pro/common/widgets/balance_strip.dart';
import 'package:my_order_pro/features/home/widgets/banner_carousel.dart';
import 'package:my_order_pro/helper/price_converter.dart';
import 'package:my_order_pro/helper/route_helper.dart';
import 'package:my_order_pro/providers/auth_provider.dart';
import 'package:my_order_pro/providers/catalog_provider.dart';
import 'package:my_order_pro/providers/order_provider.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/dimensions.dart';
import 'package:my_order_pro/util/styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _openTime = '';
  String _cutoffTime = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final catalog = context.read<CatalogProvider>();
      if (catalog.categories.isEmpty) catalog.loadHome();
      context.read<OrderProvider>().loadLedger();
    });
    _loadWindow();
  }

  Future<void> _loadWindow() async {
    try {
      final row = await Supabase.instance.client
          .from('store_settings')
          .select('order_open_time, order_cutoff_time')
          .eq('id', 1)
          .maybeSingle();
      if (!mounted || row == null) return;
      setState(() {
        _openTime = (row['order_open_time'] ?? '').toString();
        _cutoffTime = (row['order_cutoff_time'] ?? '').toString();
      });
    } catch (_) {/* non-fatal */}
  }

  int? _minutes(String hhmm) {
    final p = hhmm.split(':');
    if (p.length < 2) return null;
    final h = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    return (h == null || m == null) ? null : h * 60 + m;
  }

  bool get _orderClosed {
    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;
    final open = _minutes(_openTime);
    final cut = _minutes(_cutoffTime);
    if (open != null && nowMin < open) return true;
    if (cut != null && nowMin > cut) return true;
    return false;
  }

  Widget _closedBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEA),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: const Color(0xFFF3C9C9)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_clock, color: Color(0xFFD23B3B), size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ordering is closed right now',
                    style: robotoBold.copyWith(color: const Color(0xFFD23B3B), fontSize: Dimensions.fontSizeDefault)),
                if (_openTime.isNotEmpty || _cutoffTime.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _openTime.isNotEmpty && _cutoffTime.isNotEmpty
                        ? 'Order window: $_openTime – $_cutoffTime'
                        : (_cutoffTime.isNotEmpty ? 'Closed at $_cutoffTime' : 'Opens at $_openTime'),
                    style: robotoRegular.copyWith(color: const Color(0xFF8A5050), fontSize: Dimensions.fontSizeSmall),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final isCatalogLoading = catalog.isLoading;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: () => context.read<CatalogProvider>().loadHome(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                Dimensions.paddingSizeDefault,
                Dimensions.paddingSizeDefault,
                Dimensions.paddingSizeDefault,
                Dimensions.paddingSizeLarge,
              ),
              children: [
                if (_orderClosed) ...[
                  _closedBanner(),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                ],
                const _DistributorCard(),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                if (isCatalogLoading) ...[
                  const _CatalogShimmer(),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                ] else if (catalog.banners.isNotEmpty) ...[
                  BannerCarousel(banners: catalog.banners),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                ],
                const _QuickAccessCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DistributorCard extends StatelessWidget {
  const _DistributorCard();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final orders = context.watch<OrderProvider>();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    (user?.shopName.isNotEmpty ?? false) ? user!.shopName[0].toUpperCase() : 'D',
                    style: robotoBold.copyWith(color: AppColors.primary, fontSize: 22),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.typeLabel ?? 'Retailer', style: robotoMedium.copyWith(
                          color: AppColors.success, fontSize: Dimensions.fontSizeSmall)),
                      const SizedBox(height: 1),
                      Text(user?.shopName ?? 'My Kirana Store',
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                      const SizedBox(height: 2),
                      Text('+91-${user?.phone ?? "9000000000"}',
                          style: robotoRegular.copyWith(color: AppColors.textLight, fontSize: Dimensions.fontSizeSmall)),
                      if ((user?.code ?? '').isNotEmpty)
                        Text('${user!.typeLabel} Code: ${user.code}',
                            style: robotoBold.copyWith(color: AppColors.primary, fontSize: Dimensions.fontSizeSmall)),
                    ],
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(context, RouteHelper.statement),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text('Sync Bal', style: robotoBold.copyWith(
                          color: AppColors.link, fontSize: Dimensions.fontSizeDefault)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: BalanceStrip(
              activeIndex: 1,
              cells: [
                BalanceCellData('Cr Limit', PriceConverter.format(orders.creditLimit)),
                BalanceCellData('Ledger Bal', PriceConverter.format(orders.outstanding)),
                const BalanceCellData('Unbilled Bal', '₹0'),
                BalanceCellData('Available Bal', PriceConverter.format(orders.usableCredit),
                    valueColor: AppColors.success),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard();

  @override
  Widget build(BuildContext context) {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.grid_view_rounded, color: Color(0xFF5B5BD6), size: 18),
              const SizedBox(width: 8),
              Text('Quick Access', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Row(
            children: [
              _tile(context, Icons.assignment_outlined, 'Orders', AppColors.link, AppColors.tintBlue,
                  () => Navigator.pushNamed(context, RouteHelper.allOrders)),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              _tile(context, Icons.receipt_long_outlined, 'Invoice', AppColors.success, AppColors.tintGreen,
                  () => Navigator.pushNamed(context, RouteHelper.statement)),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              _tile(context, Icons.add_chart_outlined, 'Place Order', const Color(0xFFE8862E), AppColors.tintOrange,
                  () => Navigator.pushNamed(context, RouteHelper.placeOrder)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String label, Color color, Color bg, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 112,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 34),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Text(label, style: robotoBold.copyWith(color: color, fontSize: Dimensions.fontSizeDefault)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatalogShimmer extends StatelessWidget {
  const _CatalogShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Container(
            height: 24,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Row(
            children: List.generate(3, (index) => Expanded(
              child: Container(
                height: 120,
                margin: EdgeInsets.only(right: index < 2 ? Dimensions.paddingSizeSmall : 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }
}

Widget _whiteCard({required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      border: Border.all(color: AppColors.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 3),
        )
      ],
    ),
    child: child,
  );
}
