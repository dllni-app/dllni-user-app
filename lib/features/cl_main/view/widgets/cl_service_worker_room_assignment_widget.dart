import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../domain/models/cl_worker_room_assignment.dart';
import '../helpers/cl_worker_room_assignment_errors.dart';
import 'cl_service_section_card_widget.dart';

class ClServiceWorkerRoomAssignmentWidget extends StatelessWidget {
  const ClServiceWorkerRoomAssignmentWidget({
    required this.units,
    required this.numberOfWorkers,
    required this.slotByRoomKey,
    required this.onAssign,
    this.fieldErrors = const {},
    this.submittedAssignments = const [],
    super.key,
  });

  static const Color _screenBlue = Color(0xFF1E2A78);

  final List<CleaningRoomUnit> units;
  final int numberOfWorkers;
  final Map<String, int> slotByRoomKey;
  final void Function(String roomKey, int workerSlot) onAssign;
  final Map<String, List<String>> fieldErrors;
  final List<Map<String, dynamic>> submittedAssignments;

  @override
  Widget build(BuildContext context) {
    if (units.isEmpty || numberOfWorkers < 1) {
      return const SizedBox.shrink();
    }

    final roomErrorsByRoomKey = mapRoomKeyAssignmentErrors(
      fieldErrors: fieldErrors,
      submittedAssignments: submittedAssignments,
    );

    return ClServiceSectionCardWidget(
      title: 'توزيع الغرف على العمال',
      step: 0,
      showStepBadge: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bodySmall('اختر العامل المسؤول عن كل غرفة (اختياري)', color: const Color(0xFF6B7280), textAlign: TextAlign.right),
          if (_generalAssignmentErrors(fieldErrors).isNotEmpty) ...[
            const SizedBox(height: 10),
            _FieldErrorsBanner(messages: _generalAssignmentErrors(fieldErrors)),
          ],
          const SizedBox(height: 12),
          for (var i = 0; i < units.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _RoomAssignmentRow(
              unit: units[i],
              numberOfWorkers: numberOfWorkers,
              selectedSlot: slotByRoomKey[units[i].roomKey],
              roomErrors: roomErrorsByRoomKey[units[i].roomKey] ?? const [],
              onAssign: onAssign,
            ),
          ],
        ],
      ),
    );
  }
}

List<String> _generalAssignmentErrors(Map<String, List<String>> fieldErrors) {
  return fieldErrors.entries
      .where((entry) => entry.key == 'workerRoomAssignments')
      .expand((entry) => entry.value)
      .toList(growable: false);
}

class _RoomAssignmentRow extends StatelessWidget {
  const _RoomAssignmentRow({
    required this.unit,
    required this.numberOfWorkers,
    required this.selectedSlot,
    required this.roomErrors,
    required this.onAssign,
  });

  final CleaningRoomUnit unit;
  final int numberOfWorkers;
  final int? selectedSlot;
  final List<String> roomErrors;
  final void Function(String roomKey, int workerSlot) onAssign;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: roomErrors.isNotEmpty
              ? const Color(0xFFFCA5A5)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bodyMedium(unit.displayLabel, fontWeight: FontWeight.w700, textAlign: TextAlign.start),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SlotChip(label: 'بدون', isSelected: selectedSlot == null, onTap: () => onAssign(unit.roomKey, 0)),
              for (var slot = 1; slot <= numberOfWorkers; slot++) _SlotChip(label: 'عامل $slot', isSelected: selectedSlot == slot, onTap: () => onAssign(unit.roomKey, slot)),
            ],
          ),
          if (roomErrors.isNotEmpty) ...[
            const SizedBox(height: 8),
            _FieldErrorsBanner(messages: roomErrors),
          ],
        ],
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? ClServiceWorkerRoomAssignmentWidget._screenBlue : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? ClServiceWorkerRoomAssignmentWidget._screenBlue : const Color(0xFFD1D5DB)),
        ),
        child: AppText.labelMedium(label, color: isSelected ? Colors.white : const Color(0xFF1F2937), fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _FieldErrorsBanner extends StatelessWidget {
  const _FieldErrorsBanner({required this.messages});

  final List<String> messages;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: messages
            .map(
              (message) => AppText.bodySmall(
                message,
                color: const Color(0xFFB91C1C),
                textAlign: TextAlign.start,
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}
