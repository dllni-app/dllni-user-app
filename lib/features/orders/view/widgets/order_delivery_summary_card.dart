import 'package:flutter/material.dart';

import '../../data/models/orders_api_models.dart';

class OrderDeliverySummaryCard extends StatelessWidget {
  const OrderDeliverySummaryCard({
    super.key,
    required this.order,
    this.onTrack,
  });

  final OrderResourceModel order;
  final VoidCallback? onTrack;

  @override
  Widget build(BuildContext context) {
    final summary = order.deliverySummary;

    if (summary?.enabled != true && order.deliveryOrderId == null) {
      return const SizedBox.shrink();
    }

    final label = order.deliveryStatusLabel ?? _stageLabel(summary?.status ?? summary?.currentStage ?? '');
    final stage = summary?.currentStage ?? summary?.status;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffEEF2FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffC7D2FE)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.delivery_dining,
              color: Color(0xff1E2A78),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xff1E2A78),
                    fontSize: 13,
                  ),
                ),
                if (stage != null && stage.trim().isNotEmpty)
                  Text(
                    _stageLabel(stage),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xff6B7280),
                    ),
                  ),
              ],
            ),
          ),
          if (order.deliveryOrderId != null)
            TextButton(
              onPressed: onTrack,
              child: const Text('تتبع'),
            ),
        ],
      ),
    );
  }

  String _stageLabel(String stage) {
    return switch (stage) {
      'waiting_merchant_ready' => 'بانتظار تجهيز الطلب من المتجر',
      'searching_for_driver' => 'جاري البحث عن مندوب',
      'searching_driver' => 'جاري البحث عن مندوب',
      'dispatching' => 'جاري البحث عن مندوب',
      'offered' => 'تم إرسال الطلب إلى المندوب',
      'accepted' => 'المندوب قبل الطلب',
      'in_progress' => 'المندوب في الطريق إلى المتجر',
      'driver_en_route' => 'المندوب في الطريق إلى المتجر',
      'arrived' => 'وصل المندوب',
      'arrived_pickup' => 'وصل لنقطة الاستلام',
      'handover_complete' => 'تم استلام الطلب',
      'picked_up' => 'تم استلام الطلب',
      'delivered' => 'تم التسليم',
      'completed' => 'تم التسليم',
      'cancelled' => 'تم الإلغاء',
      'not_received' => 'لم يتم الاستلام',
      _ => stage.isEmpty ? 'توصيل الطلب' : stage,
    };
  }
}
