import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../domain/models/cleaning_assignment_mode.dart';
import 'cl_service_section_card_widget.dart';

class ClServiceAssignmentModeSectionWidget extends StatelessWidget {
  const ClServiceAssignmentModeSectionWidget({
    required this.selectedMode,
    required this.onModeChanged,
    super.key,
  });

  static const Color _screenBlue = Color(0xFF1E2A78);

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
            'يمكنك ترك دلّني يختار العمال المناسبين، أو اختيار عامل تعاملت معه سابقاً.',
            color: const Color(0xFF6B7280),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 12),
          _ModeOption(
            label: 'دع دلّني يختار العمال',
            description:
                'الخيار الموصى به — نبحث عن الفريق المتاح والمناسب لطلبك.',
            isRecommended: true,
            isSelected: selectedMode == CleaningAssignmentMode.openCount,
            onTap: () => onModeChanged(CleaningAssignmentMode.openCount),
          ),
          const SizedBox(height: 10),
          _ModeOption(
            label: 'اختيار عامل تعاملت معه سابقاً',
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF3FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? ClServiceAssignmentModeSectionWidget._screenBlue
                : const Color(0xFFD1D5DB),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected
                  ? ClServiceAssignmentModeSectionWidget._screenBlue
                  : const Color(0xFF98A2B3),
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
                          color: const Color(0xFF1F2937),
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
                            color: const Color(0xFFE7F9FA),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'موصى به',
                            style: TextStyle(
                              color: Color(0xFF0B7480),
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
                    color: const Color(0xFF667085),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
