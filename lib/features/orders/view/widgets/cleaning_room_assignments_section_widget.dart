import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../data/models/cleaning_orders_api_models.dart';

typedef CleaningRoomAssignmentChanged =
    void Function(int roomId, int? workerId);

class CleaningRoomAssignmentsSectionWidget extends StatelessWidget {
  const CleaningRoomAssignmentsSectionWidget({
    required this.roomAssignments,
    required this.acceptedWorkers,
    required this.isEditable,
    required this.isSaving,
    required this.onAssignRoom,
    super.key,
  });

  static const Color _screenBlue = Color(0xFF1E2A78);

  final List<CleaningRoomAssignmentModel> roomAssignments;
  final List<CleaningWorkerAssignmentModel> acceptedWorkers;
  final bool isEditable;
  final bool isSaving;
  final CleaningRoomAssignmentChanged onAssignRoom;

  @override
  Widget build(BuildContext context) {
    if (roomAssignments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText.bodyMedium(
                  'توزيع الغرف',
                  color: const Color(0xFF1F2937),
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (isSaving)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 4),
          AppText.bodySmall(
            isEditable
                ? 'اضغط على أي غرفة لتعيينها لأحد العمال المقبولين'
                : 'توزيع الغرف على فريق العمل',
            color: const Color(0xFF6B7280),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < roomAssignments.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _RoomTile(
              room: roomAssignments[i],
              isEditable: isEditable && !isSaving,
              onTap: isEditable && !isSaving
                  ? () => _showWorkerPicker(context, roomAssignments[i])
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showWorkerPicker(
    BuildContext context,
    CleaningRoomAssignmentModel room,
  ) async {
    if (room.id == null) return;

    final selectedWorkerId = await showModalBottomSheet<int?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppText.bodyMedium(
                  room.displayLabel ?? 'غرفة',
                  color: const Color(0xFF1F2937),
                  fontWeight: FontWeight.w800,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                AppText.bodySmall(
                  'اختر العامل المسؤول عن هذه الغرفة',
                  color: const Color(0xFF6B7280),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (acceptedWorkers.isEmpty)
                  AppText.bodySmall(
                    'لا يوجد عمال مقبولون بعد لتعيين الغرف',
                    color: const Color(0xFF6B7280),
                    textAlign: TextAlign.center,
                  )
                else ...[
                  for (final assignment in acceptedWorkers)
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: assignment.worker?.avatarUrl == null
                            ? null
                            : NetworkImage(assignment.worker!.avatarUrl!),
                        child: assignment.worker?.avatarUrl == null
                            ? const Icon(Icons.person, size: 18)
                            : null,
                      ),
                      title: Text(
                        assignment.worker?.name ?? 'عامل',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      trailing: room.assignedWorkerId == assignment.workerId
                          ? const Icon(Icons.check_circle, color: _screenBlue)
                          : null,
                      onTap: () =>
                          Navigator.of(context).pop(assignment.workerId),
                    ),
                ],
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.person_off_outlined),
                  title: const Text('إلغاء التعيين'),
                  onTap: () => Navigator.of(context).pop(null),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!context.mounted) return;
    if (selectedWorkerId == room.assignedWorkerId) return;
    onAssignRoom(room.id!, selectedWorkerId);
  }
}

class _RoomTile extends StatelessWidget {
  const _RoomTile({
    required this.room,
    required this.isEditable,
    this.onTap,
  });

  final CleaningRoomAssignmentModel room;
  final bool isEditable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final assignedName = room.assignedWorker?.name;
    final isAssigned = assignedName != null && assignedName.isNotEmpty;

    return Material(
      color: const Color(0xFFF9FAFB),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isAssigned
                  ? const Color(0xFF0CBBC7)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.meeting_room_outlined,
                color: isAssigned
                    ? const Color(0xFF0CBBC7)
                    : const Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bodyMedium(
                      room.displayLabel ?? room.roomKey ?? 'غرفة',
                      color: const Color(0xFF1F2937),
                      fontWeight: FontWeight.w700,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    AppText.bodySmall(
                      isAssigned
                          ? 'مع: $assignedName'
                          : 'غير معيّنة',
                      color: isAssigned
                          ? const Color(0xFF047857)
                          : const Color(0xFF6B7280),
                    ),
                  ],
                ),
              ),
              if (isEditable)
                const Icon(
                  Icons.chevron_left,
                  color: Color(0xFF9CA3AF),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
