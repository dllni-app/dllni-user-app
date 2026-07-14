import 'dart:async';

class CleaningTrackingSessionBus {
  CleaningTrackingSessionBus._();

  static final StreamController<int?> _activeBookingController =
      StreamController<int?>.broadcast(sync: true);
  static final StreamController<int> _refreshController =
      StreamController<int>.broadcast(sync: true);

  static int? _activeBookingId;

  static int? get activeBookingId => _activeBookingId;
  static Stream<int?> get activeBookingStream => _activeBookingController.stream;
  static Stream<int> get refreshStream => _refreshController.stream;

  static void activate(int bookingId) {
    if (bookingId <= 0) return;
    _activeBookingId = bookingId;
    if (!_activeBookingController.isClosed) {
      _activeBookingController.add(bookingId);
    }
    requestRefresh(bookingId);
  }

  static void deactivate(int bookingId) {
    if (_activeBookingId != bookingId) return;
    _activeBookingId = null;
    if (!_activeBookingController.isClosed) {
      _activeBookingController.add(null);
    }
  }

  static void requestRefresh(int bookingId) {
    if (bookingId <= 0 || _refreshController.isClosed) return;
    _refreshController.add(bookingId);
  }
}
