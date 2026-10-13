import 'package:flutter/material.dart';
import '../../../../core/widgets/design_system/design_system.dart';
import '../../domain/models/cleaning_assignment_mode.dart';
import 'cl_service_section_card_widget.dart';

/// V6 worker mode; caller's BLoC retains assignment and backend pricing logic.
class ClServiceAssignmentModeSectionWidget extends StatelessWidget {
  const ClServiceAssignmentModeSectionWidget({
    required this.selectedMode,
    required this.onModeChanged,
    super.key,
  });

  final CleaningAssignmentMode selectedMode;
  final ValueChanged<CleaningAssignmentMode> onModeChanged;

  @override
  Widget build(BuildContext context) => ClServiceSectionCardWidget(
    title: 'اختيار العمال',
    step: 0,
    showStepBadge: false,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'يمكنك ترك النظام يختار العمال المناسبين، أو تفضيل عامل تعاملت معه سابقاً.',
          style: AlnadhaTokens.caption,
        ),
        const SizedBox(height: 12),
        AppChoiceTile(
          key: const Key('cleaning_assignment_open_count'),
          title: 'اختيار العمال تلقائياً',
          description: 'يبحث النظام عن العمال المتاحين وفق مهام طلبك وموعده.',
          icon: Icons.groups_outlined,
          selected: selectedMode == CleaningAssignmentMode.openCount,
          section: AppSection.cleaning,
          onTap: () => onModeChanged(CleaningAssignmentMode.openCount),
        ),
        const SizedBox(height: 10),
        AppChoiceTile(
          key: const Key('cleaning_assignment_preferred_worker'),
          title: 'عامل تعاملت معه سابقاً',
          description: 'اختر من العمال السابقين عند توفرهم في موعدك.',
          icon: Icons.person_outline,
          selected: selectedMode == CleaningAssignmentMode.preferredWorker,
          section: AppSection.cleaning,
          onTap: () => onModeChanged(CleaningAssignmentMode.preferredWorker),
        ),
      ],
    ),
  );
}
