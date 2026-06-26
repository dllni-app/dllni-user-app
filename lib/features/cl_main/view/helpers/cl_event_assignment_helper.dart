import '../../data/models/estimate_price_response_model.dart';
import '../../domain/models/cleaning_assignment_mode.dart';

class EventAssignmentFields {
  const EventAssignmentFields({
    required this.assignmentMode,
    required this.numberOfWorkers,
    this.preferredWorkerId,
  });

  final CleaningAssignmentMode assignmentMode;
  final int numberOfWorkers;
  final int? preferredWorkerId;
}

EventAssignmentFields resolveEventAssignmentFields({
  required int? selectedWorkerId,
  required int? suggestedTeamSize,
  EstimateWorkerAcceptanceModel? workerAcceptance,
}) {
  final workers = (suggestedTeamSize ?? workerAcceptance?.required ?? 1).clamp(1, 999);

  return EventAssignmentFields(
    assignmentMode: selectedWorkerId != null
        ? CleaningAssignmentMode.preferredWorker
        : CleaningAssignmentMode.openCount,
    numberOfWorkers: workers,
    preferredWorkerId: selectedWorkerId,
  );
}

int resolveSuggestedTeamSize(EstimatePriceResponseModel estimate) {
  final size = estimate.suggestedTeamSize;
  if (size != null && size > 0) return size;
  return 1;
}
