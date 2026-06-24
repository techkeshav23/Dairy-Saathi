import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:saathi/common/widgets/balance_strip.dart';
import 'package:saathi/data/models/ledger_entry.dart';
import 'package:saathi/helper/price_converter.dart';
import 'package:saathi/providers/order_provider.dart';
import 'package:saathi/util/app_colors.dart';
import 'package:saathi/util/dimensions.dart';
import 'package:saathi/util/styles.dart';

class StatementScreen extends StatefulWidget {
  const StatementScreen({super.key});

  @override
  State<StatementScreen> createState() => _StatementScreenState();
}

class _StatementScreenState extends State<StatementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<OrderProvider>().loadLedger());
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<OrderProvider>();
    final entries = p.ledger;
    final totalDebit = entries.where((e) => e.isDebit).fold<double>(0, (s, e) => s + e.amount);
    final totalCredit = entries.where((e) => !e.isDebit).fold<double>(0, (s, e) => s + e.amount);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Statement', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge))),
      body: Column(
        children: [
          // Summary band
          _summaryBand(totalDebit, totalCredit, p.outstanding),
          // Balance strip
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: BalanceStrip(
              activeIndex: 1,
              cells: [
                BalanceCellData('Cr Limit', PriceConverter.format(p.creditLimit)),
                BalanceCellData('Ledger Bal', PriceConverter.format(p.outstanding)),
                const BalanceCellData('Unbilled Bal', '₹0'),
                BalanceCellData('Available Bal', PriceConverter.format(p.usableCredit), valueColor: AppColors.success),
              ],
            ),
          ),
          _filterRow(),
          // Entries header
          Container(
            width: double.infinity,
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 8),
            child: Text.rich(TextSpan(children: [
              TextSpan(text: 'ENTRIES  ', style: robotoRegular.copyWith(
                  color: const Color(0xFF8C8C8C), fontSize: Dimensions.fontSizeSmall, letterSpacing: 1)),
              TextSpan(text: '${entries.length}', style: robotoBold.copyWith(
                  color: const Color(0xFF333333), fontSize: Dimensions.fontSizeDefault)),
            ])),
          ),
          Expanded(
            child: entries.isEmpty
                ? Center(child: Text('No transactions yet',
                    style: robotoRegular.copyWith(color: AppColors.textLight)))
                : ListView.separated(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _EntryCard(entry: entries[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _summaryBand(double debit, double credit, double outstanding) {
    Widget label(String t, {bool big = false}) => Text(t, style: robotoBold.copyWith(
        color: const Color(0xFF1C1C1C), fontSize: big ? Dimensions.fontSizeLarge : Dimensions.fontSizeDefault));
    Widget val(String t, Color c, {bool big = false}) => Text(t, textAlign: TextAlign.right,
        style: robotoBold.copyWith(color: c, fontSize: big ? Dimensions.fontSizeLarge : Dimensions.fontSizeDefault));
    return Container(
      margin: const EdgeInsets.fromLTRB(Dimensions.paddingSizeSmall, Dimensions.paddingSizeSmall, Dimensions.paddingSizeSmall, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 5, child: Container(
            color: const Color(0xFFF1F1F1),
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              label('Opening Balance'), const SizedBox(height: 6),
              label('Current Total'), const SizedBox(height: 6),
              label('Closing Balance', big: true),
            ]),
          )),
          Expanded(flex: 3, child: Container(
            color: const Color(0xFFF1A0A0),
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              val('0.00', const Color(0xFFC62828)), const SizedBox(height: 6),
              val(PriceConverter.format(debit), const Color(0xFFC62828)), const SizedBox(height: 6),
              val(PriceConverter.format(outstanding > 0 ? outstanding : 0), const Color(0xFFC62828), big: true),
            ]),
          )),
          Expanded(flex: 3, child: Container(
            color: const Color(0xFFA8E6A8),
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              val(PriceConverter.format(outstanding < 0 ? -outstanding : 0), const Color(0xFF1E8E3E)), const SizedBox(height: 6),
              val(PriceConverter.format(credit), const Color(0xFF1E8E3E)), const SizedBox(height: 6),
              val(PriceConverter.format(outstanding < 0 ? -outstanding : 0), const Color(0xFF1E8E3E), big: true),
            ]),
          )),
        ],
      ),
    );
  }

  Widget _filterRow() {
    Widget box(Widget child, {int flex = 1}) => Expanded(flex: flex, child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
            border: Border.all(color: AppColors.border)),
          child: child,
        ));
    Widget dateBox(String label, String value) => Row(children: [
          const Icon(Icons.event, color: AppColors.link, size: 20),
          const SizedBox(width: 6),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: robotoRegular.copyWith(color: const Color(0xFF9A9A9A), fontSize: 10)),
            Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: robotoBold.copyWith(color: const Color(0xFF1C1C1C), fontSize: Dimensions.fontSizeSmall)),
          ])),
        ]);
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 4),
      child: Row(children: [
        box(Row(children: [
          Flexible(child: Text('This month', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall))),
          const Icon(Icons.keyboard_arrow_down, color: AppColors.link, size: 18),
        ]), flex: 3),
        box(dateBox('Start Date', DateFormat('dd-MMM-yy').format(start)), flex: 4),
        box(dateBox('End Date', DateFormat('dd-MMM-yy').format(now)), flex: 4),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
              border: Border.all(color: AppColors.border)),
          child: const Icon(Icons.picture_as_pdf, color: AppColors.primary, size: 22),
        ),
      ]),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final LedgerEntry entry;
  const _EntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isDebit = entry.isDebit;
    final type = isDebit ? 'Sale' : 'Rcpt';
    final vch = isDebit ? '61311${entry.id.hashCode.abs() % 100000}' : 'R-${DateFormat('ddMMyy').format(entry.date)}-${entry.id.hashCode.abs() % 9999}';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: AppColors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left info
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(DateFormat('dd-MMM-yyyy').format(entry.date),
                          style: robotoBold.copyWith(color: const Color(0xFF1C1C1C), fontSize: Dimensions.fontSizeSmall)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFC8C8C8))),
                        child: Text(type, style: robotoRegular.copyWith(
                            color: const Color(0xFF6E6E6E), fontSize: 11)),
                      ),
                    ]),
                    const SizedBox(height: 3),
                    Text('Bal ${PriceConverter.format(-10)}',
                        style: robotoBold.copyWith(color: const Color(0xFF1C1C1C), fontSize: Dimensions.fontSizeSmall)),
                    const SizedBox(height: 3),
                    Row(children: [
                      Flexible(child: Text('Vch No: $vch', maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: robotoMedium.copyWith(color: AppColors.link, fontSize: Dimensions.fontSizeSmall))),
                      const SizedBox(width: 4),
                      const Icon(Icons.download, color: Color(0xFF7A7A7A), size: 18),
                    ]),
                  ],
                ),
              ),
            ),
            // Debit column (pink)
            Expanded(flex: 3, child: Container(
              color: AppColors.errorLight,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: isDebit ? Text(PriceConverter.formatPrecise(entry.amount),
                  style: robotoBold.copyWith(color: AppColors.error, fontSize: Dimensions.fontSizeSmall)) : null,
            )),
            // Credit column (green)
            Expanded(flex: 3, child: Container(
              color: AppColors.successLight,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: !isDebit ? Text(PriceConverter.formatPrecise(entry.amount),
                  style: robotoBold.copyWith(color: const Color(0xFF1E8E3E), fontSize: Dimensions.fontSizeSmall)) : null,
            )),
          ],
        ),
      ),
    );
  }
}
