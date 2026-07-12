import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_order_pro/common/widgets/order_summary_card.dart';
import 'package:my_order_pro/common/widgets/product_image.dart';
import 'package:my_order_pro/data/models/order.dart';
import 'package:my_order_pro/helper/pdf_invoice_helper.dart';
import 'package:my_order_pro/helper/price_converter.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/dimensions.dart';
import 'package:my_order_pro/util/styles.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;
  const OrderDetailScreen({super.key, required this.order});

  // Stages used for the tracking timeline.
  static const _stages = [
    OrderStatus.placed,
    OrderStatus.confirmed,
    OrderStatus.packed,
    OrderStatus.dispatched,
    OrderStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _stages.indexOf(order.status);
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id}', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download Bill',
            onPressed: () async {
              await PdfInvoiceHelper.printInvoice(
                docTitle: 'TAX INVOICE',
                invoiceNo: order.id.toString(),
                date: order.placedAt,
                partyName: 'Customer',
                partyAddress: order.address,
                items: order.lines.map((line) => {
                  'name': line.name,
                  'hsn': '',
                  'qty': line.quantity,
                  'rate': line.unitPrice,
                  'amount': line.total,
                }).toList(),
                subtotal: order.subtotal.toDouble(),
                cgst: 0,
                sgst: 0,
                total: order.total.toDouble(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Bill',
            onPressed: () async {
              await PdfInvoiceHelper.shareInvoice(
                docTitle: 'TAX INVOICE',
                invoiceNo: order.id.toString(),
                date: order.placedAt,
                partyName: 'Customer',
                partyAddress: order.address,
                items: order.lines.map((line) => {
                  'name': line.name,
                  'hsn': '',
                  'qty': line.quantity,
                  'rate': line.unitPrice,
                  'amount': line.total,
                }).toList(),
                subtotal: order.subtotal.toDouble(),
                cgst: 0,
                sgst: 0,
                total: order.total.toDouble(),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        children: [
          // Tracking timeline
          _card(context, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order Tracking', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              ...List.generate(_stages.length, (i) {
                final done = i <= currentIndex;
                final isLast = i == _stages.length - 1;
                return _TimelineRow(
                  label: _stages[i].label,
                  done: done,
                  active: i == currentIndex,
                  isLast: isLast,
                );
              }),
            ],
          )),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Items
          _card(context, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Items (${order.lines.length})',
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              ...order.lines.map((line) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                          child: ProductImage(
                              url: line.imageUrl, categoryId: '', size: 48),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(line.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: robotoSemiBold.copyWith(fontSize: Dimensions.fontSizeSmall)),
                              Text('${line.qtyLabel} × ${PriceConverter.format(line.unitPrice)}',
                                  style: robotoRegular.copyWith(
                                      color: AppColors.textMedium, fontSize: Dimensions.fontSizeExtraSmall)),
                            ],
                          ),
                        ),
                        Text(PriceConverter.format(line.total), style: robotoSemiBold),
                      ],
                    ),
                  )),
            ],
          )),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Delivery + payment
          _card(context, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _kv(Icons.calendar_today_outlined, 'Placed on',
                  DateFormat('dd MMM yyyy, hh:mm a').format(order.placedAt)),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              _kv(Icons.location_on_outlined, 'Delivery address', order.address),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              _kv(Icons.payments_outlined, 'Payment', order.paymentMode.label),
            ],
          )),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          OrderSummaryCard(
            subtotal: order.subtotal,
            gst: order.gst,
            deliveryCharge: order.deliveryCharge,
            total: order.total,
            savings: order.savings,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, {required Widget child}) => Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        ),
        child: child,
      );

  Widget _kv(IconData icon, String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textMedium),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: robotoRegular.copyWith(
                    color: AppColors.textLight, fontSize: Dimensions.fontSizeExtraSmall)),
                Text(value, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
              ],
            ),
          ),
        ],
      );
}

class _TimelineRow extends StatelessWidget {
  final String label;
  final bool done;
  final bool active;
  final bool isLast;
  const _TimelineRow({required this.label, required this.done, required this.active, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final color = done ? AppColors.success : AppColors.border;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  color: done ? AppColors.success : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: done
                    ? const Icon(Icons.check, size: 13, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: color),
                ),
            ],
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
            child: Text(label,
                style: (active || done ? robotoSemiBold : robotoRegular).copyWith(
                    color: done ? AppColors.textDark : AppColors.textLight,
                    fontSize: Dimensions.fontSizeDefault)),
          ),
        ],
      ),
    );
  }
}