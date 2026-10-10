import 'package:dllni_user_app/core/themes/shared_platform_colors.dart';
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
    super.key,
  });

  final String dayAr;
  final String dayDate;
  final TextEditingController fromTimeController;
  final TextEditingController toTimeController;
  final VoidCallback onPickDate;
  final VoidCallback onPickFromTime;

  @override
  Widget build(BuildContext context) {
    return ClServiceSectionCardWidget(
      step: 1,
      title: 'موعد الخدمة',
      subtitle:
          'حدد اليوم ووقت البدء، وسنوضح وقت الانتهاء المتوقع حسب مدة الخدمة.',
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final preview = ClServiceDayPreviewCardWidget(
                dayAr: dayAr,
                dayDate: dayDate,
              );
              final changeDate = FilledButton(
                onPressed: onPickDate,
                style: FilledButton.styleFrom(
                  backgroundColor: SharedPlatformColors.cleaningSoft,
                  foregroundColor: SharedPlatformColors.cleaningInk,
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: AppText.bodyMedium(
                  'تغيير اليوم',
                  color: SharedPlatformColors.cleaningInk,
                  fontWeight: FontWeight.w800,
                ),
              );
              if (constraints.maxWidth < 300) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    preview,
                    const SizedBox(height: 10),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: changeDate,
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: preview),
                  const SizedBox(width: 10),
                  changeDate,
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsetsDirectional.all(12),
            decoration: BoxDecoration(
              color: SharedPlatformColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bodyMedium(
                  'وقت البداية والانتهاء',
                  color: const Color(0xFF656B78),
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final fromField = ClServiceTimePickerFieldWidget(
                      title: 'من',
                      controller: fromTimeController,
                      onTap: onPickFromTime,
                    );
                    final toField = ClServiceTimePickerFieldWidget(
                      title: 'إلى',
                      controller: toTimeController,
                    );

                    // Preserve a compact, readable two-column layout on
                    // typical phones; narrow devices still stack the fields.
                    if (constraints.maxWidth >= 280) {
                      return Row(
                        children: [
                          Expanded(child: fromField),
                          const SizedBox(width: 10),
                          Expanded(child: toField),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        fromField,
                        const SizedBox(height: 12),
                        toField,
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
