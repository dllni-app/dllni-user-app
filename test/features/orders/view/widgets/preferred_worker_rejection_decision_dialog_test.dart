import 'package:dllni_user_app/features/orders/data/models/cleaning_orders_api_models.dart';
import 'package:dllni_user_app/features/orders/view/widgets/preferred_worker_rejection_decision_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('submits convert-to-open decision', (tester) async {
    PreferredWorkerRejectionDecisionAction? action;
    var convertCalls = 0;

    await tester.pumpWidget(
      _DialogHarness(
        onConvert: () async {
          convertCalls++;
          return null;
        },
        onCancel: () async => null,
        onResult: (value) => action = value,
      ),
    );

    await tester.tap(find.byKey(const Key('open-dialog')));
    await tester.pumpAndSettle();

    expect(find.text('رفض العامل المخصص الطلب'), findsOneWidget);
    expect(find.text('نعم، ابحث عن عامل بديل'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('رفض العامل المخصص الطلب'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('preferred-worker-rejection-convert-button')),
    );
    await tester.pumpAndSettle();

    expect(convertCalls, 1);
    expect(action, PreferredWorkerRejectionDecisionAction.convertToOpen);
    expect(find.text('رفض العامل المخصص الطلب'), findsNothing);
  });

  testWidgets('keeps dialog open when cancel decision fails', (tester) async {
    await tester.pumpWidget(
      _DialogHarness(
        onConvert: () async => null,
        onCancel: () async => 'تعذر تنفيذ القرار',
      ),
    );

    await tester.tap(find.byKey(const Key('open-dialog')));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('preferred-worker-rejection-cancel-button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('تعذر تنفيذ القرار'), findsOneWidget);
    expect(find.text('رفض العامل المخصص الطلب'), findsOneWidget);
  });
}

class _DialogHarness extends StatelessWidget {
  const _DialogHarness({
    required this.onConvert,
    required this.onCancel,
    this.onResult,
  });

  final Future<String?> Function() onConvert;
  final Future<String?> Function() onCancel;
  final ValueChanged<PreferredWorkerRejectionDecisionAction?>? onResult;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: Center(
              child: TextButton(
                key: const Key('open-dialog'),
                onPressed: () async {
                  final result =
                      await PreferredWorkerRejectionDecisionDialog.show(
                        context,
                        order: CleaningOrderModel(
                          id: 77,
                          bookingNumber: 'CL-77',
                        ),
                        onConvertToOpen: onConvert,
                        onCancel: onCancel,
                      );
                  onResult?.call(result);
                },
                child: const Text('open'),
              ),
            ),
          );
        },
      ),
    );
  }
}
