import 'package:dllni_user_app/features/orders/data/models/cleaning_booking_schedule_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses authoritative multi-day booking schedule response', () {
    final envelope = cleaningMultiDayOrderEnvelopeFromJson(<String, dynamic>{
      'success': true,
      'data': <String, dynamic>{
        'id': 77,
        'bookingId': 77,
        'bookingNumber': 'CL-000077',
        'status': 'worker_assigned',
        'totalPrice': 99000,
        'currency': 'SYP',
        'schedule': <String, dynamic>{
          'mode': 'multi_day',
          'isMultiSession': true,
          'daysCount': 3,
          'completedDaysCount': 1,
          'cancelledDaysCount': 0,
          'remainingDaysCount': 2,
          'totalHours': 9.5,
          'firstDate': '2026-09-10',
          'lastDate': '2026-09-14',
          'nextSession': <String, dynamic>{
            'id': 502,
            'sequence': 2,
            'date': '2026-09-12',
            'time': '17:30',
            'hours': 3.5,
            'status': 'awaiting_start_verification',
            'statusLabel': 'بانتظار تحقق العميل',
            'canConfirmStartVerification': true,
            'canConfirmCompletion': false,
            'canSendSos': true,
            'canCancel': true,
            'pricing': <String, dynamic>{
              'basePrice': 35000,
              'travelFee': 5000,
              'adminMargin': 3000,
              'cancellationFee': 0,
              'totalPrice': 43000,
              'isPricingFinal': true,
              'currency': 'SYP',
            },
            'workerAssignments': <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 9002,
                'workerId': 42,
                'workerName': 'أحمد',
                'status': 'awaiting_start_verification',
                'workerAmount': 30000,
                'currency': 'SYP',
              },
            ],
          },
          'sessions': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 501,
              'sequence': 1,
              'date': '2026-09-10',
              'time': '18:00',
              'hours': 2,
              'status': 'completed',
              'canSendSos': false,
              'canCancel': false,
              'pricing': <String, dynamic>{
                'totalPrice': 30000,
                'currency': 'SYP',
              },
            },
            <String, dynamic>{
              'id': 502,
              'sequence': 2,
              'date': '2026-09-12',
              'time': '17:30',
              'hours': 3.5,
              'status': 'awaiting_start_verification',
              'statusLabel': 'بانتظار تحقق العميل',
              'canConfirmStartVerification': true,
              'canConfirmCompletion': false,
              'canSendSos': true,
              'canCancel': true,
              'pricing': <String, dynamic>{
                'totalPrice': 43000,
                'currency': 'SYP',
              },
              'workerAssignments': <Map<String, dynamic>>[
                <String, dynamic>{
                  'workerId': 42,
                  'workerName': 'أحمد',
                  'status': 'awaiting_start_verification',
                },
              ],
            },
            <String, dynamic>{
              'id': 503,
              'sequence': 3,
              'date': '2026-09-14',
              'time': '19:00',
              'hours': 4,
              'status': 'awaiting_customer_completion',
              'canConfirmStartVerification': false,
              'canConfirmCompletion': true,
              'canSendSos': true,
              'canCancel': false,
            },
          ],
        },
      },
    });

    expect(envelope.bookingId, 77);
    expect(envelope.bookingNumber, 'CL-000077');
    expect(envelope.status, 'worker_assigned');
    expect(envelope.totalPrice, 99000);
    expect(envelope.currency, 'SYP');

    final schedule = envelope.schedule!;
    expect(schedule.isMultiDay, isTrue);
    expect(schedule.daysCount, 3);
    expect(schedule.completedDaysCount, 1);
    expect(schedule.remainingDaysCount, 2);
    expect(schedule.totalHours, 9.5);
    expect(schedule.sessions, hasLength(3));
    expect(schedule.firstDate, DateTime(2026, 9, 10));
    expect(schedule.lastDate, DateTime(2026, 9, 14));

    expect(schedule.nextSession?.id, 502);
    expect(schedule.nextSession?.hours, 3.5);
    expect(schedule.nextSession?.pricing?.totalPrice, 43000);
    expect(schedule.nextSession?.pricing?.isPricingFinal, isTrue);
    expect(schedule.nextSession?.workerAssignments.single.workerId, 42);
    expect(schedule.nextSession?.workerAssignments.single.workerName, 'أحمد');
    expect(schedule.nextSession?.canConfirmStartVerification, isTrue);
    expect(schedule.nextSession?.canConfirmCompletion, isFalse);
    expect(schedule.nextSession?.canSendSos, isTrue);
    expect(schedule.nextSession?.canCancel, isTrue);

    expect(schedule.sessions.first.isCompleted, isTrue);
    expect(schedule.sessions.first.canSendSos, isFalse);
    expect(schedule.sessions[1].statusLabel, 'بانتظار تحقق العميل');
    expect(schedule.sessions[1].pricing?.currency, 'SYP');
    expect(schedule.sessions.last.canConfirmCompletion, isTrue);
    expect(schedule.sessions.last.isTerminal, isFalse);
  });

  test(
    'parses cancelled session fee independently from remaining sessions',
    () {
      final envelope = cleaningMultiDayOrderEnvelopeFromJson(<String, dynamic>{
        'data': <String, dynamic>{
          'id': 91,
          'totalPrice': 6850,
          'currency': 'SYP',
          'schedule': <String, dynamic>{
            'mode': 'multi_day',
            'daysCount': 3,
            'completedDaysCount': 1,
            'cancelledDaysCount': 1,
            'remainingDaysCount': 1,
            'totalHours': 4,
            'sessions': <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 901,
                'sequence': 1,
                'date': '2026-09-10',
                'time': '10:00',
                'hours': 2,
                'status': 'completed',
              },
              <String, dynamic>{
                'id': 902,
                'sequence': 2,
                'date': '2026-09-11',
                'time': '10:00',
                'hours': 2,
                'status': 'cancelled',
                'cancellationReason': 'تم إلغاء اليوم فقط',
                'canCancel': false,
                'canSendSos': false,
                'pricing': <String, dynamic>{
                  'cancellationFee': 250,
                  'totalPrice': 3300,
                  'currency': 'SYP',
                },
              },
              <String, dynamic>{
                'id': 903,
                'sequence': 3,
                'date': '2026-09-12',
                'time': '10:00',
                'hours': 2,
                'status': 'worker_assigned',
                'canCancel': true,
                'canSendSos': true,
              },
            ],
          },
        },
      });

      final cancelled = envelope.schedule!.sessions[1];
      expect(envelope.totalPrice, 6850);
      expect(envelope.schedule?.cancelledDaysCount, 1);
      expect(envelope.schedule?.remainingDaysCount, 1);
      expect(cancelled.isCancelled, isTrue);
      expect(cancelled.pricing?.cancellationFee, 250);
      expect(cancelled.cancellationReason, 'تم إلغاء اليوم فقط');
      expect(cancelled.canCancel, isFalse);
      expect(cancelled.canSendSos, isFalse);
    },
  );

  test('parses recurring session payment review and dispute capabilities', () {
    final envelope = cleaningMultiDayOrderEnvelopeFromJson(<String, dynamic>{
      'data': <String, dynamic>{
        'id': 712,
        'schedule': <String, dynamic>{
          'mode': 'recurring',
          'isRecurring': true,
          'sessions': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 991,
              'sequence': 1,
              'sessionType': 'recurring_cleaning',
              'date': '2026-09-11',
              'time': '10:00',
              'hours': 2,
              'status': 'completed',
              'paymentStatus': 'settled',
              'paymentSettledAt': '2026-09-11T12:00:00+03:00',
              'payment': <String, dynamic>{
                'status': 'settled',
                'amount': 1100,
                'currency': 'SYP',
                'settledAt': '2026-09-11T12:00:00+03:00',
                'isInternalSettlement': true,
              },
              'canReview': true,
              'hasReview': true,
              'reviewedWorkerIds': <int>[41],
              'reviewableWorkerIds': <int>[42],
              'canOpenDispute': false,
              'hasOpenDispute': true,
              'disputeId': 77,
              'disputeStatus': 'open',
            },
          ],
        },
      },
    });

    final session = envelope.schedule!.sessions.single;
    expect(session.paymentStatus, 'settled');
    expect(session.payment?.amount, 1100);
    expect(session.payment?.isInternalSettlement, isTrue);
    expect(session.canReview, isTrue);
    expect(session.reviewedWorkerIds, <int>[41]);
    expect(session.reviewableWorkerIds, <int>[42]);
    expect(session.hasOpenDispute, isTrue);
    expect(session.canOpenDispute, isFalse);
    expect(session.disputeId, 77);
    expect(session.disputeStatus, 'open');
  });

  test('parses single-day schedule fallback without child session id', () {
    final envelope = cleaningMultiDayOrderEnvelopeFromJson(<String, dynamic>{
      'data': <String, dynamic>{
        'id': 88,
        'bookingNumber': 'CL-000088',
        'status': 'pending',
        'schedule': <String, dynamic>{
          'mode': 'single_day',
          'daysCount': 1,
          'completedDaysCount': 0,
          'cancelledDaysCount': 0,
          'remainingDaysCount': 1,
          'totalHours': 4,
          'firstDate': '2026-09-20',
          'lastDate': '2026-09-20',
          'nextSession': null,
          'sessions': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': null,
              'sequence': 1,
              'date': '2026-09-20',
              'time': '09:00',
              'hours': 4,
              'status': 'pending',
              'requiredWorkers': 2,
            },
          ],
        },
      },
    });

    expect(envelope.schedule?.isMultiDay, isFalse);
    expect(envelope.schedule?.sessions, hasLength(1));
    expect(envelope.schedule?.sessions.single.id, isNull);
    expect(envelope.schedule?.sessions.single.hours, 4);
    expect(envelope.schedule?.sessions.single.canSendSos, isFalse);
  });

  test('parses backend event schedule reschedule capability', () {
    final envelope = cleaningMultiDayOrderEnvelopeFromJson(<String, dynamic>{
      'data': <String, dynamic>{
        'id': 501,
        'status': 'pending',
        'schedule': <String, dynamic>{
          'mode': 'multi_day',
          'sessions': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 1,
              'sequence': 1,
              'date': '2026-09-20',
              'time': '09:00',
              'hours': 2,
              'status': 'scheduled',
              'canReschedule': true,
            },
            <String, dynamic>{
              'id': 2,
              'sequence': 2,
              'date': '2026-09-21',
              'time': '09:00',
              'hours': 2,
              'status': 'scheduled',
              'canReschedule': true,
            },
          ],
        },
      },
    });

    expect(envelope.schedule?.sessions, hasLength(2));
    expect(
      envelope.schedule?.sessions.every(
        (session) => session.canReschedule == true,
      ),
      isTrue,
    );
  });

  test('parses recurring late and no-travel attendance capabilities', () {
    final envelope = cleaningMultiDayOrderEnvelopeFromJson(<String, dynamic>{
      'data': <String, dynamic>{
        'id': 700,
        'schedule': <String, dynamic>{
          'mode': 'multi_day',
          'isRecurring': true,
          'sessions': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 701,
              'sequence': 1,
              'sessionType': 'recurring_cleaning',
              'date': '2026-09-06',
              'time': '10:00',
              'hours': 2,
              'status': 'worker_assigned',
              'canReportLate': true,
              'canReportNoTravel': true,
              'lateWorkerIds': <int>[42],
              'noTravelWorkerIds': <int>[42],
              'reportableLateWorkerIds': <int>[42],
              'reportableNoTravelWorkerIds': <int>[42],
              'attendance': <String, dynamic>{
                'lateGraceMinutes': 15,
                'noTravelGraceMinutes': 30,
                'minutesPastStart': 35,
                'incidents': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'workerId': 42,
                    'workerName': 'أحمد',
                    'lateReportedAt': '2026-09-06T10:20:00+03:00',
                    'noTravelReportedAt': null,
                    'action': 'wait',
                    'resolvedAt': null,
                    'note': 'سأنتظر قليلاً',
                  },
                ],
              },
              'workerAssignments': <Map<String, dynamic>>[
                <String, dynamic>{
                  'workerId': 42,
                  'workerName': 'أحمد',
                  'status': 'accepted',
                  'lateReportedAt': '2026-09-06T10:20:00+03:00',
                  'attendanceAction': 'wait',
                  'attendanceNote': 'سأنتظر قليلاً',
                },
              ],
            },
          ],
        },
      },
    });

    final session = envelope.schedule!.sessions.single;
    expect(session.canReportLate, isTrue);
    expect(session.canReportNoTravel, isTrue);
    expect(session.reportableLateWorkerIds, <int>[42]);
    expect(session.reportableNoTravelWorkerIds, <int>[42]);
    expect(session.attendance?.lateGraceMinutes, 15);
    expect(session.attendance?.noTravelGraceMinutes, 30);
    expect(session.attendance?.minutesPastStart, 35);
    expect(session.attendance?.incidents.single.workerName, 'أحمد');
    expect(session.attendance?.incidents.single.action, 'wait');
    expect(session.attendance?.incidents.single.isNoTravel, isFalse);
    expect(session.workerAssignments.single.attendanceAction, 'wait');
    expect(session.workerAssignments.single.attendanceNote, 'سأنتظر قليلاً');
  });
}
