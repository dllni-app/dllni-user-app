import 'package:dllni_user_app/core/models/cleaning_gender_preference.dart';
import 'package:dllni_user_app/features/cl_main/data/models/previous_workers_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PreviousWorkerModel parses gender from common API fields', () {
    final maleWorker = PreviousWorkerModel.fromJson({
      'id': 1,
      'name': 'Worker 1',
      'gender': 'male',
    });
    final femaleWorker = PreviousWorkerModel.fromJson({
      'id': 2,
      'name': 'Worker 2',
      'worker': {'gender': 'female'},
    });

    expect(maleWorker.gender, CleaningGenderPreference.male);
    expect(femaleWorker.gender, CleaningGenderPreference.female);
  });
}
