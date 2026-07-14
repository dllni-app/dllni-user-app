import 'package:dllni_user_app/core/realtime/cleaning_realtime_contract.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Cleaning realtime worker locations', () {
    test('publishes booking-scoped locations without losing worker identity', () async {
      final publishedLocation = CleaningRealtimeLocationBus.stream.first;

      final parsed = CleaningRealtimeContract.parseLocation(<String, dynamic>{
        'cleaningBookingId': 321,
        'workerId': 17,
        'latitude': 33.5138,
        'longitude': 36.2765,
        'updatedAt': '2026-07-14T10:00:00Z',
      });

      expect(parsed, isNotNull);
      expect(parsed!.bookingId, 321);
      expect(parsed.workerId, 17);

      final emitted = await publishedLocation;
      expect(emitted.bookingId, 321);
      expect(emitted.workerId, 17);
      expect(emitted.latitude, 33.5138);
      expect(emitted.longitude, 36.2765);
    });

    test('keeps consecutive workers as separate location events', () async {
      final emitted = <CleaningRealtimeLocation>[];
      final subscription = CleaningRealtimeLocationBus.stream.listen(emitted.add);

      CleaningRealtimeContract.parseLocation(<String, dynamic>{
        'bookingId': 55,
        'workerId': 1,
        'latitude': 33.50,
        'longitude': 36.20,
      });
      CleaningRealtimeContract.parseLocation(<String, dynamic>{
        'bookingId': 55,
        'workerId': 2,
        'latitude': 33.51,
        'longitude': 36.21,
      });

      await subscription.cancel();

      expect(
        emitted.map((item) => item.workerId).toList(growable: false),
        <int?>[1, 2],
      );
      expect(
        emitted.map((item) => item.bookingId).toList(growable: false),
        <int?>[55, 55],
      );
    });
  });
}
