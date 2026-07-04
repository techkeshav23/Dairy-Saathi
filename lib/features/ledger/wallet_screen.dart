import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_order_pro/common/widgets/custom_button.dart';
import 'package:my_order_pro/helper/price_converter.dart';
import 'package:my_order_pro/providers/order_provider.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/dimensions.dart';
import 'package:my_order_pro/util/styles.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _amount = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<OrderProvider>().loadLedger());
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<OrderProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('My Wallet', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge))),
      body: ListView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        children: [
          Row(
            children: [
              _balCard('Credit\nLimit', PriceConverter.format(p.creditLimit), AppColors.textDark, false),
              const SizedBox(width: 8),
              _balCard('Ledger\nBalance', PriceConverter.format(p.outstanding), Colors.white, true),
              const SizedBox(width: 8),
              _balCard('Unbilled\nBalance', '₹0', AppColors.textDark, false),
              const SizedBox(width: 8),
              _balCard('Available\nBalance', PriceConverter.format(p.usableCredit), AppColors.success, false),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          Text('Increase Limit', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter amount',
                    hintStyle: robotoRegular.copyWith(color: const Color(0xFF9A9A9A), fontSize: Dimensions.fontSizeLarge),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Row(
                  children: [
                    _preset('₹ 5,000'),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    _preset('₹ 10,000'),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    _preset('₹ 15,000'),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                CustomButton(text: 'Add Money', onPressed: () => _toast()),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          Text('Explore More', style: robotoBold.copyWith(color: AppColors.primary, fontSize: Dimensions.fontSizeLarge)),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: [
                _exploreRow(Icons.home_work_outlined, 'Kredmint'),
                const Divider(height: 1, color: Color(0xFFECECEC)),
                _exploreRow(Icons.account_balance_outlined, 'Online Transactions'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _balCard(String label, String value, Color color, bool active) {
    return Expanded(
      child: Container(
        height: 96,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
          border: active ? null : Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: robotoBold.copyWith(color: active ? Colors.white : color, fontSize: Dimensions.fontSizeSmall)),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center,
                style: robotoMedium.copyWith(
                    color: active ? Colors.white : const Color(0xFF3A3A3A), fontSize: 10, height: 1.1)),
          ],
        ),
      ),
    );
  }

  Widget _preset(String t) => Expanded(
        child: OutlinedButton(
          onPressed: () {
            _amount.text = t.replaceAll(RegExp(r'[^0-9]'), '');
            setState(() {});
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textDark,
            side: const BorderSide(color: Color(0xFFD9D9D9)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusMedium)),
          ),
          child: Text(t, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall)),
        ),
      );

  Widget _exploreRow(IconData icon, String label) => InkWell(
        onTap: () => _toast(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 16),
          child: Row(children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(child: Text(label, style: robotoMedium.copyWith(
                color: const Color(0xFF333333), fontSize: Dimensions.fontSizeDefault))),
            const Icon(Icons.chevron_right, color: Color(0xFF555555), size: 20),
          ]),
        ),
      );

  void _toast() => ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Money — demo')));
}
