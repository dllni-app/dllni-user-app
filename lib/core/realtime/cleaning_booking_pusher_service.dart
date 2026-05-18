import 'package:dllni_user_app/core/di/injection.dart';
import 'package:injectable/injectable.dart';

import 'pusher_manager.dart';

typedef CleaningBookingEventHandler =
    void Function(String eventName, Map<String, dynamic> payload);
typedef CleaningBookingChannelErrorHandler =
    void Function(RealtimeChannelError error);

@lazySingleton
class CleaningBookingPusherService {
  CleaningBookingPusherService() : _pusherManager = getIt<PusherManager>();

  final PusherManager _pusherManager;

  final Map<int, CleaningBookingEventHandler> _bookingHandlers =
      <int, CleaningBookingEventHandler>{};
  final Map<int, CleaningBookingEventHandler> _customerHandlers =
      <int, CleaningBookingEventHandler>{};
  final Map<int, CleaningBookingChannelErrorHandler> _bookingErrorHandlers =
      <int, CleaningBookingChannelErrorHandler>{};
  final Map<int, CleaningBookingChannelErrorHandler> _customerErrorHandlers =
      <int, CleaningBookingChannelErrorHandler>{};

  final Map<int, RealtimeListenerHandle> _bookingListenerHandles =
      <int, RealtimeListenerHandle>{};
  final Map<int, RealtimeListenerHandle> _customerListenerHandles =
      <int, RealtimeListenerHandle>{};

  Future<void> ensureInitialized() {
    return _pusherManager.ensureInitialized();
  }

  @Deprecated(
    'Use PusherManager.listen with RealtimeListenerHandle ownership instead.',
  )
  void setBookingHandler(int bookingId, CleaningBookingEventHandler? onEvent) {
    if (onEvent == null) {
      _bookingHandlers.remove(bookingId);
      return;
    }
    _bookingHandlers[bookingId] = onEvent;
  }

  @Deprecated(
    'Use PusherManager.listen with RealtimeListenerHandle ownership instead.',
  )
  void setCustomerHandler(
    int customerId,
    CleaningBookingEventHandler? onEvent,
  ) {
    if (onEvent == null) {
      _customerHandlers.remove(customerId);
      return;
    }
    _customerHandlers[customerId] = onEvent;
  }

  @Deprecated(
    'Use PusherManager.listen with RealtimeListenerHandle ownership instead.',
  )
  void setBookingErrorHandler(
    int bookingId,
    CleaningBookingChannelErrorHandler? onError,
  ) {
    if (onError == null) {
      _bookingErrorHandlers.remove(bookingId);
      return;
    }
    _bookingErrorHandlers[bookingId] = onError;
  }

  @Deprecated(
    'Use PusherManager.listen with RealtimeListenerHandle ownership instead.',
  )
  void setCustomerErrorHandler(
    int customerId,
    CleaningBookingChannelErrorHandler? onError,
  ) {
    if (onError == null) {
      _customerErrorHandlers.remove(customerId);
      return;
    }
    _customerErrorHandlers[customerId] = onError;
  }

  Future<void> subscribeBookingChannel(int bookingId) async {
    if (_bookingListenerHandles.containsKey(bookingId)) return;
    final handle = await _pusherManager.listen(
      channelName: 'private-cleaning-booking.$bookingId',
      onEvent: (event) {
        final handler = _bookingHandlers[bookingId];
        if (handler == null) return;
        handler(event.eventName, event.payload);
      },
      onChannelError: (error) {
        final handler = _bookingErrorHandlers[bookingId];
        if (handler == null) return;
        handler(error);
      },
    );
    _bookingListenerHandles[bookingId] = handle;
  }

  Future<void> unsubscribeBookingChannel(int bookingId) async {
    final handle = _bookingListenerHandles.remove(bookingId);
    await handle?.dispose();
  }

  Future<void> subscribeCustomerChannel(int customerId) async {
    if (_customerListenerHandles.containsKey(customerId)) return;
    final handle = await _pusherManager.listen(
      channelName: 'private-cleaning-customer.$customerId',
      onEvent: (event) {
        final handler = _customerHandlers[customerId];
        if (handler == null) return;
        handler(event.eventName, event.payload);
      },
      onChannelError: (error) {
        final handler = _customerErrorHandlers[customerId];
        if (handler == null) return;
        handler(error);
      },
    );
    _customerListenerHandles[customerId] = handle;
  }

  Future<void> unsubscribeCustomerChannel(int customerId) async {
    final handle = _customerListenerHandles.remove(customerId);
    await handle?.dispose();
  }

  Future<void> disposeAllForSession() async {
    final bookingHandles = _bookingListenerHandles.values.toList(
      growable: false,
    );
    final customerHandles = _customerListenerHandles.values.toList(
      growable: false,
    );
    _bookingListenerHandles.clear();
    _customerListenerHandles.clear();
    _bookingHandlers.clear();
    _customerHandlers.clear();
    _bookingErrorHandlers.clear();
    _customerErrorHandlers.clear();
    for (final handle in bookingHandles) {
      await handle.dispose();
    }
    for (final handle in customerHandles) {
      await handle.dispose();
    }
    await _pusherManager.disposeAllForSession();
  }
}
