import 'package:dllni_user_app/features/orders/data/models/cleaning_booking_status.dart';
import 'package:dllni_user_app/features/orders/view/helpers/cleaning_cancel_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CleaningCancelPolicy.isCancellable', () {
    test('returns true only for pending and worker_assigned', () {
      expect(
        CleaningCancelPolicy.isCancellable(CleaningBookingStatus.pending),
        isTrue,
      );
      expect(
        CleaningCancelPolicy.isCancellable(CleaningBookingStatus.workerAssigned),
        isTrue,
      );
    });

    test('returns false for all other statuses', () {
      const blockedStatuses = <String>[
        CleaningBookingStatus.awaitingStartVerification,
        CleaningBookingStatus.awaitingWorkerStartConfirmation,
        CleaningBookingStatus.inProgress,
        CleaningBookingStatus.awaitingCustomerCompletion,
        CleaningBookingStatus.timeExtensionRequested,
        CleaningBookingStatus.completed,
        CleaningBookingStatus.cancelled,
      ];

      for (final status in blockedStatuses) {
        expect(
          CleaningCancelPolicy.isCancellable(status),
          isFalse,
          reason: status,
        );
      }
    });

    test('normalizes casing and whitespace', () {
      expect(CleaningCancelPolicy.isCancellable(' PENDING '), isTrue);
      expect(CleaningCancelPolicy.isCancellable(' Worker_Assigned '), isTrue);
    });

    test('returns false for null and empty status', () {
      expect(CleaningCancelPolicy.isCancellable(null), isFalse);
      expect(CleaningCancelPolicy.isCancellable(''), isFalse);
      expect(CleaningCancelPolicy.isCancellable('   '), isFalse);
    });
  });
}
