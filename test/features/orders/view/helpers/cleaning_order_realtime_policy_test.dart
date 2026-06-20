import 'package:dllni_user_app/features/orders/data/models/cleaning_booking_status.dart';
import 'package:dllni_user_app/features/orders/view/helpers/cleaning_order_realtime_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CleaningOrderRealtimePolicy', () {
    test('location event resolves to patch action only', () {
      final action = CleaningOrderRealtimePolicy.resolve(
        eventName: 'WorkerLocationUpdated',
        payload: const <String, dynamic>{'latitude': 33.5, 'longitude': 36.3},
        currentStatus: CleaningBookingStatus.workerAssigned,
      );

      expect(action.type, CleaningOrderRealtimeActionType.patchWorkerLocation);
      expect(action.reopenCompletionAfterRefresh, isFalse);
    });

    test('non-lifecycle event resolves to ignore', () {
      final action = CleaningOrderRealtimePolicy.resolve(
        eventName: 'UnknownEvent',
        payload: const <String, dynamic>{},
        currentStatus: CleaningBookingStatus.workerAssigned,
      );

      expect(action.type, CleaningOrderRealtimeActionType.ignore);
    });

    test('lifecycle event resolves to refresh action', () {
      final action = CleaningOrderRealtimePolicy.resolve(
        eventName: 'WorkerArrived',
        payload: const <String, dynamic>{},
        currentStatus: CleaningBookingStatus.workerAssigned,
      );

      expect(action.type, CleaningOrderRealtimeActionType.refreshDetails);
      expect(action.reopenCompletionAfterRefresh, isFalse);
    });

    test(
      'awaiting worker start confirmation event resolves to refresh action',
      () {
        final action = CleaningOrderRealtimePolicy.resolve(
          eventName: 'cleaning_order.awaiting_worker_start_confirmation',
          payload: const <String, dynamic>{},
          currentStatus: CleaningBookingStatus.awaitingStartVerification,
        );

        expect(action.type, CleaningOrderRealtimeActionType.refreshDetails);
        expect(action.reopenCompletionAfterRefresh, isFalse);
      },
    );

    test('awaiting-customer event requests completion sheet reopen', () {
      final action = CleaningOrderRealtimePolicy.resolve(
        eventName: 'CompletionReviewRequested',
        payload: const <String, dynamic>{},
        currentStatus: CleaningBookingStatus.inProgress,
      );

      expect(action.type, CleaningOrderRealtimeActionType.refreshDetails);
      expect(action.reopenCompletionAfterRefresh, isTrue);
    });

    test(
      'rejected decision reopens completion when extension was requested',
      () {
        final action = CleaningOrderRealtimePolicy.resolve(
          eventName: 'CompletionDecisionMade',
          payload: const <String, dynamic>{'decision': 'rejected'},
          currentStatus: CleaningBookingStatus.timeExtensionRequested,
        );

        expect(action.type, CleaningOrderRealtimeActionType.refreshDetails);
        expect(action.reopenCompletionAfterRefresh, isTrue);
      },
    );

    test('extension_rejected decision reopens completion sheet', () {
      final action = CleaningOrderRealtimePolicy.resolve(
        eventName: 'CompletionDecisionMade',
        payload: const <String, dynamic>{'decision': 'extension_rejected'},
        currentStatus: CleaningBookingStatus.timeExtensionRequested,
      );

      expect(action.reopenCompletionAfterRefresh, isTrue);
    });

    test(
      'tracking update to awaiting_customer_completion reopens completion',
      () {
        final action = CleaningOrderRealtimePolicy.resolve(
          eventName: 'CleaningBookingTrackingUpdated',
          payload: const <String, dynamic>{
            'tracking': {
              'status': CleaningBookingStatus.awaitingCustomerCompletion,
            },
          },
          currentStatus: CleaningBookingStatus.timeExtensionRequested,
        );

        expect(action.reopenCompletionAfterRefresh, isTrue);
      },
    );
  });
}
