import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:my_order_pro/data/models/ledger_entry.dart';
import 'package:my_order_pro/helper/price_converter.dart';
import 'package:my_order_pro/providers/order_provider.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/dimensions.dart';
import 'package:my_order_pro/util/styles.dart';
import 'package:my_order_pro/features/transactions/payment_in_screen.dart';

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
      appBar: AppBar(
        title: Text('Khata / Ledger', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          // Outstanding balance card (Premium)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_balance_wallet_rounded,
                        color: Colors.white.withValues(alpha: 0.8), size: 20),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Text(
                      'Total Outstanding (Udhaar)',
                      style: robotoMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    PriceConverter.format(provider.outstanding),
                    style: robotoBlack.copyWith(
                      color: Colors.white,
                      fontSize: 42,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: provider.outstanding > 0 ? () => _payDialog(context) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                      ),
                      disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
                    ),
                    child: Text(
                      'Pay Now',
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSmall,
            ),
            child: Row(
              children: [
                Text('Transaction History', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                const Spacer(),
                const Icon(Icons.history_rounded, color: AppColors.textLight, size: 20),
              ],
            ),
          ),
          
          Expanded(
            child: entries.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      left: Dimensions.paddingSizeDefault,
                      right: Dimensions.paddingSizeDefault,
                      bottom: Dimensions.paddingSizeExtraLarge,
                    ),
                    itemCount: entries.length,
                    itemBuilder: (_, i) {
                      final entry = entries[i];
                      // Add date headers if date changes
                      bool showHeader = false;
                      if (i == 0) {
                        showHeader = true;
                      } else {
                        final prevEntry = entries[i - 1];
                        if (entry.date.day != prevEntry.date.day ||
                            entry.date.month != prevEntry.date.month ||
                            entry.date.year != prevEntry.date.year) {
                          showHeader = true;
                        }
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showHeader)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: Dimensions.paddingSizeDefault,
                                bottom: Dimensions.paddingSizeSmall,
                              ),
                              child: Text(
                                _formatDateHeader(entry.date),
                                style: robotoMedium.copyWith(
                                  color: AppColors.textMedium,
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                            ),
                          _LedgerTile(entry: entry),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          Text(
            'No Transactions Yet',
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(
            'Your ledger entries will appear here.',
            style: robotoRegular.copyWith(color: AppColors.textMedium),
          ),
        ],
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  void _payDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PaymentInScreen()),
    );
  }
}

class _LedgerTile extends StatelessWidget {
  final LedgerEntry entry;
  const _LedgerTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isDebit = entry.isDebit;
    final color = isDebit ? AppColors.error : AppColors.success;
    final icon = isDebit ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
    
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: robotoSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('hh:mm a').format(entry.date),
                  style: robotoRegular.copyWith(
                    color: AppColors.textLight,
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isDebit ? "+" : "-"}${PriceConverter.format(entry.amount)}',
                style: robotoBold.copyWith(
                  color: color,
                  fontSize: Dimensions.fontSizeLarge,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isDebit ? 'Credit Used' : 'Payment',
                style: robotoMedium.copyWith(
                  color: AppColors.textLight,
                  fontSize: Dimensions.fontSizeExtraSmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}