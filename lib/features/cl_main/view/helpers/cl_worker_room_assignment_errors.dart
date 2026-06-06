import 'package:common_package/common_package.dart';

Map<String, List<String>> extractWorkerRoomAssignmentFieldErrors(
  Map<String, List<String>>? fieldErrors,
) {
  if (fieldErrors == null || fieldErrors.isEmpty) {
    return const {};
  }

  return Map<String, List<String>>.fromEntries(
    fieldErrors.entries.where(
      (entry) => entry.key.startsWith('workerRoomAssignments'),
    ),
  );
}

List<String> flattenWorkerRoomAssignmentFieldErrors(
  Map<String, List<String>> fieldErrors,
) {
  return fieldErrors.values
      .expand((messages) => messages)
      .toList(growable: false);
}

Map<String, List<String>>? extractFieldErrorsFromFailure(Failure failure) {
  if (failure is ServerFailure) {
    return failure.fieldErrors;
  }
  return null;
}

Map<String, List<String>> filterWorkerRoomAssignmentFieldErrors(
  Failure failure,
) {
  return extractWorkerRoomAssignmentFieldErrors(
    extractFieldErrorsFromFailure(failure),
  );
}

Map<String, List<String>> mapRoomKeyAssignmentErrors({
  required Map<String, List<String>> fieldErrors,
  required List<Map<String, dynamic>> submittedAssignments,
}) {
  final result = <String, List<String>>{};

  for (final entry in fieldErrors.entries) {
    final match = RegExp(
      r'^workerRoomAssignments\.(\d+)\.rooms\.(\d+)\.',
    ).firstMatch(entry.key);
    if (match == null) continue;

    final slotIndex = int.tryParse(match.group(1) ?? '');
    final roomIndex = int.tryParse(match.group(2) ?? '');
    if (slotIndex == null || roomIndex == null) continue;
    if (slotIndex >= submittedAssignments.length) continue;

    final roomsRaw = submittedAssignments[slotIndex]['rooms'];
    if (roomsRaw is! List || roomIndex >= roomsRaw.length) continue;

    final roomRaw = roomsRaw[roomIndex];
    if (roomRaw is! Map) continue;

    final roomKey = roomRaw['roomKey']?.toString();
    if (roomKey == null || roomKey.isEmpty) continue;

    result.putIfAbsent(roomKey, () => <String>[]).addAll(entry.value);
  }

  return result;
}
