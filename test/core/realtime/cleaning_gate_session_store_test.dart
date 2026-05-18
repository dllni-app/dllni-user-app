import 'package:dllni_user_app/core/realtime/cleaning_gate_session_store.dart';
import 'package:dllni_user_app/features/orders/data/models/cleaning_booking_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CleaningGateSessionStore', () {
    late CleaningGateSessionStore store;

    setUp(() {
      store = CleaningGateSessionStore.instance;
      store.reset();
    });

    test('start verification user-dismissed suppression can be forced', () {
      store.suppressStartVerification(
        11,
        CleaningGateSuppressionReason.userDismissed,
      );

      expect(store.isStartVerificationSuppressed(11), isTrue);
      expect(store.isStartVerificationSuppressed(11, force: true), isFalse);
    });

    test('start verification suppression is isolated per booking', () {
      store.suppressStartVerification(
        11,
        CleaningGateSuppressionReason.userDismissed,
      );

      expect(store.isStartVerificationSuppressed(11), isTrue);
      expect(store.isStartVerificationSuppressed(22), isFalse);
    });

    test('start verification permanent suppression blocks even force mode', () {
      store.suppressStartVerification(
        11,
        CleaningGateSuppressionReason.bookingTimeExpired,
      );

      expect(store.isStartVerificationSuppressed(11), isTrue);
      expect(store.isStartVerificationSuppressed(11, force: true), isTrue);
    });

    test(
      'completion suppression clears after leaving awaiting-completion status',
      () {
        store.suppressCompletion(
          22,
          CleaningGateSuppressionReason.userDismissed,
          currentAwaitingCycleOnly: true,
        );
        expect(store.isCompletionSuppressed(22), isTrue);

        store.syncWithStatus(
          bookingId: 22,
          normalizedStatus: CleaningBookingStatus.inProgress,
        );
        expect(store.isCompletionSuppressed(22), isFalse);
      },
    );
  });

  group('CleaningGateSessionStore time helpers', () {
    test(
      'resolves start and end time from scheduled date/time and duration',
      () {
        final start = resolveCleaningBookingStartDateTime(
          scheduledDate: '2026-05-17',
          scheduledTime: '10:30:00',
        );
        final end = resolveCleaningBookingEndDateTime(
          scheduledDate: '2026-05-17',
          scheduledTime: '10:30:00',
          totalHours: 2,
          estimatedHours: null,
        );

        expect(start, isNotNull);
        expect(end, isNotNull);
        expect(end!.difference(start!).inMinutes, 120);
      },
    );

    test('returns false for past-end check when date/time is incomplete', () {
      final expired = isCleaningBookingPastEndTime(
        scheduledDate: null,
        scheduledTime: '10:30:00',
        totalHours: 2,
        estimatedHours: null,
        now: DateTime.parse('2026-05-17T13:00:00'),
      );
      expect(expired, isFalse);
    });

    test('detects expired booking end time with provided now', () {
      final expired = isCleaningBookingPastEndTime(
        scheduledDate: '2026-05-17',
        scheduledTime: '10:00:00',
        totalHours: 1.5,
        estimatedHours: null,
        now: DateTime.parse('2026-05-17T12:00:00'),
      );
      expect(expired, isTrue);
    });
  });
}
