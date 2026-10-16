import 'dart:math' as math;

/// Return a positive per-worker duration whenever the quoted service is
/// positive. Rounding to one decimal used to erase short multi-worker visits.
double effectiveCleaningWorkerDurationHours({
  required double estimatedHours,
  required int numberOfWorkers,
}) {
  if (!estimatedHours.isFinite || estimatedHours <= 0) return 0;
  final workers = math.max(1, numberOfWorkers);
  final minutes = (estimatedHours * 60 / workers).ceil();
  return math.max(1, minutes) / 60;
}

/// Returns [startTime] + [durationHours] formatted as `HH:mm`.
String formatClServiceEndTime({
  required String startTime,
  required double durationHours,
}) {
  final parts = startTime.split(':');
  if (parts.length < 2) return startTime;

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return startTime;
  if (durationHours <= 0) return startTime;

  final totalMinutes = hour * 60 + minute + (durationHours * 60).round();
  final endHour = (totalMinutes ~/ 60) % 24;
  final endMinute = totalMinutes % 60;
  return '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
}
