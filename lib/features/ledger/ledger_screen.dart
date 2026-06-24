import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:saathi/common/widgets/custom_button.dart';
import 'package:saathi/data/models/ledger_entry.dart';
import 'package:saathi/helper/price_converter.dart';
import 'package:saathi/providers/order_provider.dart';
import 'package:saathi/util/app_colors.dart';
import 'package:saathi/util/dimensions.dart';
import 'package:saathi/util/styles.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadLedger();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final entries = provider.ledger;

    return Scaffold(
      appBar: AppBar(title: Text('Khata / Ledger', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge))),
      body: Column(
        children: [
          // Outstanding balance card (clean)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined,
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: 6),
                    Text('Total Outstanding (Udhaar)',
                        style: robotoMedium.copyWith(
                            color: AppColors.textMedium, fontSize: Dimensions.fontSizeSmall)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(PriceConverter.format(provider.outstanding),
                    style: robotoBlack.copyWith(color: AppColors.primary, fontSize: 34)),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                CustomButton(
                  text: 'Pay Now',
                  onPressed: provider.outstanding > 0 ? () => _payDialog(context) : null,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Row(
              children: [
                Text('Transaction History', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Expanded(
            child: entries.isEmpty
                ? Center(child: Text('No transactions yet',
                    style: robotoRegular.copyWith(color: AppColors.textLight)))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) => _LedgerTile(entry: entries[i]),
                  ),
          ),
        ],
      ),
    );
  }

  void _payDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Redirecting to payment... (demo)')),
    );
  }
}

class _LedgerTile extends StatelessWidget {
  final LedgerEntry entry;
  const _LedgerTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final color = entry.isDebit ? AppColors.error : AppColors.success;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
        child: Icon(entry.isDebit ? Icons.arrow_upward : Icons.arrow_downward, color: color, size: 20),
      ),
      title: Text(entry.title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
      subtitle: Text(DateFormat('dd MMM yyyy').format(entry.date),
          style: robotoRegular.copyWith(color: AppColors.textLight, fontSize: Dimensions.fontSizeExtraSmall)),
      trailing: Text(
        '${entry.isDebit ? "+" : "-"}${PriceConverter.format(entry.amount)}',
        style: robotoBold.copyWith(color: color, fontSize: Dimensions.fontSizeDefault),
      ),
    );
  }
}
