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
    expect(find.text('12 أيلول 2026'), findsOneWidget);
    expect(find.text('19 أيلول 2026'), findsOneWidget);

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
    expect(find.text('يمكن حجز حتى 5 زيارات خلال 30 يومًا.'), findsOneWidget);
    expect(find.text('إضافة زيارة أخرى'), findsNothing);
    expect(find.byTooltip('تعديل الزيارة'), findsNothing);
    expect(find.byTooltip('حذف الزيارة'), findsNothing);

    await tester.tap(find.byTooltip('زيادة عدد الزيارات'));
    expect(occurrences, 4);

    await tester.tap(find.byTooltip('تقليل عدد الزيارات'));
    expect(occurrences, 2);
  });

  testWidgets('monthly schedule explains the 90-day range', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(800, 1200);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final sessions = CleaningRecurringScheduleGenerator.generate(
      pattern: CleaningRecurringPattern.monthly,
      startDate: DateTime(2026, 10, 14),
      time: '10:00',
      occurrences: 2,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ClRecurringScheduleSectionWidget(
              enabled: true,
              pattern: CleaningRecurringPattern.monthly,
              occurrences: 2,
              maxOccurrences: 3,
              sessions: sessions,
              onEnabledChanged: (_) {},
              onPatternChanged: (_) {},
              onOccurrencesChanged: (_) {},
              onAddVisit: () {},
              onEditVisit: (_) {},
              onRemoveVisit: (_) {},
            ),
          ),
        ),
      ),
    );
    expect(find.text('يمكن حجز حتى 3 زيارات خلال 90 يومًا.'), findsOneWidget);
    expect(find.textContaining('30 يوم'), findsNothing);
    expect(find.text('14 تشرين الثاني 2026'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('recurring dates page omits billing and worker scope choices', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(800, 1200);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final sessions = <CleaningRecurringSessionInput>[
      CleaningRecurringSessionInput(date: DateTime(2026, 9, 12), time: '09:00'),
      CleaningRecurringSessionInput(date: DateTime(2026, 9, 19), time: '09:00'),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ClRecurringScheduleSectionWidget(
              enabled: true,
              pattern: CleaningRecurringPattern.custom,
              calculationMode: CleaningRecurringCalculationMode.hours,
              hoursPerVisit: 2,
              workerScope: CleaningRecurringWorkerScope.any,
              occurrences: 2,
              maxOccurrences: 0,
              sessions: sessions,
              onEnabledChanged: (_) {},
              onPatternChanged: (_) {},
              onOccurrencesChanged: (_) {},
              onAddVisit: () {},
              onEditVisit: (_) {},
              onRemoveVisit: (_) {},
            ),
          ),
        ),
      ),
    );
    expect(find.textContaining('حدد أيام الزيارات ومواعيدها'), findsOneWidget);
    expect(find.textContaining('12 أيلول 2026'), findsOneWidget);
    expect(find.textContaining('19 أيلول 2026'), findsOneWidget);
    expect(find.text('حسب المهام'), findsNothing);
    expect(find.text('نطاق العمال لكل زيارة'), findsNothing);
    expect(find.text('طريقة الحساب لكل زيارة'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
