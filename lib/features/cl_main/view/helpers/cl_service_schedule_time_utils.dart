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
