import 'package:dllni_user_app/features/cl_main/domain/usecases/get_previous_cleaning_workers_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('getParams includes pagination and service schedule only', () {
    final params = GetPreviousCleaningWorkersParams(
      page: 2,
      perPage: 15,
      propertyType: 'villa',
      scheduledDate: '2026-08-04',
      scheduledTime: '09:00',
      durationHours: 1.5,
    );

    expect(params.getParams(), {
      'page': 2,
      'per_page': 15,
      'scheduledDate': '2026-08-04',
      'scheduledTime': '09:00',
      'durationHours': 1.5,
    });
  });

  test('getParams omits optional filters when null or empty', () {
    expect(
      GetPreviousCleaningWorkersParams(page: 1).getParams(),
      {'page': 1, 'per_page': 10},
    );
    expect(
      GetPreviousCleaningWorkersParams(
        page: 1,
        propertyType: '',
        scheduledDate: '',
        scheduledTime: '',
        durationHours: 0,
      ).getParams(),
      {'page': 1, 'per_page': 10},
    );
  });

  test('getParams does not send property or neighborhood filters', () {
    final params = GetPreviousCleaningWorkersParams(
      propertyType: 'event_assistance',
    );

    expect(params.getParams().containsKey('propertyType'), isFalse);
    expect(params.getParams().containsKey('neighborhoodId'), isFalse);
  });
}
