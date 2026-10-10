import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/shared_platform_colors.dart';
import '../../domain/models/cleaning_assignment_mode.dart';
import 'cl_service_section_card_widget.dart';

class ClServiceAssignmentModeSectionWidget extends StatelessWidget {
  const ClServiceAssignmentModeSectionWidget({
    required this.selectedMode,
    required this.onModeChanged,
    super.key,
  });

  final CleaningAssignmentMode selectedMode;
  final ValueChanged<CleaningAssignmentMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return ClServiceSectionCardWidget(
      title: 'اختيار العمال',
      step: 0,
      showStepBadge: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bodySmall(
            'يمكنك ترك ع الندهة يختار العمال المناسبين، أو اختيار عامل تعاملت معه سابقاً.',
            color: SharedPlatformColors.muted,
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 12),
          _ModeOption(
            label: 'اختيار العمال تلقائياً',
            description:
                'الخيار الموصى به — نبحث عن الفريق المتاح والمناسب لطلبك.',
            isRecommended: true,
            isSelected: selectedMode == CleaningAssignmentMode.openCount,
            onTap: () => onModeChanged(CleaningAssignmentMode.openCount),
          ),
          const SizedBox(height: 10),
          _ModeOption(
            label: 'عامل تعاملت معه سابقاً',
            description: 'اختر من العمال السابقين المتاحين في موعدك.',
            isSelected: selectedMode == CleaningAssignmentMode.preferredWorker,
            onTap: () => onModeChanged(CleaningAssignmentMode.preferredWorker),
          ),
        ],
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
    this.isRecommended = false,
  });

  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isRecommended;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: isSelected
            ? const Color(0xFFF0F3FC)
            : SharedPlatformColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected
                ? SharedPlatformColors.primary
                : SharedPlatformColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isSelected
                      ? SharedPlatformColors.primary
                      : SharedPlatformColors.muted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AppText.bodyMedium(
                              label,
                              color: SharedPlatformColors.ink,
                              fontWeight: FontWeight.w800,
                              textAlign: TextAlign.start,
                            ),
                          ),
                          if (isRecommended)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: SharedPlatformColors.cleaningSoft,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'موصى به',
                                style: TextStyle(
                                  color: SharedPlatformColors.cleaningInk,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      AppText.bodySmall(
                        description,
                        color: SharedPlatformColors.muted,
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
