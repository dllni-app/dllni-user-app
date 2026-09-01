import 'package:flutter/material.dart';

import '../../data/models/delivery_order_models.dart';

class DeliveryStatusStepper extends StatelessWidget {
  const DeliveryStatusStepper({
    super.key,
    required this.stages,
  });

  final List<DeliveryTimelineStageModel> stages;

  bool _hasCompletedLater(int index) {
    for (var i = index + 1; i < stages.length; i++) {
      if (stages[i].completed) return true;
    }
    return false;
  }

  bool _isSkipped(int index) {
    final stage = stages[index];
    return !stage.completed && !stage.active && _hasCompletedLater(index);
  }

  Color _nodeColor(int index) {
    final stage = stages[index];
    if (stage.completed) return const Color(0xff10B981);
    if (stage.active) return const Color(0xff1E2A78);
    if (_isSkipped(index)) return const Color(0xff6366F1);
    return const Color(0xffD1D5DB);
  }

  Color _connectorColor(int index) {
    final stage = stages[index];
    if (stage.completed) return const Color(0xff10B981);
    if (_isSkipped(index) && _hasCompletedLater(index)) {
      return const Color(0xffA5B4FC);
    }
    return const Color(0xffE5E7EB);
  }

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
            final skipped = _isSkipped(index);
            final color = _nodeColor(index);

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
                            : skipped
                                ? const Color(0xffEEF2FF)
                                : Colors.white,
                        border: Border.all(color: color, width: 2),
                      ),
                      child: stage.completed
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : skipped
                              ? Icon(Icons.more_horiz_rounded, size: 14, color: color)
                              : null,
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 32,
                        color: _connectorColor(index),
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
                                : skipped
                                    ? const Color(0xff6366F1)
                                    : const Color(0xff9CA3AF),
                          ),
                        ),
                        if (skipped)
                          const Text(
                            'تم تجاوز هذه الخطوة',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xff6366F1),
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
    final key = (stage.key ?? '').toLowerCase();
    return switch (key) {
      'waiting_merchant_ready' => 'بانتظار تجهيز الطلب من المتجر',
      'searching_for_driver' => 'جاري البحث عن مندوب',
      'searching_driver' => 'جاري البحث عن مندوب',
      'dispatching' => 'جاري البحث عن مندوب',
      'offered' => 'تم إرسال الطلب إلى المندوب',
      'accepted' => 'تم تعيين مندوب للتوصيل',
      'in_progress' => 'المندوب في الطريق إلى المطعم',
      'driver_en_route' => 'المندوب في الطريق إلى المطعم',
      'arrived' => 'وصل المندوب',
      'arrived_pickup' => 'وصل المندوب إلى المطعم',
      'handover_complete' => 'تم التسليم لمندوب التوصيل',
      'picked_up' => 'تم التسليم لمندوب التوصيل',
      'delivered' => 'تم الاستلام',
      'completed' => 'مكتمل',
      'cancelled' => 'تم الإلغاء',
      'not_received' => 'لم يتم الاستلام',
      'stopped' => 'تعذر العثور على مندوب',
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
