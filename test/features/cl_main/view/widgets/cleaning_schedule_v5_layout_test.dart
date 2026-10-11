import 'package:dllni_user_app/features/cl_main/view/widgets/cl_service_schedule_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in <double>[320, 390, 430]) {
    testWidgets('V7 schedule picker remains readable at ${width.toInt()}dp', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final from = TextEditingController(text: '08:30 صباحاً');
      final to = TextEditingController(text: '11:00 صباحاً');
      addTearDown(() {
        from.dispose();
        to.dispose();
      });
      var pickedDate = 0;
      var pickedTime = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClServiceScheduleSectionWidget(
                  dayAr: 'الأحد',
                  dayDate: '2026/10/11',
                  fromTimeController: from,
                  toTimeController: to,
                  onPickDate: () => pickedDate++,
                  onPickFromTime: () => pickedTime++,
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('الموعد والوقت'), findsOneWidget);
      expect(find.text('تاريخ الخدمة'), findsOneWidget);
      expect(find.text('وقت البدء'), findsOneWidget);
      await tester.tap(find.byKey(const Key('v7_booking_date_picker')));
      await tester.tap(find.byKey(const Key('v7_booking_time_picker')));
      expect(pickedDate, 1);
      expect(pickedTime, 1);
      expect(tester.takeException(), isNull);
    });
  }
}
