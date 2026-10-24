import 'package:dllni_user_app/features/orders/data/models/orders_api_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('English delivery enum becomes Arabic for restaurant order list', () {
    final order = OrderResourceModel(deliverySummary: DeliverySummaryModel(
      enabled: true, status: 'ready_for_pickup',
      statusLabelAr: 'ready_for_pickup',
    ));
    expect(order.deliveryStatusLabel, 'جاهز للاستلام من المطعم');
  });

  test('localized status from server remains unchanged', () {
    final order = OrderResourceModel(deliverySummary: DeliverySummaryModel(
      enabled: true, status: 'picked_up',
      statusLabelAr: 'في الطريق إليك',
    ));
    expect(order.deliveryStatusLabel, 'في الطريق إليك');
  });
}
