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

  static bool _isDeliveryOrder(OrderResourceModel order) {
    final t = (order.fulfillment?.type ?? '').toLowerCase().trim();
    return t == 'delivery';
  }

  static int _mapApiStatusToStepIndex(String status, {required bool isDelivery}) {
    switch (status.toLowerCase().trim()) {
      case 'pending':
        return 0;
      case 'accepted':
        return 1;
      case 'preparing':
        return 2;
      case 'ready_for_pickup':
      case 'ready_for_delivery':
        return 3;
      case 'driver_assigned':
      case 'out_for_delivery':
      case 'on_the_way':
      case 'picked_up':
        return isDelivery ? 4 : 3;
      case 'delivered':
      case 'completed':
        return isDelivery ? 5 : 4;
      case 'cancelled':
      case 'rejected':
        return 0;
      default:
        return 0;
    }
  }

  int _currentIndex(bool isDelivery) {
    final api = tracking?.latestToStatus?.trim();
    if (api != null && api.isNotEmpty) {
      return _mapApiStatusToStepIndex(api, isDelivery: isDelivery);
    }
    return _mapApiStatusToStepIndex(order.status ?? 'pending', isDelivery: isDelivery);
  }

  List<OrderTrackingSegmentStyle> _computeBelowLines(int current, int n) {
    if (current >= n - 1) {
      return List<OrderTrackingSegmentStyle>.filled(
        n - 1,
        OrderTrackingSegmentStyle.solid(RestaurantOrderTrackingColors.primary),
      );
    }
    return List<OrderTrackingSegmentStyle>.generate(n - 1, (k) {
      if (k < current) return OrderTrackingSegmentStyle.solid(RestaurantOrderTrackingColors.primary);
      if (k == current) return OrderTrackingSegmentStyle.solid(RestaurantOrderTrackingColors.orange);
      return OrderTrackingSegmentStyle.dashed(RestaurantOrderTrackingColors.lineMuted);
    });
  }

  List<OrderTrackingStepVisual> _buildSteps(bool isDelivery) {
    const submitted = OrderTrackingStepVisual(
      title: 'تم إرسال الطلب',
      subtitle: 'بانتظار قبول المطعم',
      icon: Icons.receipt_long_outlined,
    );
    const accepted = OrderTrackingStepVisual(
      title: 'تم قبول الطلب',
      subtitle: 'وافق المطعم على طلبك',
      icon: Icons.check_circle_outline,
    );
    const preparing = OrderTrackingStepVisual(
      title: 'جاري تجهيز الطلب',
      subtitle: 'المطعم يقوم بتجهيز طلبك',
      icon: Icons.restaurant,
    );
    const readyPickup = OrderTrackingStepVisual(
      title: 'جاهز للاستلام',
      subtitle: 'يمكن استلام الطلب من المطعم',
      icon: Icons.storefront_outlined,
    );
    const readyDelivery = OrderTrackingStepVisual(
      title: 'جاهز للتوصيل',
      subtitle: 'بانتظار استلام المندوب للطلب',
      icon: Icons.inventory_2_outlined,
    );
    const driver = OrderTrackingStepVisual(
      title: 'تم التسليم لمندوب التوصيل',
      subtitle: 'الطلب أصبح في الطريق إليك',
      icon: Icons.two_wheeler,
    );
    const completed = OrderTrackingStepVisual(
      title: 'مكتمل',
      subtitle: 'اكتمل الطلب بنجاح',
      icon: Icons.done_all_rounded,
    );

    if (isDelivery) {
      return const [submitted, accepted, preparing, readyDelivery, driver, completed];
    }
    return const [submitted, accepted, preparing, readyPickup, completed];
  }

  Set<int> _visitedStepIndices(bool isDelivery) {
    final visited = <int>{};
    for (final item in tracking?.timeline ?? const []) {
      final status = item.toStatus;
      if (status != null && status.isNotEmpty) {
        visited.add(_mapApiStatusToStepIndex(status, isDelivery: isDelivery));
      }
    }
    return visited;
  }

  @override
  Widget build(BuildContext context) {
    final isDelivery = _isDeliveryOrder(order);
    final steps = _buildSteps(isDelivery);
    final current = _currentIndex(isDelivery).clamp(0, steps.length - 1);
    final visited = tracking?.timeline.isNotEmpty == true
        ? _visitedStepIndices(isDelivery)
        : null;
    final n = steps.length;
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
              visitedStepIndices: visited,
            );
          }),
        ],
      ),
    );
  }
}
