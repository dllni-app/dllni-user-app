import 'package:dllni_user_app/core/realtime/cleaning_realtime_contract.dart';
import 'package:dllni_user_app/features/orders/data/models/cleaning_booking_status.dart';
import 'package:dllni_user_app/features/orders/view/helpers/cleaning_extension_decision_presenter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CleaningExtensionDecisionPresenter', () {
    test('returns dialog data for completion decision reject event', () {
      final result = CleaningExtensionDecisionPresenter.resolveRejectedDialog(
        normalizedEvent: CleaningRealtimeContract.completionDecisionMade,
        payload: const <String, dynamic>{
          'decision': 'extension_rejected',
          'message': 'لا أستطيع تمديد الوقت اليوم.',
          'warningId': 77,
        },
        currentStatus: CleaningBookingStatus.timeExtensionRequested,
        handledWarningIds: <int>{},
      );

      expect(result, isNotNull);
      expect(result!.warningId, 77);
      expect(result.message, 'لا أستطيع تمديد الوقت اليوم.');
    });

    test('returns fallback message when reject message is missing', () {
      final result = CleaningExtensionDecisionPresenter.resolveRejectedDialog(
        normalizedEvent: CleaningRealtimeContract.completionDecisionMade,
        payload: const <String, dynamic>{
          'decision': 'extension_rejected',
          'warningId': 18,
        },
        currentStatus: CleaningBookingStatus.timeExtensionRequested,
        handledWarningIds: <int>{},
      );

      expect(result, isNotNull);
      expect(
        result!.message,
        'قام مقدم الخدمة برفض طلب تمديد الوقت وتم إنهاء الطلب.',
      );
    });

    test('returns null when warning id was already handled', () {
      final result = CleaningExtensionDecisionPresenter.resolveRejectedDialog(
        normalizedEvent: CleaningRealtimeContract.completionDecisionMade,
        payload: const <String, dynamic>{
          'decision': 'extension_rejected',
          'warningId': 90,
        },
        currentStatus: CleaningBookingStatus.timeExtensionRequested,
        handledWarningIds: <int>{90},
      );

      expect(result, isNull);
    });

    test('parses tracking decision aliases for tracking update event', () {
      final result = CleaningExtensionDecisionPresenter.resolveRejectedDialog(
        normalizedEvent: CleaningRealtimeContract.trackingUpdated,
        payload: const <String, dynamic>{
          'tracking': {
            'decision': 'extension_declined',
            'warningId': 101,
            'message': 'غير متاح التمديد حالياً.',
          },
        },
        currentStatus: CleaningBookingStatus.timeExtensionRequested,
        handledWarningIds: <int>{},
      );

      expect(result, isNotNull);
      expect(result!.warningId, 101);
      expect(result.message, 'غير متاح التمديد حالياً.');
    });

    test('returns dialog data when status is already completed', () {
      final result = CleaningExtensionDecisionPresenter.resolveRejectedDialog(
        normalizedEvent: CleaningRealtimeContract.completionDecisionMade,
        payload: const <String, dynamic>{
          'decision': 'extension_rejected',
          'message': 'انتهى الوقت المتاح.',
          'warningId': 41,
        },
        currentStatus: CleaningBookingStatus.completed,
        handledWarningIds: <int>{},
      );

      expect(result, isNotNull);
      expect(result!.warningId, 41);
      expect(result.message, 'انتهى الوقت المتاح.');
    });

    test(
      'returns dialog data for event assistance when local status is stale',
      () {
        final result = CleaningExtensionDecisionPresenter.resolveRejectedDialog(
          normalizedEvent: CleaningRealtimeContract.completionDecisionMade,
          payload: const <String, dynamic>{
            'decision': 'extension_rejected',
            'status': CleaningBookingStatus.completed,
            'propertyType': 'event_assistance',
            'workerRejectMessage': 'Cannot extend event assistance.',
            'warningId': 42,
          },
          currentStatus: CleaningBookingStatus.awaitingCustomerCompletion,
          handledWarningIds: <int>{},
        );

        expect(result, isNotNull);
        expect(result!.warningId, 42);
        expect(result.message, 'Cannot extend event assistance.');
      },
    );

    test(
      'infers completed status from rejected decision when local status is old',
      () {
        final result = CleaningExtensionDecisionPresenter.resolveRejectedDialog(
          normalizedEvent: CleaningRealtimeContract.trackingUpdated,
          payload: const <String, dynamic>{
            'tracking': {
              'decision': 'worker_rejected_extension',
              'warning_id': 43,
            },
          },
          currentStatus: CleaningBookingStatus.inProgress,
          handledWarningIds: <int>{},
        );

        expect(result, isNotNull);
        expect(result!.warningId, 43);
      },
    );
  });
}
