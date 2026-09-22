import 'package:dllni_user_app/features/orders/data/models/cleaning_orders_api_models.dart';
import 'package:dllni_user_app/features/orders/view/widgets/cleaning_schedule_change_resolution_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows pending worker decisions in RTL with accessible status', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    const change = CleaningScheduleChangeRequestModel(
      id: 3,
      status: 'pending',
      priceDelta: 0,
      sessions: <CleaningScheduleChangeSessionModel>[
        CleaningScheduleChangeSessionModel(date: '2026-09-22', time: '10:00'),
      ],
      decisions: <CleaningScheduleChangeDecisionModel>[
        CleaningScheduleChangeDecisionModel(
          workerName: 'أحمد',
          decision: 'pending',
        ),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SingleChildScrollView(
              child: CleaningScheduleChangeResolutionCard(
                change: change,
                requiredWorkers: 1,
                onResolved: _noop,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('المواعيد الجديدة بانتظار الموافقة'), findsOneWidget);
    expect(find.textContaining('أحمد: بانتظار الرد'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('طلب تعديل مواعيد بانتظار موافقة العمال')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('rejected state exposes three explicit 48dp decisions', (
    tester,
  ) async {
    const change = CleaningScheduleChangeRequestModel(
      id: 4,
      status: 'rejected',
      priceDelta: 200,
      sessions: <CleaningScheduleChangeSessionModel>[],
      decisions: <CleaningScheduleChangeDecisionModel>[],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CleaningScheduleChangeResolutionCard(
            change: change,
            requiredWorkers: 2,
            onResolved: _noop,
          ),
        ),
      ),
    );

    for (final label in <String>[
      'اختيار عامل بديل',
      'التراجع عن التعديل',
      'إلغاء الجلسات المتأثرة',
    ]) {
      final finder = find.text(label);
      expect(finder, findsOneWidget);
      expect(
        tester
            .getSize(
              find.ancestor(of: finder, matching: find.byType(SizedBox)).first,
            )
            .height,
        48,
      );
    }
    expect(tester.takeException(), isNull);
  });
}

void _noop() {}
