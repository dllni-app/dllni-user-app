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

  test('PreviousWorkersResponseModel parses live previous-workers payload', () {
    final response = PreviousWorkersResponseModel.fromJson({
      'workers': [
        {
          'workerId': 1,
          'name': 'رنا',
          'gender': 'male',
          'avatarUrl':
              'https://alnadha.net/storage/3/photo-1521572267360-ee0c2909d518.jpeg',
          'description': 'عاملة تنظيف ذات خبرة من التجارب داخل التطبيق.',
          'ratings': {
            'average': 4.8,
            'count': 0,
          },
          'averageRating': 4.8,
          'completedJobsWithUser': 1,
          'lastWorkedDate': '2026-06-17',
        },
      ],
    });

    expect(response.data, isNotNull);
    expect(response.data, hasLength(1));

    final worker = response.data!.first;
    expect(worker.id, 1);
    expect(worker.name, 'رنا');
    expect(worker.gender, CleaningGenderPreference.male);
    expect(
      worker.profileImage,
      'https://alnadha.net/storage/3/photo-1521572267360-ee0c2909d518.jpeg',
    );
    expect(worker.rating, 4.8);
    expect(worker.ratings?.average, 4.8);
    expect(worker.completedJobs, 1);
    expect(worker.lastServiceDate, '2026-06-17');
  });
}
