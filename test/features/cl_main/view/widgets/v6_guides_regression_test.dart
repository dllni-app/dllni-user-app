import 'package:dllni_user_app/features/cl_main/view/widgets/v6_cleaning_discovery.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/v6_hourly_service_guide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> showGuide(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      ),
    );
  }

  testWidgets('cleaning discovery matches the Pencil booking entry', (
    tester,
  ) async {
    await showGuide(tester, V6CleaningDiscoveryIntro(onBookApartment: () {}));
    expect(
      find.byKey(const Key('pencil_cleaning_discovery_hero')),
      findsOneWidget,
    );
    expect(find.text('نظافة على مقاس بيتك'), findsOneWidget);
    expect(find.text('وين بدك ننظّف؟'), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('occasions guidance does not repeat a second explanatory card', (
    tester,
  ) async {
    await showGuide(tester, const V6CleaningOccasionIntro());
    expect(find.text('متى تختار مساعدة في المناسبات؟'), findsOneWidget);
    expect(find.text('مناسبتك تحتاج فريقاً'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hourly examples are explanatory and not selectable cards', (
    tester,
  ) async {
    await showGuide(tester, const V6HourlyServiceGuide());
    expect(find.text('متى تختار عاملاً بالساعة؟'), findsOneWidget);
    expect(find.text('مهام خفيفة ومتنوعة'), findsOneWidget);
    expect(find.byType(InkWell), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
