import 'package:dllni_user_app/features/cl_main/view/widgets/cl_service_worker_count_selector_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('worker selector caps the displayed team size at 20', (
    tester,
  ) async {
    int? nextCount;
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: ClServiceWorkerCountSelectorWidget(
              count: 30,
              maxCount: 30,
              onChanged: (value) => nextCount = value,
            ),
          ),
        ),
      ),
    );
    expect(
      find.text('الحد الأقصى 20 عامل (حسب عدد الغرف والمساحات)'),
      findsOneWidget,
    );
    expect(find.text('20'), findsOneWidget);
    final addButton = tester.widget<InkWell>(
      find
          .ancestor(of: find.byIcon(Icons.add), matching: find.byType(InkWell))
          .first,
    );
    expect(addButton.onTap, isNull);
    expect(nextCount, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('incrementing within the allowed range reports a valid count', (
    tester,
  ) async {
    int? nextCount;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ClServiceWorkerCountSelectorWidget(
            count: 2,
            maxCount: 5,
            onChanged: (value) => nextCount = value,
          ),
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.add));
    expect(nextCount, 3);
  });
}
