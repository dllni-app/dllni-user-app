import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../data/models/orders_api_models.dart';
import 'order_status_step_row.dart';
import 'restaurant_order_status_timeline_models.dart';
import 'restaurant_order_tracking_colors.dart';

class RestaurantOrderStatusStepper extends StatelessWidget {
  const RestaurantOrderStatusStepper({super.key, required this.order, this.tracking});

  final OrderResourceModel order;
  final RestaurantOrderTrackingDataModel? tracking;

  static int _mapApiStatusToStepIndex(String status) {
    switch (status) {
      case 'pending':
        return 0;
      case 'accepted':
      case 'preparing':
        return 1;
      case 'ready_for_pickup':
      case 'ready_for_delivery':
      case 'out_for_delivery':
      case 'on_the_way':
      case 'driver_assigned':
        return 2;
      case 'picked_up':
      case 'completed':
      case 'delivered':
        return 3;
      case 'cancelled':
      case 'rejected':
        return 0;
      default:
        return 1;
    }
  }

  OrderTrackPhase _phaseFromOrderOnly() {
    final raw = (order.status ?? order.statusLabel ?? '').toLowerCase();
    if (raw.contains('deliver') && (raw.contains('تم') || raw.contains('complete') || raw == 'delivered')) {
      return OrderTrackPhase.delivered;
    }
    if (raw.contains('delivered') || raw.contains('complete') || raw.contains('done') || raw.contains('سلم')) {
      return OrderTrackPhase.delivered;
    }
    if (raw.contains('way') || raw.contains('driver') || raw.contains('transit') || raw.contains('pickup') || raw.contains('طريق')) {
      return OrderTrackPhase.onTheWay;
    }
    if (raw.contains('prepar') || raw.contains('kitchen') || raw.contains('cooking') || raw.contains('جهز') || raw.contains('تحضير')) {
      return OrderTrackPhase.preparing;
    }
    if (raw.contains('received') || raw.contains('confirm') || raw.contains('placed') || raw.contains('قبول') || raw.contains('استلام')) {
      return OrderTrackPhase.received;
    }
    return OrderTrackPhase.onTheWay;
  }

  int get _currentIndex {
    final api = tracking?.latestToStatus;
    if (api != null && api.isNotEmpty) {
      return _mapApiStatusToStepIndex(api);
    }
    switch (_phaseFromOrderOnly()) {
      case OrderTrackPhase.received:
        return 0;
      case OrderTrackPhase.preparing:
        return 1;
      case OrderTrackPhase.onTheWay:
        return 2;
      case OrderTrackPhase.delivered:
        return 3;
    }
  }

  /// Line between node `k` and `k + 1` (length `n - 1`).
  List<OrderTrackingSegmentStyle> _computeBelowLines(int current, int n) {
    if (current >= n - 1) {
      return List<OrderTrackingSegmentStyle>.filled(n - 1, OrderTrackingSegmentStyle.solid(RestaurantOrderTrackingColors.primary));
    }
    return List<OrderTrackingSegmentStyle>.generate(n - 1, (k) {
      if (k < current) return OrderTrackingSegmentStyle.solid(RestaurantOrderTrackingColors.primary);
      if (k == current) return OrderTrackingSegmentStyle.solid(RestaurantOrderTrackingColors.orange);
      return OrderTrackingSegmentStyle.dashed(RestaurantOrderTrackingColors.lineMuted);
    });
  }

  List<OrderTrackingStepVisual> _buildSteps() {
    return const [
      OrderTrackingStepVisual(title: 'تم استلام الطلب', subtitle: 'تم إرسال الطلب للمطعم', icon: Icons.check),
      OrderTrackingStepVisual(title: 'جاري تحضير الطلب', subtitle: 'المطعم يقوم بتجهيز طلبك', icon: Icons.restaurant),
      OrderTrackingStepVisual(title: 'السائق في الطريق', subtitle: 'السائق يتجه إليك الآن', icon: Icons.two_wheeler),
      OrderTrackingStepVisual(title: 'تم تسليم الطلب', subtitle: '', icon: Icons.home_outlined),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps();
    final current = _currentIndex;
    const n = 4;
    final below = _computeBelowLines(current, n);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText.titleMedium('حالة الطلب', color: RestaurantOrderTrackingColors.primary, fontWeight: FontWeight.bold, textAlign: TextAlign.start),
          const SizedBox(height: 16),
          ...List.generate(n, (i) {
            final isLast = i == n - 1;
            return OrderStatusStepRow(
              step: steps[i],
              index: i,
              currentIndex: current,
              segmentTop: i > 0 ? below[i - 1] : null,
              segmentBottom: !isLast ? below[i] : null,
            );
          }),
        ],
      ),
    );
  }
}
