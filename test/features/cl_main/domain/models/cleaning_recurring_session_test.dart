import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_recurring_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats recurring session API values canonically', () {
    final session = CleaningRecurringSessionInput(
      date: DateTime(2026, 9, 7),
      time: '09:30',
    );

    expect(session.dateApi, '2026-09-07');
    expect(session.slotKey, '2026-09-07|09:30');
    expect(session.toJson(), <String, dynamic>{
      'date': '2026-09-07',
      'time': '09:30',
    });
  });

  test('normalizes visits before serializing the recurring schedule', () {
    final sessions = <CleaningRecurringSessionInput>[
      CleaningRecurringSessionInput(
        date: DateTime(2026, 9, 21),
        time: '18:00',
      ),
      CleaningRecurringSessionInput(
        date: DateTime(2026, 9, 7),
        time: '09:30',
      ),
      CleaningRecurringSessionInput(
        date: DateTime(2026, 9, 14),
        time: '12:00',
      ),
    ];

    expect(
      sessions.normalized.map((item) => item.slotKey).toList(),
      <String>[
        '2026-09-07|09:30',
        '2026-09-14|12:00',
        '2026-09-21|18:00',
      ],
    );
    expect(sessions.scheduleJson, <String, dynamic>{
      'mode': 'recurring',
      'sessions': <Map<String, dynamic>>[
        <String, dynamic>{'date': '2026-09-07', 'time': '09:30'},
        <String, dynamic>{'date': '2026-09-14', 'time': '12:00'},
        <String, dynamic>{'date': '2026-09-21', 'time': '18:00'},
      ],
    });
  });

  test('does not serialize a recurring schedule for an empty visit list', () {
    const sessions = <CleaningRecurringSessionInput>[];

    expect(sessions.scheduleJson, isNull);
  });
}
