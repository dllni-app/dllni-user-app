import 'package:dllni_user_app/features/cl_main/view/screens/cleaning_first_welcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('welcome is optional and skip persists its seen flag', (
    tester,
  ) async {
    expect(await CleaningFirstWelcome.shouldPresent(), isTrue);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CleaningFirstWelcome(onStart: () {}),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('أهلًا في ع الندهة!'), findsOneWidget);
    await tester.tap(find.text('تخطي'));
    await tester.pumpAndSettle();
    expect(await CleaningFirstWelcome.shouldPresent(), isFalse);
  });

  testWidgets('platform intro covers all services with visible progress', (
    tester,
  ) async {
    var started = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      CleaningFirstWelcome(onStart: () => started = true),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('1 من 6'), findsOneWidget);
    expect(find.byKey(const Key('platform_intro_progress')), findsOneWidget);
    for (final title in [
      'بيتك مرتب، ووقتك إلك',
      'وجبتك المفضلة أقرب',
      'احتياجات بيتك بدون مشوار',
      'أرسلها وخلي علينا المشوار',
      'تفاصيل واضحة من البداية',
    ]) {
      await tester.tap(find.text('التالي'));
      await tester.pumpAndSettle();
      expect(find.text(title), findsOneWidget);
    }
    expect(find.text('6 من 6'), findsOneWidget);
    await tester.tap(find.text('يلا اكتشف الخدمات'));
    await tester.pumpAndSettle();
    expect(started, isTrue);
    expect(await CleaningFirstWelcome.shouldPresent(), isFalse);
  });

  testWidgets(
    'services intro is independent and opens cleaning on completion',
    (tester) async {
      var started = false;
      expect(await CleaningFirstWelcome.shouldPresentServices(), isTrue);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CleaningFirstWelcome(
                      servicesSection: true,
                      onStart: () => started = true,
                    ),
                  ),
                ),
                child: const Text('open services'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open services'));
      await tester.pumpAndSettle();
      expect(find.text('بيتك علينا، ووقتك إلك'), findsOneWidget);
      expect(find.text('1 من 5'), findsOneWidget);
      for (final title in [
        'كل غرفة إلها عنايتها',
        'حتى التفاصيل الصغيرة إلها حل',
        'فريق يناسب حجم الشغل',
        'كل شيء واضح من البداية',
      ]) {
        await tester.tap(find.text('التالي'));
        await tester.pumpAndSettle();
        expect(find.text(title), findsOneWidget);
      }
      expect(find.text('5 من 5'), findsOneWidget);
      await tester.tap(find.text('يلا نحجز خدمة'));
      await tester.pumpAndSettle();
      expect(started, isTrue);
      expect(await CleaningFirstWelcome.shouldPresentServices(), isFalse);
      expect(await CleaningFirstWelcome.shouldPresent(), isTrue);
    },
  );
}
