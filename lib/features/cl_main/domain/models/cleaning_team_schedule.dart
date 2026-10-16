import 'cleaning_booking_draft.dart';

/// Converts a customer-selected team size into schedulable per-room assignments.
/// Unlike room-count based assignment, one worker can clean several rooms
/// consecutively and several workers can clean the same room together.
CleaningBookingDraft planCleaningTeam(
  CleaningBookingDraft draft, {
  required int workerCount,
}) {
  if (workerCount < 1) throw ArgumentError.value(workerCount, 'workerCount');
  if (draft.schedules.isEmpty) return draft;
  final updated = <RoomScheduleDraft>[];
  final visits = draft.schedules.map((s) => s.visitKey).toSet();
  for (final visit in visits) {
    final rooms = draft.schedules.where((s) => s.visitKey == visit).toList();
    final start = rooms
        .map((s) => s.start)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final durations = [for (final s in rooms) s.workMinutes ?? 60];
    if (workerCount >= rooms.length) {
      final workers = List<int>.filled(rooms.length, 1);
      for (var extra = rooms.length; extra < workerCount; extra++) {
        var heaviest = 0;
        for (var i = 1; i < rooms.length; i++) {
          if (durations[i] / workers[i] >
              durations[heaviest] / workers[heaviest]) {
            heaviest = i;
          }
        }
        workers[heaviest]++;
      }
      for (var i = 0; i < rooms.length; i++) {
        updated.add(rooms[i].copyWith(start: start, workers: workers[i]));
      }
    } else {
      final laneEnds = List<int>.filled(workerCount, 0);
      for (var i = 0; i < rooms.length; i++) {
        var freeLane = 0;
        for (var lane = 1; lane < workerCount; lane++) {
          if (laneEnds[lane] < laneEnds[freeLane]) freeLane = lane;
        }
        updated.add(
          rooms[i].copyWith(
            start: start.add(Duration(minutes: laneEnds[freeLane])),
            workers: 1,
          ),
        );
        laneEnds[freeLane] += durations[i];
      }
    }
  }
  var planned = draft;
  for (final schedule in updated) {
    planned = planned.replaceSchedule(schedule);
  }
  return planned;
}

/// The complete job's elapsed wall-clock duration, not sum of worker-hours.
int? cleaningTeamDurationMinutes(CleaningBookingDraft draft) {
  final schedules = draft.schedules
      .where((s) => s.visitKey == 'visit.1')
      .toList();
  if (schedules.isEmpty || schedules.any((s) => s.end == null)) return null;
  final first = schedules
      .map((s) => s.start)
      .reduce((a, b) => a.isBefore(b) ? a : b);
  final last = schedules
      .map((s) => s.end!)
      .reduce((a, b) => a.isAfter(b) ? a : b);
  return last.difference(first).inMinutes;
}
