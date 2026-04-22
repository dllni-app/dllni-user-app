import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import 'cl_service_day_preview_card_widget.dart';
import 'cl_service_section_card_widget.dart';
import 'cl_service_time_picker_field_widget.dart';

class ClServiceScheduleSectionWidget extends StatelessWidget {
  const ClServiceScheduleSectionWidget({
    required this.dayAr,
    required this.dayDate,
    required this.fromTimeController,
    required this.toTimeController,
    required this.onPickDate,
    required this.onPickFromTime,
    required this.onPickToTime,
    super.key,
  });

  final String dayAr;
  final String dayDate;
  final TextEditingController fromTimeController;
  final TextEditingController toTimeController;
  final VoidCallback onPickDate;
  final VoidCallback onPickFromTime;
  final VoidCallback onPickToTime;

  @override
  Widget build(BuildContext context) {
    return ClServiceSectionCardWidget(
      step: 1,
      title: 'وقت و تاريخ الخدمة',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ClServiceDayPreviewCardWidget(dayAr: dayAr, dayDate: dayDate),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: onPickDate,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1E2A78),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: AppText.bodyMedium('تغيير اليوم', color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsetsDirectional.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF7F7F9), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bodyMedium('مدة الخدمة', color: const Color(0xFF656B78), fontWeight: FontWeight.w700),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClServiceTimePickerFieldWidget(title: 'من', controller: fromTimeController, onTap: onPickFromTime),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClServiceTimePickerFieldWidget(title: 'إلى', controller: toTimeController, onTap: onPickToTime),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
