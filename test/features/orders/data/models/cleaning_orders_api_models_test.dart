import 'package:dllni_user_app/core/models/cleaning_gender_preference.dart';
import 'package:dllni_user_app/features/orders/data/models/cleaning_booking_status.dart';
import 'package:dllni_user_app/features/orders/data/models/cleaning_orders_api_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CleaningOrderDetailModel parsing', () {
    test('parses full payload with tracking and key aliases', () {
      final model = fetchCleaningOrderDetailsModelFromJson(<String, dynamic>{
        'data': <String, dynamic>{
          'id': 101,
          'booking_number': 'CL-101',
          'status': CleaningBookingStatus.workerAssigned,
          'customer_id': 5,
          'workerId': 8,
          'scheduled_date': '2026-05-17',
          'scheduled_time': '10:00',
          'gender_preference': 'female',
          'cancellation_fee': '7.25',
          'total_price': 49.5,
          'travel_distance_km': '3.456',
          'admin_margin': 6.5,
          'is_pricing_final': false,
          'tracking': <String, dynamic>{
            'started_travel_at': '2026-05-17T09:45:00Z',
            'address_latitude': '33.5',
            'address_longitude': 36.3,
          },
          'customer': <String, dynamic>{
            'id': 5,
            'name': 'Maya',
            'phone': '099999',
            'email': 'maya@example.com',
          },
          'worker': <String, dynamic>{
            'id': 8,
            'first_name': 'Omar',
            'phone': '098888',
            'average_rating': 4.7,
          },
          'services': <Map<String, dynamic>>[
            <String, dynamic>{'id': 1, 'name': 'Main Service', 'quantity': 1},
          ],
          'addons': <Map<String, dynamic>>[
            <String, dynamic>{'id': 2, 'name': 'Extra', 'quantity': 2},
          ],
          'billing_policy': <String, dynamic>{'id': 12, 'name': 'Default'},
          'time_warnings': <Map<String, dynamic>>[
            <String, dynamic>{'id': 7},
          ],
          'disputes': <Map<String, dynamic>>[
            <String, dynamic>{'id': 9},
          ],
        },
      });

      final data = model.data;
      expect(data, isNotNull);
      expect(data!.id, 101);
      expect(data.bookingNumber, 'CL-101');
      expect(data.genderPreference, CleaningGenderPreference.female);
      expect(data.customerId, 5);
      expect(data.workerId, 8);
      expect(data.startedTravelAt, '2026-05-17T09:45:00Z');
      expect(data.addressLatitude, 33.5);
      expect(data.addressLongitude, 36.3);
      expect(data.cancellationFee, 7.25);
      expect(data.travelDistanceKm, 3.456);
      expect(data.adminMargin, 6.5);
      expect(data.isPricingFinal, isFalse);
      expect(data.customer?.name, 'Maya');
      expect(data.worker?.name, 'Omar');
      expect(data.services?.first.name, 'Main Service');
      expect(data.addons?.first.quantity, 2);
      expect(data.billingPolicy?['id'], 12);
      expect((data.timeWarnings ?? <dynamic>[]).length, 1);
      expect((data.disputes ?? <dynamic>[]).length, 1);
      expect(data.toCleaningOrderModel().travelDistanceKm, 3.456);
      expect(data.toCleaningOrderModel().adminMargin, 6.5);
      expect(data.toCleaningOrderModel().isPricingFinal, isFalse);
    });

    test(
      'parses gender preference from camelCase and preserves in model map',
      () {
        final model = fetchCleaningOrderDetailsModelFromJson(<String, dynamic>{
          'data': <String, dynamic>{'id': 201, 'genderPreference': 'male'},
        });

        final data = model.data;
        expect(data, isNotNull);
        expect(data!.genderPreference, CleaningGenderPreference.male);
        expect(
          data.toCleaningOrderModel().genderPreference,
          CleaningGenderPreference.male,
        );
      },
    );

    test('parses multi-worker team fields on detail payload', () {
      final model = fetchCleaningOrderDetailsModelFromJson(<String, dynamic>{
        'data': <String, dynamic>{
          'id': 123,
          'status': CleaningBookingStatus.pending,
          'assignmentMode': 'open_count',
          'numberOfWorkers': 2,
          'workerAcceptance': <String, dynamic>{
            'required': 2,
            'accepted': 1,
            'remaining': 1,
            'isFulfilled': false,
          },
          'workerAssignments': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 9001,
              'workerId': 44,
              'status': 'accepted',
              'roomCount': 1,
              'workerAmount': 20500,
              'roomIds': <int>[501],
              'worker': <String, dynamic>{
                'id': 44,
                'name': 'Ahmad Ali',
                'averageRating': 4.8,
              },
            },
          ],
          'roomAssignments': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 501,
              'roomKey': 'bedroom.small.1',
              'roomType': 'bedroom',
              'roomSize': 'small',
              'displayLabel': 'Bedroom 1 - Small',
              'assignedWorkerId': 44,
              'assignmentSource': 'customer',
            },
          ],
          'myAssignment': <String, dynamic>{
            'id': 9001,
            'workerId': 44,
            'status': 'accepted',
            'roomCount': 1,
            'workerAmount': 20500,
            'currency': 'SYP',
            'roomIds': <int>[501],
          },
        },
      });

      final data = model.data;
      expect(data, isNotNull);
      expect(data!.assignmentMode, 'open_count');
      expect(data.numberOfWorkers, 2);
      expect(data.workerAcceptance?.required, 2);
      expect(data.workerAcceptance?.accepted, 1);
      expect(data.workerAcceptance?.remaining, 1);
      expect(data.workerAcceptance?.isFulfilled, isFalse);
      expect(data.workerAssignments?.length, 1);
      expect(data.workerAssignments?.first.workerId, 44);
      expect(data.roomAssignments?.length, 1);
      expect(data.roomAssignments?.first.displayLabel, 'Bedroom 1 - Small');
      expect(data.myAssignment?.workerId, 44);
      expect(data.myAssignment?.workerAmount, 20500);
      expect(data.isMultiWorkerTeam, isTrue);
      expect(data.isSearchingForWorkers, isTrue);
      expect(data.acceptedWorkerAssignments.length, 1);
    });

    test('treats accepted waiting worker states as non-searching and labels rooms', () {
      final model = fetchCleaningOrderDetailsModelFromJson(<String, dynamic>{
        'data': <String, dynamic>{
          'id': 124,
          'status': CleaningBookingStatus.pending,
          'worker_order_status': CleaningBookingStatus.acceptedWaitingForOrderStart,
          'worker_order_status_label': 'بانتظار تأكيد مقدم الخدمة لبدء العمل',
          'required_workers_count': 2,
          'accepted_workers_count': 1,
          'pending_workers_count': 1,
          'roomAssignments': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 601,
              'roomKey': 'bedroom.small.1',
              'roomType': 'bedroom',
              'roomSize': 'small',
            },
          ],
        },
      });

      final data = model.data;
      expect(data, isNotNull);
      expect(data!.isAcceptedWaitingState, isTrue);
      expect(data.isSearchingForWorkers, isFalse);
      expect(
        data.displayStatusLabelAr,
        'بانتظار تأكيد مقدم الخدمة لبدء العمل (1/2)',
      );
      expect(data.roomAssignments?.first.resolvedLabel, 'غرفة نوم - صغيرة');
    });

    test('parses multi-worker team fields on list payload', () {
      final model = fetchCleaningOrdersModelFromJson(<String, dynamic>{
        'data': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 401,
            'status': CleaningBookingStatus.pending,
            'assignment_mode': 'open_count',
            'number_of_workers': 3,
            'worker_acceptance': <String, dynamic>{
              'required': 3,
              'accepted': 1,
              'remaining': 2,
              'is_fulfilled': false,
            },
          },
        ],
      });

      final item = model.data.first;
      expect(item.assignmentMode, 'open_count');
      expect(item.numberOfWorkers, 3);
      expect(item.workerAcceptance?.accepted, 1);
      expect(item.isMultiWorkerTeam, isTrue);
      expect(item.isSearchingForWorkers, isTrue);
    });

    test('parses new pricing fields on list payload', () {
      final model = fetchCleaningOrdersModelFromJson(<String, dynamic>{
        'data': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 301,
            'travelDistanceKm': 1.25,
            'adminMargin': '3.75',
            'isPricingFinal': 1,
          },
        ],
      });

      final item = model.data.first;
      expect(item.id, 301);
      expect(item.travelDistanceKm, 1.25);
      expect(item.adminMargin, 3.75);
      expect(item.isPricingFinal, isTrue);
    });

    test('parses travelFee from camelCase and snake_case aliases', () {
      final camelCase = fetchCleaningOrderDetailsModelFromJson(
        <String, dynamic>{
          'data': <String, dynamic>{
            'id': 501,
            'travelFee': 111.19,
            'isPricingFinal': true,
          },
        },
      );
      expect(camelCase.data?.travelFee, 111.19);
      expect(camelCase.data?.isPricingFinal, isTrue);

      final snakeCase = fetchCleaningOrderDetailsModelFromJson(
        <String, dynamic>{
          'data': <String, dynamic>{
            'id': 502,
            'travel_fee': '0',
            'is_pricing_final': false,
          },
        },
      );
      expect(snakeCase.data?.travelFee, 0);
      expect(snakeCase.data?.isPricingFinal, isFalse);
    });

    test('labels awaiting worker start confirmation status', () {
      expect(
        cleaningOrderStatusLabelAr(
          CleaningBookingStatus.awaitingWorkerStartConfirmation,
        ),
        'بانتظار تأكيد مقدم الخدمة لبدء العمل',
      );
    });
  });
}
