import 'package:flutter/material.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/dimensions.dart';
import 'package:my_order_pro/util/styles.dart';

class BalanceCellData {
  final String label;
  final String value;
  final Color valueColor;
  const BalanceCellData(this.label, this.value, {this.valueColor = AppColors.textDark});
}

/// The Ananda 4-cell balance strip: a pale-pink row with thin pink dividers; the
/// active cell is a FULL-HEIGHT solid red block (white text) that butts against
/// the dividers — matching the real app exactly. Used on Home & Statement.
class BalanceStrip extends StatelessWidget {
  final List<BalanceCellData> cells;
  final int activeIndex;
  final double radius;
  const BalanceStrip({
    super.key,
    required this.cells,
    required this.activeIndex,
    this.radius = Dimensions.radiusMedium,
  });

  @override
  Widget build(BuildContext context) {
    const divider = Color(0xFFF3C9C9);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        color: AppColors.primaryLight,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(cells.length, (i) {
              final active = i == activeIndex;
              return Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : Colors.transparent,
                    border: (i == 0 || active || i == activeIndex + 1)
                        ? null
                        : const Border(left: BorderSide(color: divider)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(cells[i].value,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: robotoBold.copyWith(
                              color: active ? Colors.white : cells[i].valueColor,
                              fontSize: Dimensions.fontSizeSmall)),
                      const SizedBox(height: 3),
                      Text(cells[i].label,
                          maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                          style: robotoRegular.copyWith(
                              color: active ? Colors.white.withValues(alpha: 0.92) : AppColors.textMedium,
                              fontSize: 9.5)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}