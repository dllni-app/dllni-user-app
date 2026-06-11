import 'package:dllni_user_app/features/orders/data/models/cleaning_booking_status.dart';
import 'package:dllni_user_app/features/orders/data/models/cleaning_orders_api_models.dart';
import 'package:dllni_user_app/features/orders/data/models/sos_api_models.dart';
import 'package:dllni_user_app/features/orders/view/helpers/cleaning_event_assistance_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CleaningEventAssistanceHelper', () {
    test('uses custom service title for event assistance', () {
      expect(
        CleaningEventAssistanceHelper.serviceTitle(
          propertyType: 'event_assistance',
          customService: 'Serving and cleanup support',
        ),
        'Serving and cleanup support',
      );
    });

    test('falls back to regular cleaning title for home orders', () {
      expect(
        CleaningEventAssistanceHelper.serviceTitle(
          propertyType: 'apartment',
        ),
        'خدمة تنظيف شقة',
      );
    });
  });

  group('CleaningPropertyDetailsModel event parsing', () {
    test('parses snake_case event fields on order detail payload', () {
      final model = fetchCleaningOrderDetailsModelFromJson(<String, dynamic>{
        'data': <String, dynamic>{
          'id': 101,
          'propertyType': 'event_assistance',
          'propertyDetails': <String, dynamic>{
            'event_type': 'family_dinner',
            'guest_count': 40,
            'venue_type': 'apartment',
            'custom_service': 'Manual hospitality support',
            'hours': 5,
            'special_requirement': 'Male helpers only',
          },
          'totalHours': 5,
          'services': <dynamic>[],
        },
      });

      final data = model.data;
      expect(data, isNotNull);
      expect(data!.propertyDetails?.eventType, 'family_dinner');
      expect(data.propertyDetails?.guestCount, 40);
      expect(data.propertyDetails?.customService, 'Manual hospitality support');
      expect(data.propertyDetails?.hours, 5);
      expect(data.services, isEmpty);
    });

    test('parses fractional hours on list payload', () {
      final model = fetchCleaningOrdersModelFromJson(<String, dynamic>{
        'data': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 202,
            'property_type': 'event_assistance',
            'total_hours': 2.5,
            'estimated_hours': '2.50',
            'is_pricing_final': false,
            'travel_fee': 0,
          },
        ],
      });

      final item = model.data.first;
      expect(item.totalHours, 2.5);
      expect(item.isPricingFinal, isFalse);
      expect(item.travelFee, 0);
    });
  });

  group('Sos API models', () {
    test('parses create response created_at as ISO 8601', () {
      final model = createUserSosResponseModelFromJson(<String, dynamic>{
        'data': <String, dynamic>{
          'id': 9,
          'created_at': '2026-06-11T18:30:00.000000Z',
        },
      });

      expect(model.id, 9);
      expect(model.createdAt, '2026-06-11T18:30:00.000000Z');
    });

    test('parses alert list timestamps as yyyy-MM-dd HH:mm:ss', () {
      final model = fetchSosAlertsModelFromJson(<String, dynamic>{
        'data': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 3,
            'created_at': '2026-06-11 18:30:00',
            'booking': <String, dynamic>{'id': 55, 'type': 'restaurant_order'},
          },
        ],
      });

      final alert = model.data.first;
      expect(alert.id, 3);
      expect(alert.createdAt, isNotNull);
      expect(alert.booking?['type'], 'restaurant_order');
    });
  });
}
