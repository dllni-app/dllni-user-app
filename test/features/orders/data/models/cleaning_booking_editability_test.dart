import 'package:dllni_user_app/features/orders/data/models/cleaning_orders_api_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses canEdit and accepted worker count from backend response', () {
    final order = CleaningOrderDetailModel.fromJson({
      'id': 7,
      'status': 'pending',
      'canEdit': true,
      'accepted_workers_count': 2,
    });

    expect(order.canEdit, isTrue);
    expect(order.acceptedWorkersCount, 2);
  });

  test('supports snake_case can_edit compatibility alias', () {
    final order = CleaningOrderDetailModel.fromJson({
      'id': 8,
      'status': 'completed',
      'can_edit': false,
      'acceptedWorkersCount': 1,
    });

    expect(order.canEdit, isFalse);
    expect(order.acceptedWorkersCount, 1);
  });

  test('preserves editability fields when converting detail to list model', () {
    final detail = CleaningOrderDetailModel.fromJson({
      'id': 9,
      'status': 'worker_assigned',
      'canEdit': true,
      'accepted_workers_count': 1,
    });

    final listModel = detail.toCleaningOrderModel();

    expect(listModel.canEdit, isTrue);
    expect(listModel.acceptedWorkersCount, 1);
  });
}
