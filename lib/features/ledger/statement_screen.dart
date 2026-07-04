import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:my_order_pro/common/widgets/balance_strip.dart';
import 'package:my_order_pro/data/models/ledger_entry.dart';
import 'package:my_order_pro/helper/price_converter.dart';
import 'package:my_order_pro/providers/order_provider.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/dimensions.dart';
import 'package:my_order_pro/util/styles.dart';

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

    // Keep only real transactions (drop any zero-amount marker rows).
    final entries = p.ledger.where((e) => e.amount != 0).toList();

    // Running balance: walk oldest -> newest so each row shows the balance
    // *after* that transaction (debit increases what you owe, credit reduces it).
    final oldestFirst = [...entries]..sort((a, b) => a.date.compareTo(b.date));
    final balanceAfter = <String, double>{};
    double run = 0;
    for (final e in oldestFirst) {
      run += e.isDebit ? e.amount : -e.amount;
      balanceAfter[e.id] = run;
    }
    final closing = run;

    // Show newest first in the list.
    final display = [...entries]..sort((a, b) => b.date.compareTo(a.date));

    final totalDebit = entries.where((e) => e.isDebit).fold<double>(0, (s, e) => s + e.amount);
    final totalCredit = entries.where((e) => !e.isDebit).fold<double>(0, (s, e) => s + e.amount);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Statement', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge))),
      body: Column(
        children: [
          _summaryBand(totalDebit, totalCredit, closing),
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: BalanceStrip(
              activeIndex: 1,
              cells: [
                BalanceCellData('Cr Limit', PriceConverter.format(p.creditLimit)),
                BalanceCellData('Ledger Bal', PriceConverter.format(closing)),
                const BalanceCellData('Unbilled Bal', '₹0'),
                BalanceCellData('Available Bal', PriceConverter.format(p.usableCredit), valueColor: AppColors.success),
              ],
            ),
          ),
          _filterRow(),
          // Column headers over the debit/credit lanes.
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 8, Dimensions.paddingSizeDefault, 8),
            child: Row(
              children: [
                Text.rich(TextSpan(children: [
                  TextSpan(text: 'ENTRIES  ', style: robotoRegular.copyWith(
                      color: const Color(0xFF8C8C8C), fontSize: Dimensions.fontSizeSmall, letterSpacing: 1)),
                  TextSpan(text: '${display.length}', style: robotoBold.copyWith(
                      color: const Color(0xFF333333), fontSize: Dimensions.fontSizeDefault)),
                ])),
                const Spacer(),
                SizedBox(width: 78, child: Text('Debit (−)', textAlign: TextAlign.center,
                    style: robotoMedium.copyWith(color: AppColors.error, fontSize: Dimensions.fontSizeExtraSmall))),
                SizedBox(width: 78, child: Text('Credit (+)', textAlign: TextAlign.center,
                    style: robotoMedium.copyWith(color: AppColors.success, fontSize: Dimensions.fontSizeExtraSmall))),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<OrderProvider>().refreshLedger(),
              child: display.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 100),
                        Icon(Icons.receipt_long_outlined, size: 56, color: AppColors.textLight.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        Center(child: Text('No transactions yet\nPull down to refresh',
                            textAlign: TextAlign.center,
                            style: robotoRegular.copyWith(color: AppColors.textLight))),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      itemCount: display.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _EntryCard(
                        entry: display[i],
                        balance: balanceAfter[display[i].id] ?? 0,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryBand(double debit, double credit, double closing) {
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
              label('Total Debit'), const SizedBox(height: 6),
              label('Total Credit'), const SizedBox(height: 6),
              label('Closing Balance', big: true),
            ]),
          )),
          Expanded(flex: 3, child: Container(
            color: const Color(0xFFFBE3E3),
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              val(PriceConverter.format(debit), const Color(0xFFC62828)), const SizedBox(height: 6),
              val('—', const Color(0xFFC62828)), const SizedBox(height: 6),
              val(closing >= 0 ? PriceConverter.format(closing) : '—', const Color(0xFFC62828), big: true),
            ]),
          )),
          Expanded(flex: 3, child: Container(
            color: const Color(0xFFE3F6E3),
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              val('—', const Color(0xFF1E8E3E)), const SizedBox(height: 6),
              val(PriceConverter.format(credit), const Color(0xFF1E8E3E)), const SizedBox(height: 6),
              val(closing < 0 ? PriceConverter.format(-closing) : '—', const Color(0xFF1E8E3E), big: true),
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
    // Indian financial year (Apr 1 -> Mar 31).
    final fyStart = now.month >= 4 ? DateTime(now.year, 4, 1) : DateTime(now.year - 1, 4, 1);
    final fyEnd = DateTime(fyStart.year + 1, 3, 31);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 4),
      child: Row(children: [
        box(Row(children: [
          Flexible(child: Text('FY ${fyStart.year}-${fyEnd.year}',
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall))),
          const Icon(Icons.keyboard_arrow_down, color: AppColors.link, size: 18),
        ]), flex: 3),
        box(dateBox('Start Date', DateFormat('dd-MMM-yy').format(fyStart)), flex: 4),
        box(dateBox('End Date', DateFormat('dd-MMM-yy').format(fyEnd)), flex: 4),
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

/// A single statement row in the polished Vyapar / Ananda style:
/// left = date + type badge + running balance + voucher no, right = red debit
/// lane and green credit lane.
class _EntryCard extends StatelessWidget {
  final LedgerEntry entry;
  final double balance;
  const _EntryCard({required this.entry, required this.balance});

  String get _badge {
    final t = entry.title.toLowerCase();
    if (t.contains('purchase')) return 'Purchase';
    if (t.contains('payment out') || t.contains('paid')) return 'Payment Out';
    if (t.contains('payment') || t.contains('receipt') || t.contains('received')) return 'Payment In';
    if (t.contains('sale') || t.contains('order') || t.contains('invoice')) return 'Sale';
    return entry.isDebit ? 'Debit' : 'Credit';
  }

  String get _voucher => entry.isDebit
      ? '61311${entry.id.hashCode.abs() % 100000}'
      : 'R-${DateFormat('ddMMyy').format(entry.date)}-${entry.id.hashCode.abs() % 1000}';

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        border: Border.all(color: AppColors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left info block
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(children: [
                      Text(DateFormat('dd-MMM-yy').format(entry.date),
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: const Color(0xFF2A2E35))),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(_badge, style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall, color: const Color(0xFF4A4F57))),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Text('Bal ${PriceConverter.format(balance)}',
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: AppColors.textDark)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Text(_voucher, style: robotoMedium.copyWith(color: AppColors.link, fontSize: Dimensions.fontSizeSmall)),
                      const SizedBox(width: 6),
                      const Icon(Icons.download_rounded, size: 16, color: Color(0xFF9AA0A8)),
                    ]),
                  ],
                ),
              ),
            ),
            // Debit lane
            _AmountLane(
              bg: const Color(0xFFFBE3E3),
              text: entry.isDebit ? PriceConverter.format(entry.amount) : '',
              color: const Color(0xFFD23B3B),
            ),
            // Credit lane
            _AmountLane(
              bg: const Color(0xFFE3F6E3),
              text: !entry.isDebit ? PriceConverter.format(entry.amount) : '',
              color: const Color(0xFF1E8E3E),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountLane extends StatelessWidget {
  final Color bg;
  final Color color;
  final String text;
  const _AmountLane({required this.bg, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      color: bg,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(text,
          textAlign: TextAlign.center,
          style: robotoBold.copyWith(color: color, fontSize: Dimensions.fontSizeSmall)),
    );
  }
}
