import 'package:common_package/helpers/error_handler.dart';
import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/check_restaurant_coupon_use_case.dart';
import '../../domain/usecases/delete_cart_item_use_case.dart';
import '../../domain/usecases/fetch_order_details_use_case.dart';
import '../../domain/usecases/fetch_orders_use_case.dart';
import '../../domain/usecases/fetch_restaurant_order_tracking_use_case.dart';
import '../../domain/usecases/place_restaurant_order_use_case.dart';
import '../../domain/usecases/update_cart_item_quantity_use_case.dart';
import '../models/orders_api_models.dart';
import '../source/orders_remote_data_source.dart';
import '../../domain/repository/orders_repo.dart';

@LazySingleton(as: OrdersRepo)
class OrdersRepoImpl with HandlingException implements OrdersRepo {
  final OrdersRemoteDataSource ordersRemoteDataSource;

  OrdersRepoImpl({required this.ordersRemoteDataSource});

  @override
  DataResponse<FetchOrdersModel> fetchOrders(FetchOrdersParams params) {
    return wrapHandlingException(
      tryCall: () => ordersRemoteDataSource.fetchOrders(params),
    );
  }

  @override
  DataResponse<FetchOrderDetailsModel> fetchOrderDetails(
    FetchOrderDetailsParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => ordersRemoteDataSource.fetchOrderDetails(params),
    );
  }

  @override
  DataResponse<OrdersActionResultModel> updateCartItemQuantity(
    UpdateCartItemQuantityParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => ordersRemoteDataSource.updateCartItemQuantity(params),
    );
  }

  @override
  DataResponse<OrdersActionResultModel> deleteCartItem(DeleteCartItemParams params) {
    return wrapHandlingException(
      tryCall: () => ordersRemoteDataSource.deleteCartItem(params),
    );
  }

  @override
  DataResponse<CouponCheckModel> checkRestaurantCoupon(
    CheckRestaurantCouponParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => ordersRemoteDataSource.checkRestaurantCoupon(params),
    );
  }

  @override
  DataResponse<FetchRestaurantCartModel> fetchRestaurantCart() {
    return wrapHandlingException(
      tryCall: () => ordersRemoteDataSource.fetchRestaurantCart(),
    );
  }

  @override
  DataResponse<PlaceRestaurantOrderModel> placeRestaurantOrder(
    PlaceRestaurantOrderParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => ordersRemoteDataSource.placeRestaurantOrder(params),
    );
  }

  @override
  DataResponse<FetchRestaurantOrderTrackingModel> fetchRestaurantOrderTracking(
    FetchRestaurantOrderTrackingParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => ordersRemoteDataSource.fetchRestaurantOrderTracking(params),
    );
  }
}
