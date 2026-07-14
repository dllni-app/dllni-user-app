import 'package:dllni_user_app/core/realtime/cleaning_tracking_session_bus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('activating a booking publishes active and refresh events', () async {
    final activeFuture = CleaningTrackingSessionBus.activeBookingStream.first;
    final refreshFuture = CleaningTrackingSessionBus.refreshStream.first;

    CleaningTrackingSessionBus.activate(77);

    expect(await activeFuture, 77);
    expect(await refreshFuture, 77);
    expect(CleaningTrackingSessionBus.activeBookingId, 77);

    final inactiveFuture = CleaningTrackingSessionBus.activeBookingStream.first;
    CleaningTrackingSessionBus.deactivate(77);
    expect(await inactiveFuture, isNull);
    expect(CleaningTrackingSessionBus.activeBookingId, isNull);
  });
}
