import 'package:dllni_user_app/features/cl_main/data/models/create_cleaning_order_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CreateCleaningOrderResponseModel', () {
    test('extracts order id from direct root keys', () {
      final model = createCleaningOrderResponseModelFromJson(<String, dynamic>{
        'success': true,
        'orderId': 77,
      });

      expect(model.success, isTrue);
      expect(model.orderId, 77);
    });

    test('extracts order id from nested data.order.id', () {
      final model = createCleaningOrderResponseModelFromJson(<String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'order': <String, dynamic>{'id': 125},
        },
      });

      expect(model.orderId, 125);
    });

    test('extracts order id from nested data.id string value', () {
      final model = createCleaningOrderResponseModelFromJson(<String, dynamic>{
        'data': <String, dynamic>{'id': '990'},
      });

      expect(model.orderId, 990);
    });

    test('keeps order id null when payload does not include id', () {
      final model = createCleaningOrderResponseModelFromJson(<String, dynamic>{
        'success': true,
        'message': 'ok',
      });

      expect(model.orderId, isNull);
    });
  });
}
