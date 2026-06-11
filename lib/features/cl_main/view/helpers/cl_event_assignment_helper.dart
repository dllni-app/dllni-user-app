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
  if (selectedWorkerId != null) {
    return EventAssignmentFields(
      assignmentMode: CleaningAssignmentMode.preferredWorker,
      numberOfWorkers: 1,
      preferredWorkerId: selectedWorkerId,
    );
  }

  final workers = suggestedTeamSize ?? workerAcceptance?.required ?? 1;
  return EventAssignmentFields(
    assignmentMode: CleaningAssignmentMode.openCount,
    numberOfWorkers: workers < 1 ? 1 : workers,
  );
}

int resolveSuggestedTeamSize(EstimatePriceResponseModel estimate) {
  final size = estimate.suggestedTeamSize;
  if (size != null && size > 0) return size;
  return 1;
}
