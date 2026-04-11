import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import 'order_status_node_dot.dart';
import 'order_status_segment_bar.dart';
import 'restaurant_order_status_timeline_models.dart';
import 'restaurant_order_tracking_colors.dart';

class OrderStatusStepRow extends StatelessWidget {
  const OrderStatusStepRow({super.key, required this.step, required this.index, required this.currentIndex, this.segmentTop, this.segmentBottom});

  final OrderTrackingStepVisual step;
  final int index;
  final int currentIndex;
  final OrderTrackingSegmentStyle? segmentTop;
  final OrderTrackingSegmentStyle? segmentBottom;

  OrderTrackingNodePresentation _presentation() {
    final isDone = index < currentIndex;
    final isCurrent = index == currentIndex;
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
    final isDone = index < currentIndex;
    final isCurrent = index == currentIndex;

    Color titleColor = RestaurantOrderTrackingColors.primary;
    Color subtitleColor = RestaurantOrderTrackingColors.grey;
    const mutedText = Color(0xff9CA3AF);
    if (isCurrent) {
      titleColor = RestaurantOrderTrackingColors.orange;
      subtitleColor = RestaurantOrderTrackingColors.orange;
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
                  if (step.subtitle.isNotEmpty) ...[
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
