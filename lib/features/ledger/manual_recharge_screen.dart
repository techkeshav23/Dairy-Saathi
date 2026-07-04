import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_order_pro/common/widgets/custom_button.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/dimensions.dart';
import 'package:my_order_pro/util/styles.dart';

class ManualRechargeScreen extends StatelessWidget {
  const ManualRechargeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final range =
        '${DateFormat('dd-MMM-yyyy').format(start)} to ${DateFormat('dd-MMM-yyyy').format(now)}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Manual Recharge', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
        actions: [
          IconButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('New recharge — demo'))),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          // MTD date range row
          Padding(
            padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeLarge, Dimensions.paddingSizeDefault,
                Dimensions.paddingSizeLarge, Dimensions.paddingSizeDefault),
            child: Row(
              children: [
                Text('MTD ', style: robotoBold.copyWith(color: AppColors.link, fontSize: Dimensions.fontSizeLarge)),
                Expanded(
                  child: Text(range,
                      style: robotoSemiBold.copyWith(color: AppColors.textDark, fontSize: Dimensions.fontSizeDefault)),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Color(0xFF333333)),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFECECEC)),
          // Stat strip
          IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
              child: Row(
                children: [
                  _stat('Claimed', AppColors.warning),
                  _vd(),
                  _stat('Approved', AppColors.link),
                  _vd(),
                  _stat('Declined', AppColors.error),
                  _vd(),
                  _stat('Total', AppColors.textDark),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFECECEC)),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 200),
                child: Text('No Recharge History(s) found',
                    style: robotoRegular.copyWith(color: const Color(0xFF7A7A7A), fontSize: Dimensions.fontSizeLarge)),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 8, Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault),
        child: SafeArea(
          child: CustomButton(
            text: 'Add Money',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add Money — demo'))),
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, Color color) => Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('₹0.00', style: robotoBold.copyWith(color: color, fontSize: Dimensions.fontSizeLarge)),
            const SizedBox(height: 2),
            Text(label, style: robotoMedium.copyWith(color: color, fontSize: Dimensions.fontSizeDefault)),
            const SizedBox(height: 2),
            Text('0', style: robotoRegular.copyWith(color: AppColors.textDark, fontSize: Dimensions.fontSizeDefault)),
          ],
        ),
      );

  Widget _vd() => const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE0E0E0), indent: 8, endIndent: 8);
}
