import 'package:flutter/material.dart';
import 'package:saathi/common/widgets/ananda_top_bar.dart';
import 'package:saathi/util/app_colors.dart';
import 'package:saathi/util/dimensions.dart';
import 'package:saathi/util/styles.dart';

class _Report {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  const _Report(this.icon, this.title, this.subtitle, {this.enabled = true});
}

class _Section {
  final String title;
  final List<_Report> rows;
  final bool enabled;
  const _Section(this.title, this.rows, {this.enabled = true});
}

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  static const _chips = ['All', 'Purchase', 'Sales', 'Customer', 'Gst', 'Inventory'];

  static const _sections = [
    _Section('Purchase Reports', [
      _Report(Icons.event_note_outlined, 'Purchase Day-wise Report', 'Daily purchase summary'),
      _Report(Icons.receipt_long_outlined, 'Purchase invoice', 'Summary of all Purchases Invoice'),
      _Report(Icons.inventory_2_outlined, 'Open Purchase Order', 'Summary of Open Purchase order'),
      _Report(Icons.description_outlined, 'All Purchase Order', 'Summary of All Purchase Order'),
      _Report(Icons.format_list_bulleted, 'Supplier List', 'Summary of Supplier List'),
    ]),
    _Section('Sales Reports', [
      _Report(Icons.event_note_outlined, 'Sales Day-wise Report', 'Daily Sales Summary'),
      _Report(Icons.receipt_long_outlined, 'Sale Invoice', 'Summary of all Sale Invoice'),
      _Report(Icons.inventory_2_outlined, 'Open Sale Order', 'Summary of Open Sales order'),
      _Report(Icons.description_outlined, 'All Sale Order', 'Summary of All Sale Order'),
      _Report(Icons.format_list_bulleted, 'Retailer List', 'Summary of Retailer List'),
      _Report(Icons.map_outlined, 'Retailers on Map', 'Summary of Retailer Map List'),
    ]),
    _Section('Customer Reports', [
      _Report(Icons.swap_horiz, 'Customer Transactions report', 'Summary of all customer Transactions'),
      _Report(Icons.picture_as_pdf_outlined, 'Customer list pdf', 'List of all Customers', enabled: false),
    ]),
    _Section('GST Reports', [
      _Report(Icons.article_outlined, 'GSTR 1 Report', 'GSTR 1', enabled: false),
      _Report(Icons.article_outlined, 'GSTR 2 Report', 'GSTR 2', enabled: false),
      _Report(Icons.article_outlined, 'GSTR 3B Report', 'GSTR 3B', enabled: false),
    ], enabled: false),
    _Section('Inventory Reports', [
      _Report(Icons.inventory_2_outlined, 'Stock Summary', 'Summary of all items', enabled: false),
      _Report(Icons.warning_amber_outlined, 'Low Stock Summary Report', 'Summary of all low stock items', enabled: false),
      _Report(Icons.trending_up, 'Profit & Loss Report', 'Summary of all item level profit & loss', enabled: false),
    ], enabled: false),
    _Section('Supplier Reports', [
      _Report(Icons.format_list_bulleted, 'Supplier Transaction Report', 'Summary of all supplier transactions'),
      _Report(Icons.picture_as_pdf_outlined, 'Supplier list pdf', 'List of all suppliers', enabled: false),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AnandaTopBar(),
          // Filter chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
            child: SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                itemCount: _chips.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECECEC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(_chips[i],
                      style: robotoRegular.copyWith(
                          color: const Color(0xFF393939), fontSize: Dimensions.fontSizeDefault)),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              itemCount: _sections.length,
              separatorBuilder: (_, _) => const SizedBox(height: Dimensions.paddingSizeSmall),
              itemBuilder: (_, i) => _SectionCard(section: _sections[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final _Section section;
  const _SectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault,
          Dimensions.paddingSizeDefault, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.title, style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: section.enabled ? AppColors.textDark : AppColors.disabledText)),
          const SizedBox(height: 4),
          for (int i = 0; i < section.rows.length; i++) ...[
            _row(context, section.rows[i]),
            if (i < section.rows.length - 1)
              const Divider(height: 1, thickness: 1, color: Color(0xFFEDEDED), indent: 36),
          ],
        ],
      ),
    );
  }

  Widget _row(BuildContext context, _Report r) {
    final on = r.enabled;
    final titleColor = on ? const Color(0xFF2B2B2B) : AppColors.disabledText;
    final subColor = on ? const Color(0xFFA6A6A6) : AppColors.disabledText;
    final iconColor = on ? AppColors.primary : AppColors.disabledText;
    return InkWell(
      onTap: on
          ? () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${r.title} — demo')))
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Icon(r.icon, size: 22, color: iconColor),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.title, style: robotoSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault, color: titleColor)),
                  const SizedBox(height: 2),
                  Text(r.subtitle, style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall, color: subColor)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: on ? const Color(0xFFC9C9C9) : AppColors.disabledText),
          ],
        ),
      ),
    );
  }
}

