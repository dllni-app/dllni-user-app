import 'package:flutter/material.dart';

import 'restaurant_order_status_timeline_models.dart';

class OrderStatusNodeDot extends StatelessWidget {
  const OrderStatusNodeDot({super.key, required this.presentation});

  final OrderTrackingNodePresentation presentation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: presentation.bg,
        shape: BoxShape.circle,
        border: Border.all(color: presentation.ring, width: 2),
        boxShadow: [BoxShadow(color: presentation.bg.withAlpha(60), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Icon(presentation.icon, size: 18, color: presentation.fg),
    );
  }
}
