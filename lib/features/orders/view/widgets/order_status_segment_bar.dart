import 'package:flutter/material.dart';

import 'order_status_dashed_line_painter.dart';
import 'restaurant_order_status_timeline_models.dart';

class OrderStatusSegmentBar extends StatelessWidget {
  const OrderStatusSegmentBar({super.key, required this.height, required this.style});

  final double height;
  final OrderTrackingSegmentStyle? style;

  @override
  Widget build(BuildContext context) {
    if (style == null) return SizedBox(height: height);
    if (style!.dashed) {
      return SizedBox(
        height: height,
        width: 3,
        child: CustomPaint(painter: OrderStatusDashedLinePainter(color: style!.color, strokeWidth: 3)),
      );
    }
    return Container(
      width: 3,
      height: height,
      decoration: BoxDecoration(color: style!.color, borderRadius: BorderRadius.circular(2)),
    );
  }
}
