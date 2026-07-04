import 'package:flutter/material.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/styles.dart';

/// SixamMart-style quantity stepper: a white rounded pill with circular
/// +/- controls (minus on a pale-pink chip, plus filled primary).
class QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool compact;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.compact = true,
  });

  @override
  Widget build(BuildContext context) {
    final double h = compact ? 30 : 40;
    final double circle = h - 6;
    return Container(
      height: h,
      padding: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _circle(Icons.remove, onDecrement, circle,
              bg: AppColors.primaryLight, fg: AppColors.primary),
          Container(
            constraints: BoxConstraints(minWidth: compact ? 22 : 30),
            alignment: Alignment.center,
            child: Text('$quantity',
                style: robotoBold.copyWith(
                    color: AppColors.textDark, fontSize: compact ? 12 : 14)),
          ),
          _circle(Icons.add, onIncrement, circle,
              bg: AppColors.primary, fg: Colors.white),
        ],
      ),
    );
  }

  Widget _circle(IconData icon, VoidCallback onTap, double size,
      {required Color bg, required Color fg}) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: fg, size: size * 0.55),
      ),
    );
  }
}

/// Empty-state "add" control on product cards: a white circle with a pink "+".
class AddCircleButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double size;
  const AddCircleButton({super.key, required this.onTap, this.size = 30});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 4),
          ],
        ),
        child: Icon(Icons.add,
            color: enabled ? AppColors.primary : AppColors.textLight,
            size: size * 0.62),
      ),
    );
  }
}
