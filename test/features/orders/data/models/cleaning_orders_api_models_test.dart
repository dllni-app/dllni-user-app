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
  });
}
