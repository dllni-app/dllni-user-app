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

  group('Arabic delivery tracking timeline', () {
    DeliveryTimelineStageModel stage(
      String key, {
      bool completed = false,
      bool active = false,
      String? timestamp,
    }) => DeliveryTimelineStageModel(
      key: key,
      completed: completed,
      active: active,
      timestamp: timestamp,
    );

    test('completed delivery excludes all untriggered exceptional stages', () {
      final all = [
        stage('created', completed: true),
        stage('searching_driver', completed: true),
        stage('driver_en_route', completed: true),
        stage('handover_complete', completed: true),
        stage('returning_to_merchant'),
        stage('returned_to_merchant'),
        stage('delivered', completed: true),
        stage('completed', completed: true),
        stage('stopped'),
        stage('cancelled'),
      ];
      final visible = visibleDeliveryTrackingStages(
        all,
        currentStatus: 'completed',
      );
      expect(visible.map((item) => item.key), [
        'created',
        'searching_driver',
        'driver_en_route',
        'handover_complete',
        'delivered',
        'completed',
      ]);
    });

    test('skipped merchant return steps stay hidden even with timestamps', () {
      final stages = [
        stage('created', completed: true),
        stage('picked_up', completed: true),
        stage('returning_to_merchant',
            timestamp: '2026-10-27T14:00:00Z'),
        stage('returned_to_merchant'),
        stage('delivered', completed: true),
        stage('completed', completed: true),
        stage('stopped', active: true),
        stage('cancelled'),
      ];

      expect(
        visibleDeliveryTrackingStages(
          stages,
          currentStatus: 'completed',
        ).map((stage) => stage.key),
        ['created', 'picked_up', 'delivered', 'completed'],
      );
    });

    test('return flow appears after failure and hides unachieved delivery', () {
      final all = [
        stage('created', completed: true),
        stage('picked_up', completed: true),
        stage('returning_to_merchant', completed: true),
        stage('returned_to_merchant', active: true),
        stage('delivered'),
        stage('completed'),
        stage('stopped'),
        stage('cancelled'),
      ];
      final visible = visibleDeliveryTrackingStages(
        all,
        currentStatus: 'returned_to_merchant',
      );
      expect(visible.map((stage) => stage.key), [
        'created',
        'picked_up',
        'returning_to_merchant',
        'returned_to_merchant',
      ]);
    });

    test('cancellation is shown only if real cancellation occurred', () {
      final all = [
        stage('created', completed: true),
        stage('cancelled'),
        stage('stopped'),
        stage('completed'),
      ];
      expect(
        visibleDeliveryTrackingStages(
          all,
          currentStatus: 'dispatching',
        ).map((item) => item.key),
        ['created', 'completed'],
      );
      expect(
        visibleDeliveryTrackingStages(
          all,
          currentStatus: 'cancelled',
        ).map((item) => item.key),
        ['created', 'cancelled'],
      );
    });

    test('event timestamp confirms otherwise unmarked exceptional step', () {
      final visible = visibleDeliveryTrackingStages(
        [stage('returning_to_merchant', timestamp: '2026-10-11T08:00:00Z')],
        currentStatus: 'returned_to_merchant',
      );
      expect(visible.single.key, 'returning_to_merchant');
    });

    test('API English codes never become user-facing status labels', () {
      final order = DeliveryOrderModel.fromJson({
        'status': 'returned_to_merchant',
        'statusLabelAr': 'returned_to_merchant',
        'tracking': {
          'currentStatus': 'returned_to_merchant',
          'currentStatusLabelAr': 'returned_to_merchant',
        },
      });
      expect(order.displayStatusLabel, 'تمت إعادة الطلب إلى المتجر');
      expect(DeliveryTimelineStageModel(key: 'unknown_status').label,
          'تم تحديث حالة الطلب');
    });

    test('no-driver-found wording requires an explicit matching reason', () {
      expect(
        deliveryTrackingStatusLabelAr('stopped'),
        'توقف طلب التوصيل',
      );
      expect(
        deliveryTrackingStatusLabelAr(
          'stopped',
          stopReason: 'no_driver_found',
        ),
        'تعذر العثور على مندوب',
      );
    });

    test('delivered and returned-to-merchant are terminal states', () {
      for (final status in [
        'delivered',
        'returned_to_merchant',
        'rejected',
      ]) {
        final order = DeliveryOrderModel.fromJson({'status': status});
        expect(order.isTerminal, isTrue, reason: status);
      }
    });
  });
}
