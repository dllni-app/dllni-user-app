import 'package:flutter/material.dart';

enum OrderTrackPhase { received, preparing, onTheWay, delivered }

/// Line segment between timeline nodes (solid or dashed).
class OrderTrackingSegmentStyle {
  const OrderTrackingSegmentStyle._(this.color, {this.dashed = false});

  factory OrderTrackingSegmentStyle.solid(Color c) => OrderTrackingSegmentStyle._(c, dashed: false);
  factory OrderTrackingSegmentStyle.dashed(Color c) => OrderTrackingSegmentStyle._(c, dashed: true);

  final Color color;
  final bool dashed;
}

class OrderTrackingStepVisual {
  const OrderTrackingStepVisual({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class OrderTrackingNodePresentation {
  const OrderTrackingNodePresentation({
    required this.fg,
    required this.bg,
    required this.icon,
    required this.ring,
  });

  final Color fg;
  final Color bg;
  final IconData icon;
  final Color ring;
}
