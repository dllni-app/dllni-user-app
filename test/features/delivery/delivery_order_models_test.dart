import 'package:dllni_user_app/features/delivery/data/models/delivery_order_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DeliveryOrderModel parses contract sample', () {
    final order = DeliveryOrderModel.fromJson({
      'id': 101,
      'orderNumber': 'DO-2026-000101',
      'status': 'accepted',
      'statusLabelAr': 'تم قبول الطلب',
      'tracking': {
        'currentStatus': 'accepted',
        'currentStatusLabelAr': 'تم قبول الطلب',
        'eta': {'minutes': 12, 'text': '12 دقيقة'},
        'timeline': [
          {
            'key': 'created',
            'timestamp': '2026-06-03T07:50:00+03:00',
            'completed': true,
            'active': false,
          },
        ],
        'map': {
          'enabled': true,
          'centerLatitude': 33.5105,
          'centerLongitude': 36.2834,
          'zoom': 13.5,
          'markers': [
            {
              'kind': 'driver',
              'latitude': 33.514,
              'longitude': 36.2767,
            },
          ],
        },
      },
    });

    expect(order.id, 101);
    expect(order.tracking?.currentStatus, 'accepted');
    expect(order.tracking?.eta?.minutes, 12);
    expect(order.tracking?.timeline.first.key, 'created');
    expect(order.isTerminal, isFalse);
  });
}
