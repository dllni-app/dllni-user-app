import '../../data/models/cleaning_suite_config_model.dart';

/// Values already collected in the visible first step must not be requested
/// again by dynamic event fields, even if the backend configuration repeats it.
bool isPreviouslyCollectedGuestCount(CleaningDynamicFieldConfigModel field) {
  final key = field.key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  return const {
        'guestcount',
        'guestscount',
        'numberofguests',
        'numberofattendees',
        'attendeecount',
      }.contains(key) ||
      field.label.trim().contains('عدد الضيوف');
}

/// Reuse the venue actually chosen from dynamic admin-configured event fields.
/// Never silently replace the chosen venue with a constant apartment value.
String resolveEventVenueType(
  Map<String, dynamic> answers, {
  String fallback = 'apartment',
}) {
  for (final entry in answers.entries) {
    final key = entry.key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (key != 'venuetype' && key != 'eventvenue') continue;
    final value = entry.value?.toString().trim();
    if (value != null && value.isNotEmpty) return value;
  }
  return fallback;
}

Map<String, dynamic> mergeCollectedGuestsIntoDynamicAnswers({
  required List<CleaningDynamicFieldConfigModel> fields,
  required Map<String, dynamic> answers,
  required int guestCount,
}) {
  final result = <String, dynamic>{...answers};
  for (final field in fields) {
    if (!isPreviouslyCollectedGuestCount(field)) continue;
    result[field.key] = field.type == 'number' ? guestCount : '$guestCount';
  }
  return result;
}
