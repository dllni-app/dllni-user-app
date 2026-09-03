import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_event_session.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/get_previous_cleaning_workers_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('getParams includes pagination and legacy service schedule', () {
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
      'propertyType': 'villa',
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

  test('multi-day availability sends every requested session', () {
    final params = GetPreviousCleaningWorkersParams(
      propertyType: 'event_assistance',
      scheduledDate: '2026-09-10',
      scheduledTime: '18:00',
      durationHours: 4,
      eventSessions: <CleaningEventSessionInput>[
        CleaningEventSessionInput(
          date: DateTime(2026, 9, 12),
          time: '17:30',
          hours: 5,
        ),
        CleaningEventSessionInput(
          date: DateTime(2026, 9, 10),
          time: '18:00',
          hours: 4,
        ),
      ],
    );

    expect(params.getParams(), {
      'page': 1,
      'per_page': 10,
      'propertyType': 'event_assistance',
      'schedule[mode]': 'multi_day',
      'schedule[sessions][0][date]': '2026-09-10',
      'schedule[sessions][0][time]': '18:00',
      'schedule[sessions][0][hours]': 4.0,
      'schedule[sessions][1][date]': '2026-09-12',
      'schedule[sessions][1][time]': '17:30',
      'schedule[sessions][1][hours]': 5.0,
    });
  });
}
