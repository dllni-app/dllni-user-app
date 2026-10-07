import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_assignment_mode.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/create_cleaning_order_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CreateCleaningOrderParams buildParams({
    CleaningAssignmentMode assignmentMode =
        CleaningAssignmentMode.preferredWorker,
    int? numberOfWorkers,
    List<int> preferredWorkerIds = const <int>[],
  }) {
    return CreateCleaningOrderParams(
      addressId: 1,
      propertyType: 'apartment',
      bedrooms: 1,
      rooms: 1,
      bathrooms: 1,
      livingRoomSize: 'small',
      address: 'حلب - الحمدانية',
      locationName: 'المنزل',
      scheduledDate: '2026-06-27',
      scheduledTime: '09:00',
      addressLatitude: null,
      addressLongitude: null,
      assignmentMode: assignmentMode,
      numberOfWorkers: numberOfWorkers,
      preferredWorkerIds: preferredWorkerIds,
    );
  }

  test('preferred worker ids count toward an open-count team on create', () {
    final params = buildParams(
      assignmentMode: CleaningAssignmentMode.openCount,
      numberOfWorkers: 2,
      preferredWorkerIds: const [7, 9],
    );

    final body = params.getBody();

    expect(body['assignmentMode'], 'open_count');
    expect(body['numberOfWorkers'], 2);
    expect(body['preferredWorkerIds'], [7, 9]);
  });

  test('open-count without preferred workers keeps selected worker count', () {
    final params = buildParams(
      assignmentMode: CleaningAssignmentMode.openCount,
      numberOfWorkers: 3,
    );

    final body = params.getBody();

    expect(body['assignmentMode'], 'open_count');
    expect(body['numberOfWorkers'], 3);
    expect(body.containsKey('preferredWorkerIds'), isFalse);
  });

  test('hourly worker create payload is a standalone open-time order', () {
    final params = CreateCleaningOrderParams.hourlyWorker(
      addressId: 12,
      scheduledDate: '2026-10-09',
      scheduledTime: '11:00',
      workerCount: 3,
      expectedMaxMinutes: 240,
      address: 'حلب - العزيزية',
      locationName: 'المنزل',
      notes: 'مساعدة في ترتيب المنزل',
    );

    final body = params.getBody();
    final openTime = body['openTime'] as Map<String, dynamic>;

    expect(body['bookingKind'], 'open_time');
    expect(body['propertyType'], 'apartment');
    expect(body['assignmentMode'], 'open_count');
    expect(body['numberOfWorkers'], 3);
    expect(openTime['workerCount'], 3);
    expect(openTime['expectedMaxMinutes'], 240);
    expect(body.containsKey('cleaning_services'), isFalse);
  });

}
