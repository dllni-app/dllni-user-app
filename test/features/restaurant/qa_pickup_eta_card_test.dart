import 'package:dllni_user_app/features/orders/view/widgets/restaurant_order_eta_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('pickup ETA is labeled as preparation time with Arabic minutes', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RestaurantOrderEtaCard(
        etaText: '25 دقيقة', title: 'الوقت المتوقع لتجهيز الطلب',
      ))),
    );
    expect(find.text('الوقت المتوقع لتجهيز الطلب'), findsOneWidget);
    expect(find.text('25 دقيقة'), findsOneWidget);
  });
}
