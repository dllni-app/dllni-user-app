import 'package:dllni_user_app/features/orders/data/models/cleaning_orders_api_models.dart';
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
                    completionRequest: const CleaningCompletionRequestModel(
                      workerId: 8,
                      assignmentId: 14,
                      message: 'Please check the kitchen counter.',
                      finishedCleaningServices: [
                        CleaningCompletionSnapshotItemModel(
                          label: 'Kitchen cleaning',
                        ),
                      ],
                    ),
                    fetchExtensionTimeRanges: () async => [
                      CleaningExtensionRangeModel(
                        startMinutes: 1,
                        endMinutes: 30,
                        label: '30 دقيقة',
                        price: 10000,
                        currency: 'SYP',
                      ),
                      CleaningExtensionRangeModel(
                        startMinutes: 31,
                        endMinutes: 60,
                        label: '60 دقيقة',
                        price: 18000,
                        currency: 'SYP',
                      ),
                      CleaningExtensionRangeModel(
                        startMinutes: 61,
                        endMinutes: 90,
                        label: '90 دقيقة',
                        price: 25000,
                        currency: 'SYP',
                      ),
                    ],
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

  testWidgets('shows only the completing worker tasks and note', (
    WidgetTester tester,
  ) async {
    await _openSheet(tester, onExtend: (_) async => null);

    expect(find.text('Kitchen cleaning'), findsOneWidget);
    expect(find.text('Please check the kitchen counter.'), findsOneWidget);
    expect(find.text('صالون'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
