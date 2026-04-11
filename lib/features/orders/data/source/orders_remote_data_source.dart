import 'package:common_package/helpers/api_handler.dart';
import 'package:common_package/helpers/dio_network.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/check_restaurant_coupon_use_case.dart';
import '../../domain/usecases/delete_cart_item_use_case.dart';
import '../../domain/usecases/fetch_order_details_use_case.dart';
import '../../domain/usecases/fetch_orders_use_case.dart';
import '../../domain/usecases/fetch_restaurant_order_tracking_use_case.dart';
import '../../domain/usecases/place_restaurant_order_use_case.dart';
import '../../domain/usecases/update_cart_item_quantity_use_case.dart';
import '../models/orders_api_models.dart';

@lazySingleton
class OrdersRemoteDataSource with HandlingApiManager {
  final DioNetwork dioNetwork;

  OrdersRemoteDataSource({required this.dioNetwork});

  Future<FetchOrdersModel> fetchOrders(FetchOrdersParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/orders',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: fetchOrdersModelFromJson,
    );
  }

  Future<FetchOrderDetailsModel> fetchOrderDetails(FetchOrderDetailsParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/orders/${params.section}/${params.orderId}',
      ),
      jsonConvert: fetchOrderDetailsModelFromJson,
    );
  }

  Future<OrdersActionResultModel> updateCartItemQuantity(
    UpdateCartItemQuantityParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.patchData(
        endPoint: '/api/v1/user/restaurants/cart/items/${params.itemId}',
        data: params.getBody(),
      ),
      jsonConvert: ordersActionResultModelFromJson,
    );
  }

  Future<OrdersActionResultModel> deleteCartItem(DeleteCartItemParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.deleteData(
        endPoint: '/api/v1/user/restaurants/cart/items/${params.itemId}',
      ),
      jsonConvert: ordersActionResultModelFromJson,
    );
  }

  Future<CouponCheckModel> checkRestaurantCoupon(CheckRestaurantCouponParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/coupons/check',
        data: params.getBody(),
      ),
      jsonConvert: couponCheckModelFromJson,
    );
  }

  Future<FetchRestaurantCartModel> fetchRestaurantCart() {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/restaurants/cart',
      ),
      jsonConvert: fetchRestaurantCartModelFromJson,
    );
  }

  Future<PlaceRestaurantOrderModel> placeRestaurantOrder(
    PlaceRestaurantOrderParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/restaurants/orders',
        data: params.getBody(),
      ),
      jsonConvert: placeRestaurantOrderModelFromJson,
    );
  }

  Future<FetchRestaurantOrderTrackingModel> fetchRestaurantOrderTracking(
    FetchRestaurantOrderTrackingParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/orders/restaurant/${params.orderId}/tracking',
      ),
      jsonConvert: fetchRestaurantOrderTrackingModelFromJson,
    );
  }
}
