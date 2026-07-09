import 'package:flutter/material.dart';

import '../../data/models/delivery_order_models.dart';

class DeliveryStatusStepper extends StatelessWidget {
  const DeliveryStatusStepper({
    super.key,
    required this.stages,
  });

  final List<DeliveryTimelineStageModel> stages;

  @override
  Widget build(BuildContext context) {
    if (stages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'حالة التوصيل',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xff1F2937),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(stages.length, (index) {
            final stage = stages[index];
            final isLast = index == stages.length - 1;
            final color = stage.completed
                ? const Color(0xff10B981)
                : stage.active
                    ? const Color(0xff1E2A78)
                    : const Color(0xffD1D5DB);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: stage.completed || stage.active
                            ? color
                            : Colors.white,
                        border: Border.all(color: color, width: 2),
                      ),
                      child: stage.completed
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 32,
                        color: stage.completed
                            ? const Color(0xff10B981)
                            : const Color(0xffE5E7EB),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _stageLabel(stage),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: stage.active ? FontWeight.w700 : FontWeight.w500,
                            color: stage.active || stage.completed
                                ? const Color(0xff1F2937)
                                : const Color(0xff9CA3AF),
                          ),
                        ),
                        if (stage.timestamp != null && stage.timestamp!.isNotEmpty)
                          Text(
                            _formatTimestamp(stage.timestamp!),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xff6B7280),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  String _stageLabel(DeliveryTimelineStageModel stage) {
    final key = stage.key ?? '';
    return switch (key) {
      'waiting_merchant_ready' => 'بانتظار تجهيز الطلب من المتجر',
      'searching_for_driver' => 'جاري البحث عن مندوب',
      'searching_driver' => 'جاري البحث عن مندوب',
      'dispatching' => 'جاري البحث عن مندوب',
      'offered' => 'تم إرسال الطلب إلى المندوب',
      'accepted' => 'المندوب قبل الطلب',
      'in_progress' => 'المندوب في الطريق إلى المتجر',
      'driver_en_route' => 'المندوب في الطريق إلى المتجر',
      'arrived' => 'وصل المندوب',
      'arrived_pickup' => 'وصل المندوب إلى المتجر',
      'handover_complete' => 'تم استلام الطلب من المتجر',
      'picked_up' => 'تم استلام الطلب من المتجر',
      'delivered' => 'تم التسليم',
      'completed' => 'تم التسليم',
      'cancelled' => 'تم الإلغاء',
      'not_received' => 'لم يتم الاستلام',
      _ => stage.label,
    };
  }

  String _formatTimestamp(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }
}
