import 'package:dllni_user_app/core/realtime/cleaning_realtime_contract.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CleaningRealtimeContract', () {
    test('normalizes security-code issued aliases to awaiting-start event', () {
      expect(
        CleaningRealtimeContract.normalizeEventName('SecurityCodeIssued'),
        CleaningRealtimeContract.awaitingStartVerification,
      );
      expect(
        CleaningRealtimeContract.normalizeEventName(
          'cleaning_order.security_code_issued',
        ),
        CleaningRealtimeContract.awaitingStartVerification,
      );
    });

    test('normalizes arrival aliases and flexible event casing', () {
      expect(
        CleaningRealtimeContract.normalizeEventName('worker_arrived'),
        CleaningRealtimeContract.workerArrived,
      );
      expect(
        CleaningRealtimeContract.normalizeEventName(
          'cleaning_order.worker_arrived',
        ),
        CleaningRealtimeContract.workerArrived,
      );
      expect(
        CleaningRealtimeContract.normalizeEventName(
          'arrival_verification_requested',
        ),
        CleaningRealtimeContract.awaitingStartVerification,
      );
      expect(
        CleaningRealtimeContract.normalizeEventName('workerarrived'),
        CleaningRealtimeContract.workerArrived,
      );
    });

    test('identifies security-code reissue raw events only', () {
      expect(
        CleaningRealtimeContract.isSecurityCodeReissuedEvent(
          'SecurityCodeIssued',
        ),
        isTrue,
      );
      expect(
        CleaningRealtimeContract.isSecurityCodeReissuedEvent(
          'cleaning_order.security_code_issued',
        ),
        isTrue,
      );
      expect(
        CleaningRealtimeContract.isSecurityCodeReissuedEvent(
          CleaningRealtimeContract.awaitingStartVerification,
        ),
        isFalse,
      );
    });

    test('extracts booking id from cleaning_order_id payload aliases', () {
      expect(
        CleaningRealtimeContract.extractBookingId(const <String, dynamic>{
          'cleaning_order_id': 42,
        }),
        42,
      );
      expect(
        CleaningRealtimeContract.extractBookingId(const <String, dynamic>{
          'cleaningOrderId': '77',
        }),
        77,
      );
      expect(
        CleaningRealtimeContract.extractBookingId(const <String, dynamic>{
          'tracking': <String, dynamic>{'cleaning_order_id': 19},
        }),
        19,
      );
      expect(
        CleaningRealtimeContract.extractBookingId(const <String, dynamic>{
          'cleaning_order': <String, dynamic>{'id': 63},
        }),
        63,
      );
      expect(
        CleaningRealtimeContract.extractBookingId(const <String, dynamic>{
          'order': <String, dynamic>{'booking_id': '88'},
        }),
        88,
      );
      expect(
        CleaningRealtimeContract.extractBookingId(const <String, dynamic>{
          'booking': <String, dynamic>{'cleaningOrderId': 91},
        }),
        91,
      );
      expect(
        CleaningRealtimeContract.extractBookingId(const <String, dynamic>{
          'data': <String, dynamic>{
            'cleaning_booking': <String, dynamic>{'id': 94},
          },
        }),
        94,
      );
      expect(
        CleaningRealtimeContract.extractBookingId(const <String, dynamic>{
          'data': <String, dynamic>{
            'order': <String, dynamic>{'cleaning_booking_id': 96},
          },
        }),
        96,
      );
    });

    test('unwraps nested data payloads for booking id extraction', () {
      expect(
        CleaningRealtimeContract.extractBookingId(const <String, dynamic>{
          'data': <String, dynamic>{
            'team': <String, dynamic>{
              'requiredWorkers': 2,
            },
            'cleaning_order_id': 55,
          },
        }),
        55,
      );
    });

    test('parseLocation reads coordinates from nested data payload', () {
      final location = CleaningRealtimeContract.parseLocation(
        const <String, dynamic>{
          'data': <String, dynamic>{
            'latitude': 33.5,
            'longitude': 36.3,
          },
        },
      );

      expect(location, isNotNull);
      expect(location!.latitude, 33.5);
      expect(location.longitude, 36.3);
    });
  });
}
