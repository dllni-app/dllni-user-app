import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import 'order_status_node_dot.dart';
import 'order_status_segment_bar.dart';
import 'restaurant_order_status_timeline_models.dart';
import 'restaurant_order_tracking_colors.dart';

class OrderStatusStepRow extends StatelessWidget {
  const OrderStatusStepRow({
    super.key,
    required this.step,
    required this.index,
    required this.currentIndex,
    this.segmentTop,
    this.segmentBottom,
    this.visitedStepIndices,
  });

  final OrderTrackingStepVisual step;
  final int index;
  final int currentIndex;
  final OrderTrackingSegmentStyle? segmentTop;
  final OrderTrackingSegmentStyle? segmentBottom;
  final Set<int>? visitedStepIndices;

  bool get _isSkipped {
    if (index >= currentIndex) return false;
    if (visitedStepIndices == null) return false;
    return !visitedStepIndices!.contains(index);
  }

  OrderTrackingNodePresentation _presentation() {
    final isDone = index < currentIndex && !_isSkipped;
    final isCurrent = index == currentIndex;
    if (_isSkipped) {
      const skippedFg = Color(0xff6366F1);
      const skippedBg = Color(0xffEEF2FF);
      const skippedRing = Color(0xffA5B4FC);
      return const OrderTrackingNodePresentation(
        fg: skippedFg,
        bg: skippedBg,
        icon: Icons.more_horiz_rounded,
        ring: skippedRing,
        skipped: true,
      );
    }
    if (isDone) {
      return OrderTrackingNodePresentation(
        fg: Colors.white,
        bg: RestaurantOrderTrackingColors.primary,
        icon: step.icon,
        ring: RestaurantOrderTrackingColors.primary,
      );
    }
    if (isCurrent) {
      return OrderTrackingNodePresentation(
        fg: Colors.white,
        bg: RestaurantOrderTrackingColors.orange,
        icon: step.icon,
        ring: RestaurantOrderTrackingColors.orange,
      );
    }
    const muted = Color(0xff9CA3AF);
    return OrderTrackingNodePresentation(fg: muted, bg: const Color(0xffF3F4F6), icon: step.icon, ring: muted);
  }

  @override
  Widget build(BuildContext context) {
    final pres = _presentation();
    final isDone = index < currentIndex && !_isSkipped;
    final isCurrent = index == currentIndex;
    final isSkipped = _isSkipped;

    Color titleColor = RestaurantOrderTrackingColors.primary;
    Color subtitleColor = RestaurantOrderTrackingColors.grey;
    const mutedText = Color(0xff9CA3AF);
    const skippedText = Color(0xff6366F1);
    if (isCurrent) {
      titleColor = RestaurantOrderTrackingColors.orange;
      subtitleColor = RestaurantOrderTrackingColors.orange;
    } else if (isSkipped) {
      titleColor = skippedText;
      subtitleColor = skippedText;
    } else if (!isDone && !isCurrent) {
      titleColor = mutedText;
      subtitleColor = mutedText;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OrderStatusSegmentBar(height: 18, style: segmentTop),
                OrderStatusNodeDot(presentation: pres),
                OrderStatusSegmentBar(height: 22, style: segmentBottom),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 10, bottom: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.bodyMedium(step.title, color: titleColor, fontWeight: FontWeight.bold, textAlign: TextAlign.start),
                  if (isSkipped) ...[
                    const SizedBox(height: 4),
                    AppText.labelMedium('تم تجاوز هذه الخطوة', color: skippedText, textAlign: TextAlign.start),
                  ] else if (step.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    AppText.labelMedium(step.subtitle, color: subtitleColor, textAlign: TextAlign.start),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
