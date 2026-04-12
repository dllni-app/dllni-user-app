import 'package:common_package/helpers/error_handler.dart';
import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repository/orders_repo.dart';
import '../../domain/usecases/cancel_cleaning_order_use_case.dart';
import '../../domain/usecases/check_restaurant_coupon_use_case.dart';
import '../../domain/usecases/delete_cart_item_use_case.dart';
import '../../domain/usecases/fetch_cleaning_order_details_use_case.dart';
import '../../domain/usecases/fetch_cleaning_orders_use_case.dart';
import '../../domain/usecases/fetch_order_details_use_case.dart';
import '../../domain/usecases/fetch_orders_use_case.dart';
import '../../domain/usecases/fetch_restaurant_order_tracking_use_case.dart';
import '../../domain/usecases/place_restaurant_order_use_case.dart';
import '../../domain/usecases/place_store_order_use_case.dart';
import '../../domain/usecases/patch_cleaning_order_use_case.dart';
import '../../domain/usecases/update_cart_item_quantity_use_case.dart';
import '../models/cleaning_order_cancel_api_models.dart';
import '../models/cleaning_orders_api_models.dart';
import '../models/orders_api_models.dart';
import '../source/orders_remote_data_source.dart';

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
  DataResponse<FetchCleaningOrdersModel> fetchCleaningOrders(
    FetchCleaningOrdersParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => ordersRemoteDataSource.fetchCleaningOrders(params),
    );
  }

  @override
  DataResponse<CleaningCancelResultModel> cancelCleaningOrder(
    CancelCleaningOrderParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => ordersRemoteDataSource.cancelCleaningOrder(params),
    );
  }

  @override
  DataResponse<FetchCleaningOrderDetailsModel> fetchCleaningOrderDetails(
    FetchCleaningOrderDetailsParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => ordersRemoteDataSource.fetchCleaningOrderDetails(params),
    );
  }

  @override
  DataResponse<OrdersActionResultModel> patchCleaningOrder(
    PatchCleaningOrderParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => ordersRemoteDataSource.patchCleaningOrder(params),
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
  DataResponse<OrdersActionResultModel> deleteCartItem(
    DeleteCartItemParams params,
  ) {
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
  DataResponse<FetchRestaurantCartModel> fetchStoreCart() {
    return wrapHandlingException(
      tryCall: () => ordersRemoteDataSource.fetchStoreCart(),
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
  DataResponse<PlaceRestaurantOrderModel> placeStoreOrder(
    PlaceStoreOrderParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => ordersRemoteDataSource.placeStoreOrder(params),
    );
  }

  @override
  DataResponse<OrdersActionResultModel> updateStoreCartItemQuantity(
    UpdateCartItemQuantityParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => ordersRemoteDataSource.updateStoreCartItemQuantity(params),
    );
  }

  @override
  DataResponse<OrdersActionResultModel> deleteStoreCartItem(
    DeleteCartItemParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => ordersRemoteDataSource.deleteStoreCartItem(params),
    );
  }

  @override
  DataResponse<FetchRestaurantOrderTrackingModel> fetchRestaurantOrderTracking(
    FetchRestaurantOrderTrackingParams params,
  ) {
    return wrapHandlingException(
      tryCall: () =>
          ordersRemoteDataSource.fetchRestaurantOrderTracking(params),
    );
  }

  @override
  DataResponse<FetchRestaurantOrderTrackingModel> fetchStoreOrderTracking(
    FetchRestaurantOrderTrackingParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => ordersRemoteDataSource.fetchStoreOrderTracking(params),
    );
  }
}
