import 'package:dllni_user_app/features/orders/data/models/merchant_cart_models.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/place_restaurant_order_use_case.dart';
import 'package:dllni_user_app/features/rs_home/data/models/fetch_restaurant_home_category_products_model.dart';
import 'package:dllni_user_app/features/rs_home/domain/usecases/fetch_restaurant_home_category_products_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('restaurant user flow contracts', () {
    test('category products use the backend pagination query contract', () {
      final params = FetchRestaurantHomeCategoryProductsParams(
        categoryId: 44,
        page: 3,
        perPage: 30,
      );

      expect(params.getParams(), <String, dynamic>{
        'page': 3,
        'per_page': 30,
      });
    });

    test('category products retain pagination metadata', () {
      final model = fetchRestaurantHomeCategoryProductsModelFromJson(
        <String, dynamic>{
          'data': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 9,
              'name': 'Meal',
              'displayPrice': 120,
            },
          ],
          'meta': <String, dynamic>{
            'current_page': 2,
            'last_page': 4,
            'total': 91,
          },
        },
      );

      expect(model.products.single.productId, 9);
      expect(model.currentPage, 2);
      expect(model.lastPage, 4);
      expect(model.total, 91);
    });

    test('restaurant checkout preview sends schedule, address and coupon', () {
      final params = CheckoutPreviewParams(
        cartId: 7,
        fulfillmentType: 'delivery',
        receiveMode: 'scheduled',
        scheduledAt: '2026-10-02T18:30:00.000',
        addressId: 12,
        couponCode: 'REST20',
        note: 'Call on arrival',
      );

      expect(params.getBody(), <String, dynamic>{
        'fulfillmentType': 'delivery',
        'receiveMode': 'scheduled',
        'addressId': 12,
        'scheduledAt': '2026-10-02T18:30:00.000',
        'couponCode': 'REST20',
        'note': 'Call on arrival',
      });
    });

    test('restaurant order placement preserves scheduled checkout contract', () {
      final params = PlaceRestaurantOrderParams(
        cartId: 7,
        fulfillmentType: 'pickup',
        receiveMode: 'scheduled',
        scheduledAt: '2026-10-03T12:00:00.000',
        couponCode: 'REST20',
      );

      expect(params.getBody(), <String, dynamic>{
        'fulfillmentType': 'pickup',
        'receiveMode': 'scheduled',
        'addressId': null,
        'scheduledAt': '2026-10-03T12:00:00.000',
        'couponCode': 'REST20',
      });
    });
  });
}
