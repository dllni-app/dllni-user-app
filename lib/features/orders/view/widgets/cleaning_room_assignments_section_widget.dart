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

  final List<CleaningRoomAssignmentModel> roomAssignments;
  final List<CleaningWorkerAssignmentModel> acceptedWorkers;
  final bool isEditable;
  final bool isSaving;
  final CleaningRoomAssignmentChanged onAssignRoom;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
