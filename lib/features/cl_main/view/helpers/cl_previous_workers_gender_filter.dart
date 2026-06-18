import '../../../../core/models/cleaning_gender_preference.dart';
import '../../data/models/previous_workers_response_model.dart';

extension PreviousWorkerGenderFilter on PreviousWorkerModel {
  bool matchesGenderPreference(CleaningGenderPreference preference) {
    if (preference == CleaningGenderPreference.any) {
      return true;
    }
    if (gender == null) {
      return false;
    }
    return gender == preference;
  }
}

List<PreviousWorkerModel> filterPreviousWorkersByGender(
  List<PreviousWorkerModel> workers,
  CleaningGenderPreference preference,
) {
  if (preference == CleaningGenderPreference.any) {
    return workers;
  }
  return workers
      .where((worker) => worker.matchesGenderPreference(preference))
      .toList(growable: false);
}
