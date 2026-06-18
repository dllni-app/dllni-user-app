import 'package:dllni_user_app/core/models/cleaning_gender_preference.dart';
import 'package:dllni_user_app/features/cl_main/data/models/previous_workers_response_model.dart';
import 'package:dllni_user_app/features/cl_main/view/helpers/cl_previous_workers_gender_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final rana = PreviousWorkerModel.fromJson({
    'workerId': 1,
    'name': 'رنا',
    'gender': 'male',
  });

  test('matchesGenderPreference returns true for any preference', () {
    expect(
      rana.matchesGenderPreference(CleaningGenderPreference.any),
      isTrue,
    );
  });

  test('matchesGenderPreference matches male worker to male preference', () {
    expect(
      rana.matchesGenderPreference(CleaningGenderPreference.male),
      isTrue,
    );
    expect(
      rana.matchesGenderPreference(CleaningGenderPreference.female),
      isFalse,
    );
  });

  test('filterPreviousWorkersByGender filters live previous-workers payload', () {
    final response = PreviousWorkersResponseModel.fromJson({
      'workers': [
        {
          'workerId': 1,
          'name': 'رنا',
          'gender': 'male',
        },
      ],
    });
    final workers = response.data!;

    expect(
      filterPreviousWorkersByGender(workers, CleaningGenderPreference.male),
      hasLength(1),
    );
    expect(
      filterPreviousWorkersByGender(workers, CleaningGenderPreference.female),
      isEmpty,
    );
    expect(
      filterPreviousWorkersByGender(workers, CleaningGenderPreference.any),
      hasLength(1),
    );
  });
}
