import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:my_order_pro/common/widgets/empty_state.dart';
import 'package:my_order_pro/data/models/order.dart';
import 'package:my_order_pro/helper/price_converter.dart';
import 'package:my_order_pro/helper/route_helper.dart';
import 'package:my_order_pro/providers/order_provider.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/dimensions.dart';
import 'package:my_order_pro/util/styles.dart';

class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({super.key});

  @override
  State<AllOrdersScreen> createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<OrderProvider>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>().orders;
    final totalAmount = orders.fold<double>(0, (s, o) => s + o.total);
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('All Orders', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge))),
      body: Column(
        children: [
          // Filter row
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Row(
              children: [
                Expanded(flex: 4, child: _filterCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text('FY year', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                      const Icon(Icons.keyboard_arrow_down, color: AppColors.link, size: 16),
                    ]),
                    Text('(${now.year}-${now.year + 1})', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                  ]),
                )),
                const SizedBox(width: 8),
                Expanded(flex: 4, child: _dateCard('Start Date', '01-Apr-${now.year}')),
                const SizedBox(width: 8),
                Expanded(flex: 4, child: _dateCard('End Date', '31-Mar-${now.year + 1}')),
              ],
            ),
          ),
          // Summary
          Container(
            margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(Dimensions.radiusMedium)),
            child: IntrinsicHeight(
              child: Row(children: [
                Expanded(child: _summaryCell('${orders.length}', 'Total Count')),
                const VerticalDivider(width: 1, color: Color(0xFFD9DCE1)),
                Expanded(child: _summaryCell(PriceConverter.format(totalAmount), 'Total Amount')),
              ]),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Expanded(
            child: orders.isEmpty
                ? const EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No orders yet',
                    message: 'Your orders will appear here once you place one.',
                  )
                : Container(
                    margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(Dimensions.radiusMedium)),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: orders.length,
                      separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFE6E8EB), indent: 16),
                      itemBuilder: (_, i) => _OrderRow(order: orders[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterCard({required Widget child}) => Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
            border: Border.all(color: AppColors.border)),
        child: child,
      );

  Widget _dateCard(String label, String value) => _filterCard(
        child: Row(children: [
          const Icon(Icons.event, color: AppColors.link, size: 20),
          const SizedBox(width: 6),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: robotoRegular.copyWith(color: const Color(0xFF8A8F98), fontSize: 10)),
            Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: robotoSemiBold.copyWith(fontSize: Dimensions.fontSizeSmall)),
          ])),
        ]),
      );

  Widget _summaryCell(String value, String label) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
          const SizedBox(height: 2),
          Text(label, style: robotoRegular.copyWith(color: const Color(0xFF4A4F57), fontSize: Dimensions.fontSizeSmall)),
        ],
      );
}

class _OrderRow extends StatelessWidget {
  final OrderModel order;
  const _OrderRow({required this.order});

  @override
  Widget build(BuildContext context) {
    final status = order.status == OrderStatus.delivered ? 'Delivered'
        : order.status == OrderStatus.cancelled ? 'Cancelled' : 'Invoiced';
    final statusColor = order.status == OrderStatus.delivered ? AppColors.success
        : order.status == OrderStatus.cancelled ? AppColors.error : AppColors.warning;
    return InkWell(
      onTap: () => Navigator.pushNamed(context, RouteHelper.orderDetail, arguments: order),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 48,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat('HH:mm').format(order.placedAt),
                      style: robotoMedium.copyWith(color: const Color(0xFF3A3F47), fontSize: Dimensions.fontSizeSmall)),
                  Text(DateFormat('dd-MMM').format(order.placedAt),
                      style: robotoRegular.copyWith(color: const Color(0xFF3A3F47), fontSize: Dimensions.fontSizeSmall)),
                ],
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DAIRY DEMO WHOLESALE',
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall)),
                  const SizedBox(height: 2),
                  Text('#${order.id}', style: robotoMedium.copyWith(
                      color: AppColors.link, fontSize: Dimensions.fontSizeSmall)),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(PriceConverter.format(order.total),
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall)),
            const SizedBox(width: 8),
            Text(status, style: robotoSemiBold.copyWith(color: statusColor, fontSize: Dimensions.fontSizeSmall)),
            const Icon(Icons.chevron_right, color: Color(0xFF9AA0A8), size: 18),
          ],
        ),
      ),
    );
  }
}
