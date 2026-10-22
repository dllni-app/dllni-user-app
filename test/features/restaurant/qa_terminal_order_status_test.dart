import 'package:dllni_user_app/features/orders/data/models/orders_api_models.dart';
import 'package:dllni_user_app/features/orders/view/widgets/restaurant_order_status_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('cancelled restaurant order shows terminal cancellation instead of pending', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RestaurantOrderStatusStepper(order: OrderResourceModel(status: 'cancelled')),
        ),
      ),
    );
    expect(find.text('تم إلغاء الطلب'), findsOneWidget);
    expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
  });

  testWidgets('rejected restaurant order shows terminal rejection', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RestaurantOrderStatusStepper(order: OrderResourceModel(status: 'rejected')),
        ),
      ),
    );
    expect(find.text('تم رفض الطلب من المطعم'), findsOneWidget);
    expect(find.byIcon(Icons.block_rounded), findsOneWidget);
  });
}
