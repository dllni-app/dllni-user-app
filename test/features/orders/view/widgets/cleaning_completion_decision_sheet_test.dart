import 'package:dllni_user_app/features/orders/view/widgets/cleaning_completion_decision_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> _openSheet(
  WidgetTester tester, {
  required Future<String?> Function(int minutes) onExtend,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  CleaningCompletionDecisionSheet.show(
                    context,
                    onConfirm: () async => null,
                    onReject: (_) async => null,
                    onExtend: onExtend,
                  );
                },
                child: const Text('open'),
              ),
            ),
          );
        },
      ),
    ),
  );

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('ar');
  });

  testWidgets('shows mock extension options with prices', (
    WidgetTester tester,
  ) async {
    await _openSheet(tester, onExtend: (_) async => null);

    await tester.tap(find.byKey(const Key('completion_extend_button')));
    await tester.pumpAndSettle();

    expect(find.text('طلب تمديد وقت إضافي'), findsOneWidget);
    expect(find.textContaining('30 دقيقة'), findsOneWidget);
    expect(find.textContaining('10,000'), findsOneWidget);
    expect(find.textContaining('60 دقيقة'), findsOneWidget);
    expect(find.textContaining('18,000'), findsOneWidget);
    expect(find.textContaining('90 دقيقة'), findsOneWidget);
    expect(find.textContaining('25,000'), findsOneWidget);
    expect(find.textContaining('120 دقيقة'), findsOneWidget);
    expect(find.textContaining('32,000'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('submits selected extension minutes', (
    WidgetTester tester,
  ) async {
    int? submittedMinutes;
    await _openSheet(
      tester,
      onExtend: (minutes) async {
        submittedMinutes = minutes;
        return null;
      },
    );

    await tester.tap(find.byKey(const Key('completion_extend_button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('extension_option_90')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('extension_submit')));
    await tester.pumpAndSettle();

    expect(submittedMinutes, 90);
    expect(find.text('أرغب في تمديد الوقت'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('cancel does not submit extension request', (
    WidgetTester tester,
  ) async {
    var extendCalled = false;
    await _openSheet(
      tester,
      onExtend: (_) async {
        extendCalled = true;
        return null;
      },
    );

    await tester.tap(find.byKey(const Key('completion_extend_button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('extension_cancel')));
    await tester.pumpAndSettle();

    expect(extendCalled, isFalse);
    expect(find.text('أرغب في تمديد الوقت'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
