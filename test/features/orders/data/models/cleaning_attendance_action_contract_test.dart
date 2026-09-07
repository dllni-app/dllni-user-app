import 'package:dllni_user_app/features/orders/data/models/cleaning_booking_schedule_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps no-travel actions available after the initial report is recorded', () {
    final envelope = cleaningMultiDayOrderEnvelopeFromJson(<String, dynamic>{
      'data': <String, dynamic>{
        'id': 700,
        'schedule': <String, dynamic>{
          'isRecurring': true,
          'sessions': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 701,
              'sequence': 1,
              'sessionType': 'recurring_cleaning',
              'status': 'worker_assigned',
              'canReportLate': false,
              'canReportNoTravel': false,
              'reportableLateWorkerIds': <int>[],
              'reportableNoTravelWorkerIds': <int>[],
              'allowedAttendanceActions': <String>[
                'wait',
                'replace',
                'cancel',
              ],
              'attendanceActionWorkerIds': <String, dynamic>{
                'wait': <int>[42],
                'replace': <int>[42],
                'cancel': <int>[42],
              },
              'attendance': <String, dynamic>{
                'allowedActions': <String>['wait', 'replace', 'cancel'],
                'actionWorkerIds': <String, dynamic>{
                  'wait': <int>[42],
                  'replace': <int>[42],
                  'cancel': <int>[42],
                },
                'incidents': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'workerId': 42,
                    'workerName': 'أحمد',
                    'lateReportedAt': '2026-09-07T10:20:00+03:00',
                    'noTravelReportedAt': '2026-09-07T10:35:00+03:00',
                    'action': 'wait',
                    'resolvedAt': null,
                  },
                ],
              },
            },
          ],
        },
      },
    });

    final session = envelope.schedule!.sessions.single;
    expect(session.hasAttendanceActionContract, isTrue);
    expect(session.canReportNoTravel, isFalse);
    expect(session.allowsAttendanceAction('wait'), isTrue);
    expect(session.allowsAttendanceAction('replace'), isTrue);
    expect(session.allowsAttendanceAction('cancel'), isTrue);
    expect(session.attendanceWorkerIdsFor('replace'), <int>[42]);
    expect(session.attendanceWorkerIdsFor('cancel'), <int>[42]);
    expect(session.hasNoTravelAttendanceActions, isTrue);
  });

  test('explicit empty contract prevents legacy flags from enabling actions', () {
    final session = CleaningBookingSessionModel.fromJson(<String, dynamic>{
      'id': 900,
      'sequence': 1,
      'status': 'worker_assigned',
      'canReportLate': true,
      'canReportNoTravel': true,
      'reportableLateWorkerIds': <int>[42],
      'reportableNoTravelWorkerIds': <int>[42],
      'allowedAttendanceActions': <String>[],
      'attendanceActionWorkerIds': <String, dynamic>{},
      'attendance': <String, dynamic>{
        'allowedActions': <String>[],
        'actionWorkerIds': <String, dynamic>{},
      },
    });

    expect(session.hasAttendanceActionContract, isTrue);
    expect(session.hasAttendanceActions, isFalse);
    expect(session.allowsAttendanceAction('wait'), isFalse);
    expect(session.allowsAttendanceAction('replace'), isFalse);
    expect(session.allowsAttendanceAction('cancel'), isFalse);
  });

  test('legacy attendance capabilities remain compatible before backend rollout', () {
    final session = CleaningBookingSessionModel.fromJson(<String, dynamic>{
      'id': 901,
      'sequence': 1,
      'status': 'worker_assigned',
      'canReportLate': false,
      'canReportNoTravel': true,
      'reportableLateWorkerIds': <int>[],
      'reportableNoTravelWorkerIds': <int>[73],
    });

    expect(session.hasAttendanceActionContract, isFalse);
    expect(session.allowsAttendanceAction('wait'), isTrue);
    expect(session.allowsAttendanceAction('replace'), isTrue);
    expect(session.allowsAttendanceAction('cancel'), isTrue);
    expect(session.attendanceWorkerIdsFor('replace'), <int>[73]);
  });
}
