import 'package:flutter/material.dart';
import '../../../../core/themes/shared_platform_colors.dart';
import 'cl_service_section_card_widget.dart';

class ClServiceScheduleSectionWidget extends StatelessWidget {
  const ClServiceScheduleSectionWidget({
    required this.dayAr,
    required this.dayDate,
    required this.fromTimeController,
    required this.toTimeController,
    required this.onPickDate,
    required this.onPickFromTime,
    super.key,
  });
  final String dayAr, dayDate;
  final TextEditingController fromTimeController, toTimeController;
  final VoidCallback onPickDate, onPickFromTime;

  @override
  Widget build(BuildContext context) => ClServiceSectionCardWidget(
    title: 'الموعد والوقت',
    step: 1,
    subtitle: 'اختر تاريخ بدء الخدمة والوقت المناسب لك.',
    child: Column(
      children: [
        _PickerRow(
          key: const Key('v7_booking_date_picker'),
          label: 'تاريخ الخدمة',
          value: [dayAr, dayDate].where((e) => e.trim().isNotEmpty).join(' • '),
          icon: Icons.calendar_month_outlined,
          onTap: onPickDate,
        ),
        const SizedBox(height: 10),
        _PickerRow(
          key: const Key('v7_booking_time_picker'),
          label: 'وقت البدء',
          value: fromTimeController.text.isEmpty
              ? 'اختر الوقت'
              : fromTimeController.text,
          icon: Icons.schedule_outlined,
          onTap: onPickFromTime,
        ),
        if (toTimeController.text.trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          _PickerRow(
            label: 'وقت الانتهاء المتوقع',
            value: toTimeController.text,
            icon: Icons.timelapse_outlined,
            onTap: null,
          ),
        ],
      ],
    ),
  );
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
  });
  final String label, value;
  final IconData icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Material(
    borderRadius: BorderRadius.circular(14),
    color: const Color(0xFFF8FAFC),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E9EF)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0A7E88), size: 23),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: SharedPlatformColors.muted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: SharedPlatformColors.primary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.chevron_left_rounded,
                size: 20,
                color: SharedPlatformColors.primary,
              ),
          ],
        ),
      ),
    ),
  );
}
