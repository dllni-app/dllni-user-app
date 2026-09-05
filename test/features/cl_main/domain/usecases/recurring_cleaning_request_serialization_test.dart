import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_recurring_session.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/create_cleaning_order_use_case.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/estimate_cleaning_price_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final visits = <CleaningRecurringSessionInput>[
    CleaningRecurringSessionInput(date: DateTime(2026, 9, 18), time: '11:00'),
    CleaningRecurringSessionInput(date: DateTime(2026, 9, 12), time: '09:30'),
  ];

  test('create payload sends a canonical recurring schedule', () {
    final params = CreateCleaningOrderParams(
      addressId: 1,
      propertyType: 'apartment',
      bedrooms: 1,
      rooms: 1,
      bathrooms: 1,
      livingRoomSize: 'small',
      address: 'حلب',
      locationName: 'المنزل',
      scheduledDate: '2026-09-10',
      scheduledTime: '08:00',
      addressLatitude: null,
      addressLongitude: null,
      recurringSessions: visits,
    );

    final body = params.getBody();
    final schedule = body['schedule'] as Map<String, dynamic>;
    final sessions = schedule['sessions'] as List<dynamic>;

    expect(body['scheduledDate'], '2026-09-12');
    expect(body['scheduledTime'], '09:30');
    expect(schedule['mode'], 'recurring');
    expect(schedule['calculationMode'], 'task');
    expect(sessions, [
      {'date': '2026-09-12', 'time': '09:30'},
      {'date': '2026-09-18', 'time': '11:00'},
    ]);
  });

  test('estimate payload sends the same recurring schedule contract', () {
    final params = EstimateCleaningPriceParams(
      propertyType: 'apartment',
      bedrooms: 1,
      rooms: 1,
      bathrooms: 1,
      livingRoomSize: 'small',
      addressLatitude: 36.2,
      addressLongitude: 37.1,
      recurringSessions: visits,
    );

    final body = params.getBody();
    final schedule = body['schedule'] as Map<String, dynamic>;
    final sessions = schedule['sessions'] as List<dynamic>;

    expect(schedule['mode'], 'recurring');
    expect(schedule['calculationMode'], 'task');
    expect(sessions, [
      {'date': '2026-09-12', 'time': '09:30'},
      {'date': '2026-09-18', 'time': '11:00'},
    ]);
  });

  test(
    'create and estimate payloads serialize the same hour-based contract',
    () {
      final create =
          CreateCleaningOrderParams(
                addressId: 1,
                propertyType: 'apartment',
                bedrooms: 1,
                rooms: 1,
                bathrooms: 1,
                livingRoomSize: 'small',
                address: 'حلب',
                locationName: 'المنزل',
                scheduledDate: '2026-09-10',
                scheduledTime: '08:00',
                addressLatitude: null,
                addressLongitude: null,
                recurringSessions: visits,
                recurringCalculationMode:
                    CleaningRecurringCalculationMode.hours,
                recurringHoursPerVisit: 2.25,
              ).getBody()['schedule']
              as Map<String, dynamic>;
      final estimate =
          EstimateCleaningPriceParams(
                propertyType: 'apartment',
                bedrooms: 1,
                rooms: 1,
                bathrooms: 1,
                livingRoomSize: 'small',
                addressLatitude: 36.2,
                addressLongitude: 37.1,
                recurringSessions: visits,
                recurringCalculationMode:
                    CleaningRecurringCalculationMode.hours,
                recurringHoursPerVisit: 2.25,
              ).getBody()['schedule']
              as Map<String, dynamic>;

      expect(create, estimate);
      expect(create['calculationMode'], 'hours');
      expect(create['hoursPerVisit'], 2.5);
    },
  );
}
