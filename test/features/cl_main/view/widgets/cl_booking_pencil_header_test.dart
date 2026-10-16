import 'package:dllni_user_app/features/cl_main/view/widgets/cl_booking_pencil_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('every cleaning step uses the same exit header', (tester) async {
    var exited = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(appBar: ClBookingTopBar(onExit: () => exited = true)),
      ),
    );
    expect(find.text('حجز تنظيف'), findsOneWidget);
    expect(find.byTooltip('الخروج من الطلب'), findsOneWidget);
    await tester.tap(find.byTooltip('الخروج من الطلب'));
    expect(exited, isTrue);
  });

  testWidgets('progress header labels first and final step correctly', (
    tester,
  ) async {
    Future<void> show(int step) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: ClBookingPencilHeader(
              step: step,
              title: 'عنوان التجربة',
              subtitle: 'شرح التجربة',
            ),
          ),
        ),
      ),
    );
    await show(0);
    expect(find.text('1 / 7'), findsOneWidget);
    await show(6);
    expect(find.text('7 / 7'), findsOneWidget);
  });
}
