import 'package:flutter/material.dart';

import '../helpers/cleaning_event_assistance_helper.dart';
import 'v7_order_detail_components.dart';

/// Event-specific order summary. Never includes cleaning rooms or technical counts.
class V7EventOrderPanel extends StatelessWidget {
  const V7EventOrderPanel({
    super.key,
    required this.eventType,
    required this.guestCount,
    this.helpDescription,
    this.specialRequirements,
    this.onOpenSessions,
  });

  final String? eventType;
  final int? guestCount;
  final String? helpDescription;
  final String? specialRequirements;
  final VoidCallback? onOpenSessions;

  @override
  Widget build(BuildContext context) {
    final help = helpDescription?.trim();
    final special = specialRequirements?.trim();
    return V7OrderPanel(
      title: 'تفاصيل المناسبة',
      leading: const Icon(Icons.celebration_outlined),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          V7OrderInfoRow(
            label: 'نوع المناسبة',
            value: CleaningEventAssistanceHelper.eventTypeLabelAr(eventType),
          ),
          if (guestCount != null)
            V7OrderInfoRow(label: 'عدد الضيوف', value: '$guestCount'),
          if (help != null && help.isNotEmpty)
            V7OrderInfoRow(label: 'طبيعة المساعدة', value: help),
          if (special != null && special.isNotEmpty)
            V7OrderInfoRow(label: 'متطلبات إضافية', value: special),
          if (onOpenSessions != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onOpenSessions,
              icon: const Icon(Icons.event_note_outlined),
              label: const Text('عرض أيام وأوقات المناسبة'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                foregroundColor: const Color(0xFF172554),
                side: const BorderSide(color: Color(0xFFCCD7E9)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
