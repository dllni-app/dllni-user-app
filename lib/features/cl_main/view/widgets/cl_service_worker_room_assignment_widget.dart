import 'package:dllni_user_app/core/themes/shared_platform_colors.dart';
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
          const Text(
            'وزّع الغرف إذا حبيت، أو خلي التوزيع تلقائي.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
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
      padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 8, 4),
      decoration: BoxDecoration(
        color: SharedPlatformColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: roomErrors.isNotEmpty
              ? SharedPlatformColors.danger
              : SharedPlatformColors.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.meeting_room_outlined,
                color: SharedPlatformColors.primary,
                size: 20,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  unit.displayLabel,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              SizedBox(
                width: 140,
                child: DropdownButtonFormField<int>(
                  key: Key('room_assignment_${unit.roomKey}'),
                  isExpanded: true,
                  initialValue: selectedSlot ?? 0,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(value: 0, child: Text('تلقائي')),
                    for (var slot = 1; slot <= numberOfWorkers; slot++)
                      DropdownMenuItem(value: slot, child: Text('عامل $slot')),
                  ],
                  onChanged: (slot) {
                    if (slot != null) onAssign(unit.roomKey, slot);
                  },
                ),
              ),
            ],
          ),
          if (roomErrors.isNotEmpty) _FieldErrorsBanner(messages: roomErrors),
        ],
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
