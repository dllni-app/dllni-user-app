import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_recurring_session.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_recurring_schedule_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows custom recurring visits and forwards manual actions', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(800, 1200);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
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
            pattern: CleaningRecurringPattern.custom,
            occurrences: sessions.length,
            maxOccurrences: 0,
            sessions: sessions,
            onEnabledChanged: (value) => enabled = value,
            onPatternChanged: (_) {},
            onOccurrencesChanged: (_) {},
            onAddVisit: () => addCount++,
            onEditVisit: (index) => editedIndex = index,
            onRemoveVisit: (index) => removedIndex = index,
          ),
        ),
      ),
    );

    expect(find.text('حجز دوري لخدمة التنظيف'), findsOneWidget);
    expect(find.text('تواريخ مخصصة'), findsOneWidget);
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

  testWidgets('shows generated pattern count controls without manual editing', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(800, 1200);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var pattern = CleaningRecurringPattern.weekly;
    var occurrences = 3;

    final sessions = CleaningRecurringScheduleGenerator.generate(
      pattern: pattern,
      startDate: DateTime(2026, 9, 12),
      time: '09:00',
      occurrences: occurrences,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ClRecurringScheduleSectionWidget(
            enabled: true,
            pattern: pattern,
            occurrences: occurrences,
            maxOccurrences: 5,
            sessions: sessions,
            onEnabledChanged: (_) {},
            onPatternChanged: (value) => pattern = value,
            onOccurrencesChanged: (value) => occurrences = value,
            onAddVisit: () {},
            onEditVisit: (_) {},
            onRemoveVisit: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('أسبوعي'), findsOneWidget);
    expect(find.text('عدد الزيارات'), findsOneWidget);
    expect(
      find.text('الحد الأقصى لهذا النمط ضمن 30 يوماً: 5 زيارات.'),
      findsOneWidget,
    );
    expect(find.text('إضافة زيارة أخرى'), findsNothing);
    expect(find.byTooltip('تعديل الزيارة'), findsNothing);
    expect(find.byTooltip('حذف الزيارة'), findsNothing);

    await tester.tap(find.byTooltip('زيادة عدد الزيارات'));
    expect(occurrences, 4);

    await tester.tap(find.byTooltip('تقليل عدد الزيارات'));
    expect(occurrences, 2);
  });

  testWidgets('forwards recurring calculation mode and hour changes', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(800, 1200);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var mode = CleaningRecurringCalculationMode.task;
    var hours = 2.0;
    final sessions = <CleaningRecurringSessionInput>[
      CleaningRecurringSessionInput(date: DateTime(2026, 9, 12), time: '09:00'),
      CleaningRecurringSessionInput(date: DateTime(2026, 9, 19), time: '09:00'),
    ];

    Future<void> pump() => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ClRecurringScheduleSectionWidget(
            enabled: true,
            pattern: CleaningRecurringPattern.custom,
            calculationMode: mode,
            hoursPerVisit: hours,
            occurrences: 2,
            maxOccurrences: 0,
            sessions: sessions,
            onEnabledChanged: (_) {},
            onPatternChanged: (_) {},
            onCalculationModeChanged: (value) => mode = value,
            onHoursPerVisitChanged: (value) => hours = value,
            onOccurrencesChanged: (_) {},
            onAddVisit: () {},
            onEditVisit: (_) {},
            onRemoveVisit: (_) {},
          ),
        ),
      ),
    );

    await pump();
    await tester.tap(find.text('حسب المهام'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حسب الساعات').last);
    expect(mode, CleaningRecurringCalculationMode.hours);

    mode = CleaningRecurringCalculationMode.hours;
    await pump();
    expect(find.text('الساعات لكل زيارة'), findsOneWidget);
    await tester.tap(find.byTooltip('زيادة ساعات الزيارة'));
    expect(hours, 2.5);
  });

  testWidgets('forwards recurring worker scope and explains specific lock', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(800, 1200);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var scope = CleaningRecurringWorkerScope.any;
    final sessions = <CleaningRecurringSessionInput>[
      CleaningRecurringSessionInput(date: DateTime(2026, 9, 12), time: '09:00'),
      CleaningRecurringSessionInput(date: DateTime(2026, 9, 19), time: '09:00'),
    ];

    Future<void> pump() => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ClRecurringScheduleSectionWidget(
            enabled: true,
            pattern: CleaningRecurringPattern.custom,
            workerScope: scope,
            occurrences: 2,
            maxOccurrences: 0,
            sessions: sessions,
            onEnabledChanged: (_) {},
            onPatternChanged: (_) {},
            onWorkerScopeChanged: (value) => scope = value,
            onOccurrencesChanged: (_) {},
            onAddVisit: () {},
            onEditVisit: (_) {},
            onRemoveVisit: (_) {},
          ),
        ),
      ),
    );

    await pump();
    expect(find.text('نطاق العمال لكل زيارة'), findsOneWidget);
    expect(find.text('أي عامل متاح'), findsOneWidget);
    await tester.tap(find.text('أي عامل متاح'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('عمال محددون فقط').last);
    expect(scope, CleaningRecurringWorkerScope.specific);

    await pump();
    expect(
      find.text(
        'تُحصر الزيارات بالعمال الذين تختارهم فقط، ولن يتم فتحها تلقائياً لعمال آخرين.',
      ),
      findsOneWidget,
    );
  });
}
