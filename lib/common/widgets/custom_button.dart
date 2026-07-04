import 'package:flutter/material.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/dimensions.dart';
import 'package:my_order_pro/util/styles.dart';

/// Primary filled button used across the app. Set [isLoading] to show a spinner,
/// [outlined] for a secondary variant, [color] to override the fill.
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;
  final Color? color;
  final IconData? icon;
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.outlined = false,
    this.color,
    this.icon,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    final fill = color ?? AppColors.primary;
    final disabled = onPressed == null || isLoading;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: outlined
          ? OutlinedButton(
              onPressed: disabled ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: fill,
                disabledForegroundColor: AppColors.disabledButton,
                side: BorderSide(
                  color: disabled ? AppColors.disabledButton : fill,
                  width: 1.4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
              ),
              child: _child(disabled ? AppColors.disabledButton : fill),
            )
          : ElevatedButton(
              onPressed: disabled ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: fill,
                foregroundColor: AppColors.textDark,
                disabledBackgroundColor: AppColors.disabledButton,
                disabledForegroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
              ),
              child: _child(AppColors.textDark),
            ),
    );
  }

  Widget _child(Color fg) {
    if (isLoading) {
      return SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
      );
    }
    final label = Text(
      text,
      style: robotoSemiBold.copyWith(color: fg, fontSize: Dimensions.fontSizeLarge),
    );
    if (icon == null) return label;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: Dimensions.iconSizeDefault, color: fg),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        label,
      ],
    );
  }
}