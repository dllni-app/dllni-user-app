import 'package:dllni_user_app/features/orders/view/widgets/v7_event_order_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'event details show guests and requested assistance without cleaning rooms',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: V7EventOrderPanel(
              eventType: 'family_dinner',
              guestCount: 10,
              helpDescription: 'تجهيز طاولة العشاء',
              onOpenSessions: () {},
            ),
          ),
        ),
      );
      expect(find.text('تفاصيل المناسبة'), findsOneWidget);
      expect(find.text('عدد الضيوف'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('طبيعة المساعدة'), findsOneWidget);
      expect(find.text('تجهيز طاولة العشاء'), findsOneWidget);
      expect(find.textContaining('غرفة'), findsNothing);
      expect(find.text('عرض أيام وأوقات المناسبة'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('event requirement is not rendered unless it exists', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: V7EventOrderPanel(eventType: 'birthday', guestCount: 20),
        ),
      ),
    );
    expect(find.text('متطلبات إضافية'), findsNothing);
    expect(find.textContaining('غرفة'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
