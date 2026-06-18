import 'package:dllni_user_app/features/delivery/presentation/widgets/delivery_driver_card.dart';
import 'package:dllni_user_app/features/delivery/presentation/widgets/delivery_status_stepper.dart';
import 'package:dllni_user_app/features/delivery/presentation/widgets/delivery_tracking_map.dart';
import 'package:dllni_user_app/features/profile/view/widgets/personal_details_app_bar.dart';
import 'package:flutter/material.dart';

import '../../../delivery/data/models/delivery_order_models.dart';
import '../../data/models/orders_api_models.dart';
import 'restaurant_order_details_card.dart';
import 'restaurant_order_eta_card.dart';
import 'restaurant_order_number_chip.dart';
import 'restaurant_order_sos_sheet.dart';
import 'restaurant_order_status_stepper.dart';
import 'restaurant_order_tracking_map_section.dart';
import 'restaurant_tracking_restaurant_info_card.dart';

class RestaurantOrderTrackingView extends StatelessWidget {
  const RestaurantOrderTrackingView({
    super.key,
    required this.order,
    this.tracking,
    this.deliveryOrder,
    this.isLoading = false,
    this.loadError,
    this.onRetry,
  });

  final OrderResourceModel order;
  final RestaurantOrderTrackingDataModel? tracking;
  final DeliveryOrderModel? deliveryOrder;
  final bool isLoading;
  final String? loadError;
  final VoidCallback? onRetry;

  String _money(double v) => '${v.toStringAsFixed(0)} ل.س';

  String _etaLabel() {
    if (deliveryOrder != null && deliveryOrder!.etaLabel.isNotEmpty) {
      return deliveryOrder!.etaLabel;
    }
    final eta = tracking?.eta;
    if (eta != null) {
      if (eta.text.isNotEmpty) return eta.text;
      if (eta.minutes > 0) return '${eta.minutes} دقيقة';
    }
    final scheduled = order.fulfillment?.scheduledAt;
    if (scheduled != null && scheduled.isNotEmpty) {
      return scheduled;
    }
    return '30 — 40 دقيقة';
  }

  @override
  Widget build(BuildContext context) {
    final amounts = order.amounts;
    final subtotal = amounts?.subtotal ?? 0;
    final deliveryFee = amounts?.serviceFee ?? 0;
    final total = amounts?.total ?? subtotal + deliveryFee;

    final merchantName =
        tracking?.merchant?.name ?? order.merchant?.name ?? 'المطعم';
    final merchantImage = tracking?.merchant?.primaryImageUrl;
    final deliveryTracking = deliveryOrder?.tracking;
    final deliveryDriver = deliveryTracking?.driver ?? deliveryOrder?.driver;
    final deliveryStages = deliveryTracking?.stages.isNotEmpty == true
        ? deliveryTracking!.stages
        : deliveryTracking?.timeline ?? deliveryOrder?.timeline ?? const [];

    return Column(
      children: [
        PersonalDetailsAppBar(title: 'تتبع الطلب'),
        if (loadError != null)
          Material(
            color: const Color(0xffFEF2F2),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      loadError!,
                      style: const TextStyle(
                        color: Color(0xff991B1B),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (onRetry != null)
                    TextButton(
                      onPressed: onRetry,
                      child: const Text('إعادة المحاولة'),
                    ),
                ],
              ),
            ),
          ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RestaurantOrderNumberChip(
                        orderNumber: order.orderNumber ?? '—',
                      ),
                      const SizedBox(height: 12),
                      RestaurantOrderEtaCard(etaText: _etaLabel()),
                      if (deliveryTracking?.map != null &&
                          deliveryTracking!.map!.enabled) ...[
                        const SizedBox(height: 14),
                        DeliveryTrackingMap(map: deliveryTracking.map!),
                      ] else if (tracking?.map?.enabled == true) ...[
                        const SizedBox(height: 14),
                        RestaurantOrderTrackingMapSection(map: tracking!.map!),
                      ],
                      const SizedBox(height: 14),
                      if (deliveryStages.isNotEmpty)
                        DeliveryStatusStepper(stages: deliveryStages)
                      else
                        RestaurantOrderStatusStepper(
                          order: order,
                          tracking: tracking,
                        ),
                      if (deliveryDriver != null) ...[
                        const SizedBox(height: 14),
                        DeliveryDriverCard(driver: deliveryDriver),
                      ],
                      const SizedBox(height: 14),
                      RestaurantTrackingRestaurantInfoCard(
                        name: merchantName,
                        imageUrl: merchantImage,
                        onCall: () => _showSoon(context),
                      ),
                      const SizedBox(height: 14),
                      RestaurantOrderDetailsCard(
                        items: order.items,
                        subtotal: subtotal,
                        deliveryFee: deliveryFee,
                        total: total,
                        money: _money,
                      ),
                      if (order.id != null) ...[
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: () => RestaurantOrderSosSheet.show(
                            context,
                            orderId: order.id!,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xffDC2626),
                            side: const BorderSide(color: Color(0xffDC2626)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.sos_outlined),
                          label: const Text(
                            'طلب SOS',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  static void _showSoon(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('قريباً')));
  }
}
