import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/v6_booking_decision_guide.dart';

Widget makeWidget(V6BookingDecisionTopic topic) => MaterialApp(
  home: Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: V6BookingDecisionGuide(topic: topic),
      ),
    ),
  ),
);

void main() {
  test('all critical booking choices provide useful distinct examples', () {
    final seen = <String>{};
    for (final topic in V6BookingDecisionTopic.values) {
      final copy = V6DecisionCopy.forTopic(topic);
      expect(copy.title, isNotEmpty);
      expect(copy.summary, isNotEmpty);
      expect(
        copy.examples.length,
        greaterThanOrEqualTo(
          topic == V6BookingDecisionTopic.appointment ? 2 : 3,
        ),
      );
      expect(copy.examples.toSet().length, copy.examples.length);
      expect(seen.add(copy.title), isTrue);
    }
  });

  testWidgets('appointment tips do not mislabel a second date as recurring', (
    tester,
  ) async {
    final tips = V6DecisionCopy.forTopic(V6BookingDecisionTopic.appointment);
    expect(tips.examples, hasLength(2));
    expect(
      tips.examples.any((example) => example.contains('الحجز الدوري')),
      isFalse,
    );
    await tester.pumpWidget(makeWidget(V6BookingDecisionTopic.appointment));
    await tester.tap(find.text('لست متأكداً؟'));
    await tester.pumpAndSettle();
    expect(find.textContaining('إذا كنت تحتاج زيارة أخرى'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'one compact explanation with expandable help and real support link',
    (tester) async {
      await tester.pumpWidget(
        makeWidget(V6BookingDecisionTopic.tasksAndExtras),
      );
      expect(find.text('متى أضيف خدمات إضافية؟'), findsOneWidget);
      expect(find.text('لست متأكداً؟'), findsOneWidget);
      expect(find.textContaining('اكتب مهمة خاصة'), findsNothing);
      await tester.tap(find.text('لست متأكداً؟'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('اكتب مهمة خاصة في وصف الطلب'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('booking_decision_contact_support')),
        findsOneWidget,
      );
      await tester.ensureVisible(find.text('فهمت'));
      await tester.tap(find.text('فهمت'));
      await tester.pumpAndSettle();
      expect(find.textContaining('اكتب مهمة خاصة'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final width in [320.0, 360.0, 430.0]) {
    testWidgets('V6 booking guidance scales at ${width.toInt()}dp RTL 180%', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.8)),
            child: child!,
          ),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: SingleChildScrollView(
                child: V6BookingDecisionGuide(
                  topic: V6BookingDecisionTopic.teamSelection,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
