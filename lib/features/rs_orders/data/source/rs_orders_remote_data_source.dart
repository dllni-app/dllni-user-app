import 'package:injectable/injectable.dart';
import 'package:common_package/common_package.dart';

import '../models/rs_orders_api_models.dart';

@lazySingleton
class RsOrdersRemoteDataSource with HandlingApiManager {
  final DioNetwork dioNetwork;

  RsOrdersRemoteDataSource({required this.dioNetwork});

  Future<FetchOrdersListModel> listOrders({int page = 1, int perPage = 20}) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/restaurants/orders',
        params: {'page': page, 'perPage': perPage},
      ),
      jsonConvert: fetchOrdersListModelFromJson,
    );
  }

  Future<FetchOrderDetailsModel> showOrder({required int orderId}) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/restaurants/orders/$orderId',
      ),
      jsonConvert: fetchOrderDetailsModelFromJson,
    );
  }

  Future<CheckoutOrderModel> checkout({
    required int restaurantId,
    required String orderType,
    String pickupMode = 'immediate_pickup',
    String? pickupScheduledFor,
    String? promoCode,
    String specialInstructions = '',
  }) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/restaurants/checkout',
        data: {
          'restaurantId': restaurantId,
          'orderType': orderType,
          'pickupMode': pickupMode,
          if (pickupScheduledFor != null)
            'pickupScheduledFor': pickupScheduledFor,
          if (promoCode != null) 'promoCode': promoCode,
          'specialInstructions': specialInstructions,
        },
      ),
      jsonConvert: checkoutOrderModelFromJson,
    );
  }

  Future<AddCartItemModel> addCartItem({
    required int productId,
    int quantity = 1,
    List<int> modifierIds = const [],
    int? substituteProductId,
    String specialInstructions = '',
  }) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/restaurants/cart/items',
        data: {
          'productId': productId,
          'quantity': quantity,
          'modifierIds': modifierIds,
          if (substituteProductId != null)
            'substituteProductId': substituteProductId,
          'specialInstructions': specialInstructions,
        },
      ),
      jsonConvert: addCartItemModelFromJson,
    );
  }
}
