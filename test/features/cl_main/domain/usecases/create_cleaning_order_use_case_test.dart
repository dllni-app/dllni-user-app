import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_assignment_mode.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/create_cleaning_order_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CreateCleaningOrderParams buildParams({
    CleaningAssignmentMode assignmentMode = CleaningAssignmentMode.preferredWorker,
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

  test('preferred worker ids do not drive open-count worker count on create', () {
    final params = buildParams(
      assignmentMode: CleaningAssignmentMode.openCount,
      numberOfWorkers: 2,
      preferredWorkerIds: const [7, 9],
    );

    final body = params.getBody();

    expect(body['assignmentMode'], 'preferred_worker');
    expect(body['numberOfWorkers'], 1);
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
}
