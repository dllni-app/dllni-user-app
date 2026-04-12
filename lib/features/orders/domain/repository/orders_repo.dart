import 'package:common_package/helpers/typedef.dart';

import '../../data/models/orders_api_models.dart';
import '../usecases/check_restaurant_coupon_use_case.dart';
import '../usecases/delete_cart_item_use_case.dart';
import '../usecases/fetch_order_details_use_case.dart';
import '../usecases/fetch_orders_use_case.dart';
import '../usecases/fetch_restaurant_order_tracking_use_case.dart';
import '../usecases/place_restaurant_order_use_case.dart';
import '../usecases/place_store_order_use_case.dart';
import '../usecases/update_cart_item_quantity_use_case.dart';

abstract class OrdersRepo {
  DataResponse<FetchOrdersModel> fetchOrders(FetchOrdersParams params);

  DataResponse<FetchOrderDetailsModel> fetchOrderDetails(
    FetchOrderDetailsParams params,
  );

  DataResponse<OrdersActionResultModel> updateCartItemQuantity(
    UpdateCartItemQuantityParams params,
  );

  DataResponse<OrdersActionResultModel> deleteCartItem(DeleteCartItemParams params);

  DataResponse<CouponCheckModel> checkRestaurantCoupon(
    CheckRestaurantCouponParams params,
  );

  DataResponse<FetchRestaurantCartModel> fetchRestaurantCart();
  DataResponse<FetchRestaurantCartModel> fetchStoreCart();

  DataResponse<PlaceRestaurantOrderModel> placeRestaurantOrder(
    PlaceRestaurantOrderParams params,
  );
  DataResponse<PlaceRestaurantOrderModel> placeStoreOrder(
    PlaceStoreOrderParams params,
  );

  DataResponse<OrdersActionResultModel> updateStoreCartItemQuantity(
    UpdateCartItemQuantityParams params,
  );
  DataResponse<OrdersActionResultModel> deleteStoreCartItem(DeleteCartItemParams params);

  DataResponse<FetchRestaurantOrderTrackingModel> fetchRestaurantOrderTracking(
    FetchRestaurantOrderTrackingParams params,
  );
  DataResponse<FetchRestaurantOrderTrackingModel> fetchStoreOrderTracking(
    FetchRestaurantOrderTrackingParams params,
  );
}
