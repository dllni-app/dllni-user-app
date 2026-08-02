import '../../data/models/estimate_price_response_model.dart';
import '../../domain/models/cleaning_assignment_mode.dart';

class EventAssignmentFields {
  const EventAssignmentFields({
    required this.assignmentMode,
    required this.numberOfWorkers,
    this.preferredWorkerIds = const <int>[],
  });

  final CleaningAssignmentMode assignmentMode;
  final int numberOfWorkers;
  final List<int> preferredWorkerIds;

  int? get preferredWorkerId =>
      preferredWorkerIds.isEmpty ? null : preferredWorkerIds.first;
}

const int eventWorkerDailyHourLimit = 8;

int resolveMinimumEventWorkersForHours(double? hours) {
  if (hours == null || hours <= 0) return 1;
  final requiredWorkers = (hours / eventWorkerDailyHourLimit).ceil();
  return requiredWorkers < 1 ? 1 : requiredWorkers;
}

int resolveEventWorkerCountForHours({
  required double? hours,
  required int requestedWorkers,
}) {
  final safeRequestedWorkers = requestedWorkers < 1 ? 1 : requestedWorkers;
  final minimumWorkers = resolveMinimumEventWorkersForHours(hours);
  return safeRequestedWorkers < minimumWorkers
      ? minimumWorkers
      : safeRequestedWorkers;
}

EventAssignmentFields resolveEventAssignmentFields({
  List<int>? selectedWorkerIds,
  int? selectedWorkerId,
  required int? suggestedTeamSize,
  EstimateWorkerAcceptanceModel? workerAcceptance,
}) {
  final workerIds = _normalizeWorkerIds(
    selectedWorkerIds ??
        (selectedWorkerId == null ? const <int>[] : <int>[selectedWorkerId]),
  );
  final suggestedWorkers =
      (suggestedTeamSize ?? workerAcceptance?.required ?? 1).clamp(1, 999);
  final workers = suggestedWorkers < workerIds.length
      ? workerIds.length
      : suggestedWorkers;

  return EventAssignmentFields(
    assignmentMode: workerIds.length == 1
        ? CleaningAssignmentMode.preferredWorker
        : CleaningAssignmentMode.openCount,
    numberOfWorkers: workers,
    preferredWorkerIds: workerIds,
  );
}

int resolveSuggestedTeamSize(EstimatePriceResponseModel estimate) {
  final size = estimate.suggestedTeamSize;
  if (size != null && size > 0) return size;
  return 1;
}

List<int> _normalizeWorkerIds(List<int> ids) {
  final normalized = <int>[];
  for (final id in ids) {
    if (id <= 0 || normalized.contains(id)) continue;
    normalized.add(id);
  }
  return normalized;
}
