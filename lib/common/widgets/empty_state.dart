import 'package:flutter/material.dart';
import 'package:my_order_pro/common/widgets/custom_button.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/dimensions.dart';
import 'package:my_order_pro/util/styles.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 54, color: AppColors.primary),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Text(title, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              message,
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(color: AppColors.textMedium),
            ),
            if (actionText != null) ...[
              const SizedBox(height: Dimensions.paddingSizeLarge),
              SizedBox(
                width: 200,
                child: CustomButton(text: actionText!, onPressed: onAction),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
