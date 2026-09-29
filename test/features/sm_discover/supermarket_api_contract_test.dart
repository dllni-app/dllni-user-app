import 'package:dllni_user_app/features/orders/data/models/merchant_cart_models.dart';
import 'package:dllni_user_app/features/orders/data/models/fetch_supermarket_cart_model.dart';
import 'package:dllni_user_app/features/sm_discover/domain/usecases/browse_products_use_case.dart';
import 'package:dllni_user_app/features/sm_discover/domain/usecases/browse_stores_use_case.dart';
import 'package:dllni_user_app/features/sm_stores/domain/usecases/add_supermarket_cart_item_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('supermarket request contracts', () {
    test('store discovery keeps coordinates sort and filters', () {
      final params = BrowseStoresParams(
        page: 3,
        sort: 'nearestBy',
        latitude: 36.2,
        longitude: 37.1,
        openNow: true,
        isFeatured: true,
        averageRatingMin: 4,
      );

      expect(params.getParams(), containsPair('page', 3));
      expect(params.getParams(), containsPair('sort', 'nearestBy'));
      expect(params.getParams(), containsPair('latitude', 36.2));
      expect(params.getParams(), containsPair('longitude', 37.1));
      expect(params.getParams(), containsPair('filter[openNow]', true));
      expect(params.getParams(), containsPair('filter[isFeatured]', true));
      expect(params.getParams(), containsPair('filter[averageRatingMin]', 4));
    });
    test('product discovery serializes supported filters', () {
      final params = BrowseProductsParams(
        search: 'حليب',
        storeId: 7,
        categoryId: 11,
        priceMin: 1000,
        priceMax: 5000,
        isAvailable: true,
        sort: 'price',
        page: 2,
      );

      expect(params.getParams(), containsPair('search', 'حليب'));
      expect(params.getParams(), containsPair('filter[storeId]', 7));
      expect(params.getParams(), containsPair('filter[categoryId]', 11));
      expect(params.getParams(), containsPair('price_min', 1000));
      expect(params.getParams(), containsPair('price_max', 5000));
      expect(params.getParams(), containsPair('filter[isAvailable]', true));
      expect(params.getParams(), containsPair('sort', 'price'));
    });

    test('cart item request preserves customizations', () {
      final params = AddSupermarketCartItemParams(
        productId: 9,
        quantity: 2,
        modifierIds: const [3, 4],
        substituteProductId: 12,
        note: 'عبوة حديثة',
      );
      expect(params.getBody(), <String, dynamic>{
        'productId': 9,
        'quantity': 2,
        'modifierIds': const [3, 4],
        'substituteProductId': 12,
        'note': 'عبوة حديثة',
      });
    });

    test('checkout preview parses delivery fee separately', () {
      final model = checkoutPreviewModelFromJson({
        'data': {
          'cartId': 1,
          'amounts': {
            'subtotal': 10000,
            'discount': 1000,
            'serviceFee': 0,
            'deliveryFee': 5000,
            'tax': 0,
            'total': 14000,
          },
        },
      });

      expect(model.data?.amounts?.subtotal, 10000);
      expect(model.data?.amounts?.deliveryFee, 5000);
      expect(model.data?.amounts?.serviceFee, 0);
      expect(model.data?.amounts?.total, 14000);
    });
    test('supermarket cart models preserve explicit product discount', () {
      final payload = {
        'data': [
          {
            'id': 1,
            'productsCount': 2,
            'items': <Map<String, dynamic>>[],
            'amounts': {
              'subtotal': 1600,
              'discount': 400,
              'total': 1600,
            },
          },
        ],
      };

      final supermarketCart = fetchSupermarketCartModelFromJson(payload);
      final merchantCarts = fetchMerchantCartsModelFromJson(payload);

      expect(supermarketCart.data?.first.amounts?.discount, 400);
      expect(merchantCarts.data.first.amounts?.discount, 400);
      expect(merchantCarts.data.first.amounts?.total, 1600);
    });

  });
}
