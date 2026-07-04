import 'package:flutter/material.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/dimensions.dart';
import 'package:my_order_pro/util/styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
        if (actionText != null)
          InkWell(
            onTap: onAction,
            child: Row(
              children: [
                Text(actionText!, style: robotoMedium.copyWith(
                  color: AppColors.link, fontSize: Dimensions.fontSizeSmall)),
                const Icon(Icons.chevron_right, size: 18, color: AppColors.link),
              ],
            ),
          ),
      ],
    );
  }
}
