import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_recurring_session.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_recurring_schedule_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows recurring visits and forwards schedule actions', (
    tester,
  ) async {
    var enabled = true;
    var addCount = 0;
    int? editedIndex;
    int? removedIndex;

    final sessions = <CleaningRecurringSessionInput>[
      CleaningRecurringSessionInput(date: DateTime(2026, 9, 12), time: '09:00'),
      CleaningRecurringSessionInput(date: DateTime(2026, 9, 19), time: '09:00'),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ClRecurringScheduleSectionWidget(
            enabled: enabled,
            sessions: sessions,
            onEnabledChanged: (value) => enabled = value,
            onAddVisit: () => addCount++,
            onEditVisit: (index) => editedIndex = index,
            onRemoveVisit: (index) => removedIndex = index,
          ),
        ),
      ),
    );

    expect(find.text('حجز دوري لخدمة التنظيف'), findsOneWidget);
    expect(find.text('2026-09-12 • 09:00'), findsOneWidget);
    expect(find.text('2026-09-19 • 09:00'), findsOneWidget);

    await tester.tap(find.text('إضافة زيارة أخرى'));
    expect(addCount, 1);

    await tester.tap(find.byTooltip('تعديل الزيارة').first);
    expect(editedIndex, 0);

    await tester.tap(find.byTooltip('حذف الزيارة'));
    expect(removedIndex, 1);

    await tester.tap(find.byType(Switch).first);
    expect(enabled, isFalse);
  });
}
