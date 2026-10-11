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
