import 'package:dllni_user_app/core/models/cleaning_service_extras.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_open_time_sessions_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget subject({
    required List<CleaningOpenTimeSessionRequest> sessions,
    VoidCallback? onAdd,
    ValueChanged<int>? onEdit,
    ValueChanged<int>? onRemove,
    void Function(int index, int minutes)? onDurationChanged,
    double textScale = 1,
  }) {
    return MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: Scaffold(
            body: SingleChildScrollView(
              child: ClOpenTimeSessionsSectionWidget(
                sessions: sessions,
                durationOptions: const <int>[120, 180, 240],
                defaultExpectedMaxMinutes: 120,
                onAddSession: onAdd ?? () {},
                onEditSession: onEdit ?? (_) {},
                onRemoveSession: onRemove ?? (_) {},
                onDurationChanged: onDurationChanged ?? (_, _) {},
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows independent sessions and forwards all decisions', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 1100);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    var additions = 0;
    int? edited;
    int? removed;
    (int, int)? durationChange;
    const sessions = <CleaningOpenTimeSessionRequest>[
      CleaningOpenTimeSessionRequest(
        date: '2026-09-12',
        time: '09:00',
        expectedMaxMinutes: 120,
      ),
      CleaningOpenTimeSessionRequest(
        date: '2026-09-14',
        time: '15:00',
        expectedMaxMinutes: 180,
      ),
    ];

    await tester.pumpWidget(
      subject(
        sessions: sessions,
        onAdd: () => additions++,
        onEdit: (index) => edited = index,
        onRemove: (index) => removed = index,
        onDurationChanged: (index, minutes) =>
            durationChange = (index, minutes),
      ),
    );

    expect(find.text('مواعيد الطلب المفتوح'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'جلسة الوقت المفتوح رقم 1',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'جلسة الوقت المفتوح رقم 2',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('إضافة يوم آخر'));
    expect(additions, 1);
    await tester.tap(find.text('تعديل الموعد').first);
    expect(edited, 0);
    await tester.tap(find.text('حذف'));
    expect(removed, 1);

    await tester.tap(find.byType(DropdownButtonFormField<int>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('4 ساعات').last);
    await tester.pumpAndSettle();
    expect(durationChange, (0, 240));

    for (final button in find.byType(TextButton).evaluate()) {
      expect(
        tester.getSize(find.byWidget(button.widget)).height,
        greaterThanOrEqualTo(48),
      );
    }
  });

  testWidgets('does not overflow on a narrow RTL screen with large text', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 1400);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      subject(
        textScale: 2,
        sessions: const <CleaningOpenTimeSessionRequest>[
          CleaningOpenTimeSessionRequest(
            date: '2026-09-12',
            time: '09:00',
            expectedMaxMinutes: 120,
          ),
          CleaningOpenTimeSessionRequest(
            date: '2026-09-14',
            time: '15:00',
            expectedMaxMinutes: 180,
          ),
        ],
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('إضافة يوم آخر'), findsOneWidget);
  });
}
