import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../domain/models/cl_worker_room_assignment_result.dart';
import 'cl_service_section_card_widget.dart';

class ClServiceWorkerAssignmentSummaryWidget extends StatelessWidget {
  const ClServiceWorkerAssignmentSummaryWidget({
    required this.assignments,
    this.fieldErrors = const {},
    super.key,
  });

  final List<CleaningWorkerRoomAssignment> assignments;
  final Map<String, List<String>> fieldErrors;

  static const Color _screenBlue = Color(0xFF1E2A78);

  @override
  Widget build(BuildContext context) {
    final visibleAssignments = filterNonEmptyWorkerRoomAssignments(assignments);
    if (visibleAssignments.isEmpty) {
      return const SizedBox.shrink();
    }

    final generalErrors = _generalAssignmentErrors(fieldErrors);

    return ClServiceSectionCardWidget(
      title: 'خطة توزيع الغرف',
      step: 0,
      showStepBadge: false,
      subtitle: 'تمت مراجعة التوزيع من قبل النظام',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (generalErrors.isNotEmpty) ...[
            _FieldErrorsBanner(messages: generalErrors),
            const SizedBox(height: 12),
          ],
          for (var i = 0; i < visibleAssignments.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _SlotSummaryCard(
              assignment: visibleAssignments[i],
              fieldErrors: fieldErrors,
            ),
          ],
        ],
      ),
    );
  }

  static List<String> _generalAssignmentErrors(
    Map<String, List<String>> fieldErrors,
  ) {
    return fieldErrors.entries
        .where((entry) => entry.key == 'workerRoomAssignments')
        .expand((entry) => entry.value)
        .toList(growable: false);
  }
}

class _SlotSummaryCard extends StatelessWidget {
  const _SlotSummaryCard({
    required this.assignment,
    required this.fieldErrors,
  });

  final CleaningWorkerRoomAssignment assignment;
  final Map<String, List<String>> fieldErrors;

  @override
  Widget build(BuildContext context) {
    final slotErrors = _slotFieldErrors(fieldErrors, assignment.workerSlot);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: slotErrors.isNotEmpty
              ? const Color(0xFFFCA5A5)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bodyMedium(
            'العامل ${assignment.workerSlot}',
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.start,
          ),
          if (assignment.roomsWeight != null ||
              assignment.estimatedServiceShareAmount != null) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (assignment.roomsWeight != null)
                  _InfoChip(
                    label:
                        'وزن الغرف: ${assignment.roomsWeight!.toStringAsFixed(1)}',
                  ),
                if (assignment.estimatedServiceShareAmount != null)
                  _InfoChip(
                    label:
                        'تقدير الحصة: ${assignment.estimatedServiceShareAmount!.toStringAsFixed(0)}',
                  ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: assignment.rooms
                .map(
                  (room) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: ClServiceWorkerAssignmentSummaryWidget._screenBlue
                          .withAlpha(26),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: ClServiceWorkerAssignmentSummaryWidget._screenBlue
                            .withAlpha(77),
                      ),
                    ),
                    child: AppText.labelMedium(
                      _roomDisplayLabel(room),
                      color: ClServiceWorkerAssignmentSummaryWidget._screenBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                .toList(growable: false),
          ),
          if (slotErrors.isNotEmpty) ...[
            const SizedBox(height: 10),
            _FieldErrorsBanner(messages: slotErrors),
          ],
        ],
      ),
    );
  }

  static List<String> _slotFieldErrors(
    Map<String, List<String>> fieldErrors,
    int workerSlot,
  ) {
    final prefix = 'workerRoomAssignments.';
    return fieldErrors.entries
        .where((entry) {
          if (!entry.key.startsWith(prefix)) return false;
          final slotMatch = RegExp(r'^workerRoomAssignments\.(\d+)').firstMatch(
            entry.key,
          );
          if (slotMatch == null) return false;
          final slotIndex = int.tryParse(slotMatch.group(1) ?? '');
          return slotIndex != null && slotIndex + 1 == workerSlot;
        })
        .expand((entry) => entry.value)
        .toList(growable: false);
  }

  static String _roomDisplayLabel(CleaningWorkerRoomAssignmentRoom room) {
    const roomTypeLabels = {
      'bedroom': 'غرفة نوم',
      'bathroom': 'حمام',
      'kitchen': 'مطبخ',
      'living_room': 'صالون',
      'balcony': 'بلكونة',
      'corridor': 'موزع',
    };
    const roomSizeLabels = {
      'small': 'صغير',
      'medium': 'متوسط',
      'large': 'كبير',
    };

    final typeLabel = roomTypeLabels[room.roomType] ?? room.roomType;
    final sizeLabel = roomSizeLabels[room.roomSize] ?? room.roomSize;
    final parts = room.roomKey.split('.');
    final index = parts.length >= 3 ? parts.last : '';

    if (index.isEmpty) {
      return '$typeLabel - $sizeLabel';
    }
    return '$typeLabel $index - $sizeLabel';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: AppText.labelMedium(
        label,
        color: const Color(0xFF1D4ED8),
        fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: messages
            .map(
              (message) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: AppText.bodySmall(
                  message,
                  color: const Color(0xFFB91C1C),
                  textAlign: TextAlign.start,
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}
