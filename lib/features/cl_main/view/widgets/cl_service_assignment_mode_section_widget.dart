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
      title: 'طريقة تعيين العمال',
      step: 0,
      showStepBadge: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bodySmall(
            'اختر إما عامل مفضل واحد أو فريق عمل بعدد محدد',
            color: const Color(0xFF6B7280),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ModeOption(
                  label: 'عامل/ة',
                  isSelected:
                      selectedMode == CleaningAssignmentMode.preferredWorker,
                  onTap: () =>
                      onModeChanged(CleaningAssignmentMode.preferredWorker),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ModeOption(
                  label: 'فريق عمل',
                  isSelected: selectedMode == CleaningAssignmentMode.openCount,
                  onTap: () => onModeChanged(CleaningAssignmentMode.openCount),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? ClServiceAssignmentModeSectionWidget._screenBlue
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? ClServiceAssignmentModeSectionWidget._screenBlue
                : const Color(0xFFD1D5DB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: AppText.bodyMedium(
            label,
            color: isSelected ? Colors.white : const Color(0xFF1F2937),
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
