import 'package:flutter/material.dart';
import 'package:saathi/util/dimensions.dart';
import 'package:shimmer/shimmer.dart';

class _Box extends StatelessWidget {
  final double h;
  final double w;
  final double r;
  const _Box({required this.h, this.w = double.infinity, this.r = 8});
  @override
  Widget build(BuildContext context) => Container(
        height: h, width: w,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(r)),
      );
}

/// Grid of skeleton product cards.
class ProductGridShimmer extends StatelessWidget {
  final int count;
  const ProductGridShimmer({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlight = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade700 : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.62,
          crossAxisSpacing: Dimensions.paddingSizeSmall,
          mainAxisSpacing: Dimensions.paddingSizeSmall,
        ),
        itemBuilder: (_, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _Box(h: 120, r: 12),
            SizedBox(height: 8),
            _Box(h: 10, w: 60),
            SizedBox(height: 6),
            _Box(h: 12),
            SizedBox(height: 6),
            _Box(h: 12, w: 90),
          ],
        ),
      ),
    );
  }
}

/// Vertical list of skeleton rows.
class ProductListShimmer extends StatelessWidget {
  final int count;
  const ProductListShimmer({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlight = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade700 : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(height: Dimensions.paddingSizeSmall),
        itemBuilder: (_, _) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _Box(h: 84, w: 84, r: 8),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Box(h: 10, w: 70),
                  SizedBox(height: 8),
                  _Box(h: 12),
                  SizedBox(height: 8),
                  _Box(h: 12, w: 120),
                  SizedBox(height: 8),
                  _Box(h: 14, w: 90),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
