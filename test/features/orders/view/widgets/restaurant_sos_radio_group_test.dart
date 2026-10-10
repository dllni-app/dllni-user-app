import 'package:dllni_user_app/features/orders/view/widgets/restaurant_order_sos_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SOS selection and validation work with RadioGroup', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 950);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RestaurantOrderSosSheet(orderId: 42, bookingType: 'restaurant'),
        ),
      ),
    );

    expect(
      tester
          .widget<RadioGroup<String>>(find.byType(RadioGroup<String>))
          .groupValue,
      'safety_threat',
    );
    await tester.tap(find.text('حدثت حالة طبية طارئة'));
    await tester.pump();
    expect(
      tester
          .widget<RadioGroup<String>>(find.byType(RadioGroup<String>))
          .groupValue,
      'medical_emergency',
    );

    await tester.tap(find.text('إرسال SOS'));
    await tester.pump();
    expect(find.text('يرجى وصف المشكلة قبل إرسال SOS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
