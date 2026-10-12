import 'package:flutter/material.dart';
import '../../../../core/themes/shared_platform_colors.dart';
import '../../data/models/cleaning_orders_api_models.dart';
import 'v7_order_detail_components.dart';

typedef CleaningRoomAssignmentChanged =
    void Function(int roomId, int? workerId);

/// Pen V7 task/room assignment. Server determines editable status and
/// validates saved assignment. No optimistic local assignment is performed.
class CleaningRoomAssignmentsSectionWidget extends StatelessWidget {
  const CleaningRoomAssignmentsSectionWidget({
    super.key,
    required this.roomAssignments,
    required this.acceptedWorkers,
    required this.isEditable,
    required this.isSaving,
    required this.onAssignRoom,
  });
  final List<CleaningRoomAssignmentModel> roomAssignments;
  final List<CleaningWorkerAssignmentModel> acceptedWorkers;
  final bool isEditable, isSaving;
  final CleaningRoomAssignmentChanged onAssignRoom;

  String _workerLabel(int? id) {
    if (id == null) return 'لم يُحدد عامل بعد';
    for (final entry in acceptedWorkers) {
      if (entry.workerId == id) {
        final name = entry.worker?.name?.trim();
        return name == null || name.isEmpty ? 'العامل #$id' : name;
      }
    }
    return 'عامل ضمن الفريق';
  }

  @override
  Widget build(BuildContext context) {
    if (roomAssignments.isEmpty) return const SizedBox.shrink();
    final editable =
        isEditable &&
        !isSaving &&
        acceptedWorkers.any(
          (entry) => entry.workerId != null && entry.workerId! > 0,
        );
    return V7OrderPanel(
      title: 'المهام والغرف',
      subtitle: editable
          ? 'يمكنك تحديد العامل المناسب لكل غرفة.'
          : 'تفاصيل توزيع العمل في طلبك.',
      trailing: isSaving
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      child: Column(
        children: [
          for (var i = 0; i < roomAssignments.length; i++) ...[
            if (i > 0) const Divider(height: 20, color: Color(0xFFE6E9EF)),
            _RoomAssignmentRow(
              room: roomAssignments[i],
              worker: _workerLabel(roomAssignments[i].assignedWorkerId),
              editable: editable && roomAssignments[i].id != null,
              acceptedWorkers: acceptedWorkers,
              onChange: (workerId) {
                final roomId = roomAssignments[i].id;
                if (roomId != null) onAssignRoom(roomId, workerId);
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _RoomAssignmentRow extends StatelessWidget {
  const _RoomAssignmentRow({
    required this.room,
    required this.worker,
    required this.editable,
    required this.acceptedWorkers,
    required this.onChange,
  });
  final CleaningRoomAssignmentModel room;
  final String worker;
  final bool editable;
  final List<CleaningWorkerAssignmentModel> acceptedWorkers;
  final ValueChanged<int?> onChange;

  @override
  Widget build(BuildContext context) {
    final label = room.localizedDisplayLabel;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: SharedPlatformColors.cleaningSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.meeting_room_outlined,
            color: Color(0xFF087D83),
            size: 21,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: SharedPlatformColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                worker,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: SharedPlatformColors.muted,
                ),
              ),
            ],
          ),
        ),
        if (editable)
          PopupMenuButton<int>(
            tooltip: 'تحديد العامل',
            icon: const Icon(
              Icons.edit_outlined,
              color: SharedPlatformColors.primary,
            ),
            onSelected: (id) => onChange(id == 0 ? null : id),
            itemBuilder: (context) => [
              const PopupMenuItem<int>(value: 0, child: Text('دون تعيين')),
              for (final assignment in acceptedWorkers)
                if (assignment.workerId != null)
                  PopupMenuItem<int>(
                    value: assignment.workerId,
                    child: Text(
                      (assignment.worker?.name?.trim().isNotEmpty ?? false)
                          ? assignment.worker!.name!
                          : 'العامل #${assignment.workerId}',
                    ),
                  ),
            ],
          ),
      ],
    );
  }
}
