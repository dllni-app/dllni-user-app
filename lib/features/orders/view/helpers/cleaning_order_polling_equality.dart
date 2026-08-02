import '../../data/models/cleaning_orders_api_models.dart';

bool _nullableEquals<T>(T? a, T? b) => a == b;

bool _workerAcceptanceEquals(
  CleaningWorkerAcceptanceModel? a,
  CleaningWorkerAcceptanceModel? b,
) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  return a.required == b.required &&
      a.accepted == b.accepted &&
      a.remaining == b.remaining &&
      a.isFulfilled == b.isFulfilled;
}

bool _intListEquals(List<int>? a, List<int>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null || a.length != b.length) return false;
  for (var index = 0; index < a.length; index++) {
    if (a[index] != b[index]) return false;
  }
  return true;
}

bool _workerAssignmentEquals(
  CleaningWorkerAssignmentModel a,
  CleaningWorkerAssignmentModel b,
) {
  return a.id == b.id &&
      a.workerId == b.workerId &&
      a.status == b.status &&
      a.acceptedAt == b.acceptedAt &&
      a.roomCount == b.roomCount &&
      a.roomsWeight == b.roomsWeight &&
      a.serviceShareAmount == b.serviceShareAmount &&
      a.travelFee == b.travelFee &&
      a.adminMarginAmount == b.adminMarginAmount &&
      a.workerAmount == b.workerAmount &&
      a.currency == b.currency &&
      _intListEquals(a.roomIds, b.roomIds) &&
      a.worker?.id == b.worker?.id &&
      a.worker?.name == b.worker?.name &&
      a.worker?.phone == b.worker?.phone &&
      a.worker?.averageRating == b.worker?.averageRating &&
      a.worker?.avatarUrl == b.worker?.avatarUrl;
}

bool _workerAssignmentsEqual(
  List<CleaningWorkerAssignmentModel>? a,
  List<CleaningWorkerAssignmentModel>? b,
) {
  if (identical(a, b)) return true;
  if (a == null || b == null || a.length != b.length) return false;

  final byId = <int, CleaningWorkerAssignmentModel>{
    for (final assignment in b)
      if (assignment.id != null) assignment.id!: assignment,
  };

  for (var index = 0; index < a.length; index++) {
    final assignment = a[index];
    final other = assignment.id == null ? b[index] : byId[assignment.id];
    if (other == null || !_workerAssignmentEquals(assignment, other)) {
      return false;
    }
  }
  return true;
}

bool cleaningOrderListDisplayEquals(
  CleaningOrderModel a,
  CleaningOrderModel b,
) {
  return _nullableEquals(a.id, b.id) &&
      _nullableEquals(a.bookingNumber, b.bookingNumber) &&
      _nullableEquals(a.status, b.status) &&
      _nullableEquals(a.propertyType, b.propertyType) &&
      _nullableEquals(a.totalPrice, b.totalPrice) &&
      _nullableEquals(a.scheduledDate, b.scheduledDate) &&
      _nullableEquals(a.scheduledTime, b.scheduledTime) &&
      _nullableEquals(a.assignmentMode, b.assignmentMode) &&
      _nullableEquals(
        a.convertedFromPreferredWorker,
        b.convertedFromPreferredWorker,
      ) &&
      _nullableEquals(
        a.convertedFromPreferredWorkerAt,
        b.convertedFromPreferredWorkerAt,
      ) &&
      _nullableEquals(a.numberOfWorkers, b.numberOfWorkers) &&
      _workerAcceptanceEquals(a.workerAcceptance, b.workerAcceptance);
}

bool cleaningOrderDetailDisplayEquals(
  CleaningOrderDetailModel a,
  CleaningOrderDetailModel b,
) {
  return _nullableEquals(a.id, b.id) &&
      _nullableEquals(a.bookingNumber, b.bookingNumber) &&
      _nullableEquals(a.status, b.status) &&
      _nullableEquals(a.propertyType, b.propertyType) &&
      _nullableEquals(a.locationName, b.locationName) &&
      _nullableEquals(a.addressLatitude, b.addressLatitude) &&
      _nullableEquals(a.addressLongitude, b.addressLongitude) &&
      _nullableEquals(a.scheduledDate, b.scheduledDate) &&
      _nullableEquals(a.scheduledTime, b.scheduledTime) &&
      _nullableEquals(a.totalPrice, b.totalPrice) &&
      _nullableEquals(a.basePrice, b.basePrice) &&
      _nullableEquals(a.travelFee, b.travelFee) &&
      _nullableEquals(a.isPricingFinal, b.isPricingFinal) &&
      _nullableEquals(a.addonsTotal, b.addonsTotal) &&
      _nullableEquals(a.assignmentMode, b.assignmentMode) &&
      _nullableEquals(
        a.convertedFromPreferredWorker,
        b.convertedFromPreferredWorker,
      ) &&
      _nullableEquals(
        a.convertedFromPreferredWorkerAt,
        b.convertedFromPreferredWorkerAt,
      ) &&
      _nullableEquals(a.numberOfWorkers, b.numberOfWorkers) &&
      _nullableEquals(a.workerId, b.workerId) &&
      _nullableEquals(a.startedTravelAt, b.startedTravelAt) &&
      _nullableEquals(a.arrivedAt, b.arrivedAt) &&
      _nullableEquals(a.workStartedAt, b.workStartedAt) &&
      _nullableEquals(a.workFinishedAt, b.workFinishedAt) &&
      _nullableEquals(a.worker?.id, b.worker?.id) &&
      _nullableEquals(a.worker?.name, b.worker?.name) &&
      _nullableEquals(a.worker?.phone, b.worker?.phone) &&
      _nullableEquals(a.worker?.averageRating, b.worker?.averageRating) &&
      _nullableEquals(a.worker?.avatarUrl, b.worker?.avatarUrl) &&
      _nullableEquals(a.preferredWorker?.id, b.preferredWorker?.id) &&
      _workerAcceptanceEquals(a.workerAcceptance, b.workerAcceptance) &&
      _workerAssignmentsEqual(a.workerAssignments, b.workerAssignments) &&
      _nullableEquals(a.roomAssignments?.length, b.roomAssignments?.length) &&
      _nullableEquals(a.propertyDetails?.address, b.propertyDetails?.address);
}

List<CleaningOrderModel> mergeCleaningOrdersSilentPage1({
  required List<CleaningOrderModel> current,
  required List<CleaningOrderModel> fetched,
  required int perPage,
}) {
  final existingById = <int, CleaningOrderModel>{
    for (final order in current)
      if (order.id != null) order.id!: order,
  };

  final mergedPage1 = fetched
      .map((fresh) {
        final id = fresh.id;
        if (id == null) return fresh;
        final existing = existingById[id];
        if (existing != null &&
            cleaningOrderListDisplayEquals(existing, fresh)) {
          return existing;
        }
        return fresh;
      })
      .toList(growable: false);

  if (current.length <= perPage) {
    return mergedPage1;
  }

  return [...mergedPage1, ...current.skip(perPage)];
}

bool cleaningOrderListsReferentiallyEqual(
  List<CleaningOrderModel> a,
  List<CleaningOrderModel> b,
) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (!identical(a[i], b[i])) return false;
  }
  return true;
}
