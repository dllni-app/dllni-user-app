import 'package:dllni_user_app/features/orders/view/screens/cleaning_order_sos_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('emergency location is strictly opt-in', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: CleaningOrderSosScreen(
            args: CleaningOrderSosArgs(orderId: 81),
          ),
        ),
      ),
    );
    expect(find.text('مشاركة موقعي الحالي'), findsNothing);
    await tester.tap(find.text('حالة طوارئ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('أشعر بعدم الأمان أو بوجود تهديد'));
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    final switchFinder = find.byKey(const Key('v7_emergency_location_opt_in'));
    expect(switchFinder, findsOneWidget);
    SwitchListTile locationTile() =>
        tester.widget<SwitchListTile>(switchFinder);
    expect(locationTile().value, false);
    await tester.ensureVisible(switchFinder);
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();
    expect(locationTile().value, true);
    expect(find.textContaining('اختياري'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
