import 'package:common_package/helpers/api_handler.dart';
import 'package:common_package/helpers/dio_network.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/cancel_cleaning_order_use_case.dart';
import '../../domain/usecases/check_restaurant_coupon_use_case.dart';
import '../../domain/usecases/confirm_cleaning_completion_use_case.dart';
import '../../domain/usecases/confirm_cleaning_start_verification_use_case.dart';
import '../../domain/usecases/extend_cleaning_completion_time_use_case.dart';
import '../../domain/usecases/fetch_cleaning_worker_profile_use_case.dart';
import '../../domain/usecases/delete_cart_item_use_case.dart';
import '../../domain/usecases/fetch_cleaning_order_details_use_case.dart';
import '../../domain/usecases/fetch_cleaning_orders_use_case.dart';
import '../../domain/usecases/fetch_order_details_use_case.dart';
import '../../domain/usecases/fetch_orders_use_case.dart';
import '../../domain/usecases/fetch_restaurant_order_tracking_use_case.dart';
import '../../domain/usecases/place_restaurant_order_use_case.dart';
import '../../domain/usecases/place_store_order_use_case.dart';
import '../../domain/usecases/patch_cleaning_order_use_case.dart';
import '../../domain/usecases/patch_cleaning_room_assignments_use_case.dart';
import '../../domain/usecases/reject_cleaning_completion_use_case.dart';
import '../../domain/usecases/submit_cleaning_review_use_case.dart';
import '../../domain/usecases/sos_use_cases.dart';
import '../../domain/usecases/update_cart_item_quantity_use_case.dart';
import '../models/cleaning_order_cancel_api_models.dart';
import '../models/cleaning_orders_api_models.dart';
import '../models/cleaning_worker_profile_model.dart';
import '../models/orders_api_models.dart';
import '../models/sos_api_models.dart';
import '../models/submit_cleaning_review_model.dart';

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

  Future<FetchCleaningOrdersModel> fetchCleaningOrders(
    FetchCleaningOrdersParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/cleaning/orders',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: fetchCleaningOrdersModelFromJson,
    );
  }

  Future<CleaningCancelResultModel> cancelCleaningOrder(
    CancelCleaningOrderParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint:
            '/api/v1/user/cleaning/orders/${params.cleaningOrderId}/cancel',
        data: params.getBody(),
      ),
      jsonConvert: cleaningCancelResultModelFromJson,
    );
  }

  Future<FetchCleaningOrderDetailsModel> fetchCleaningOrderDetails(
    FetchCleaningOrderDetailsParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/cleaning/orders/${params.orderId}',
      ),
      jsonConvert: fetchCleaningOrderDetailsModelFromJson,
    );
  }

  Future<FetchCleaningOrderDetailsModel> confirmCleaningStartVerification(
    ConfirmCleaningStartVerificationParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint:
            '/api/v1/user/cleaning/orders/${params.orderId}/start-verification/confirm',
        data: params.getBody(),
      ),
      jsonConvert: fetchCleaningOrderDetailsModelFromJson,
    );
  }

  Future<FetchCleaningOrderDetailsModel> confirmCleaningCompletion(
    ConfirmCleaningCompletionParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint:
            '/api/v1/user/cleaning/orders/${params.orderId}/completion/confirm',
        data: params.getBody(),
      ),
      jsonConvert: fetchCleaningOrderDetailsModelFromJson,
    );
  }

  Future<FetchCleaningOrderDetailsModel> rejectCleaningCompletion(
    RejectCleaningCompletionParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint:
            '/api/v1/user/cleaning/orders/${params.orderId}/completion/reject',
        data: params.getBody(),
      ),
      jsonConvert: fetchCleaningOrderDetailsModelFromJson,
    );
  }

  Future<FetchCleaningOrderDetailsModel> extendCleaningCompletionTime(
    ExtendCleaningCompletionTimeParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint:
            '/api/v1/user/cleaning/orders/${params.orderId}/completion/extend-time',
        data: params.getBody(),
      ),
      jsonConvert: fetchCleaningOrderDetailsModelFromJson,
    );
  }

  Future<SubmitCleaningReviewModel> submitCleaningReview(
    SubmitCleaningReviewParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        // TODO(backend): confirm /review contract once endpoint is shipped.
        endPoint: '/api/v1/user/cleaning/orders/${params.orderId}/review',
        data: params.getBody(),
      ),
      jsonConvert: submitCleaningReviewModelFromJson,
    );
  }

  Future<FetchCleaningWorkerProfileModel> fetchCleaningWorkerProfile(
    FetchCleaningWorkerProfileParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () =>
          dioNetwork.getData(endPoint: '/api/v1/worker/${params.workerId}'),
      jsonConvert: fetchCleaningWorkerProfileModelFromJson,
    );
  }

  Future<OrdersActionResultModel> patchCleaningOrder(
    PatchCleaningOrderParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.patchData(
        endPoint: '/api/v1/user/cleaning/orders/${params.cleaningOrderId}',
        data: params.getBody(),
      ),
      jsonConvert: ordersActionResultModelFromJson,
    );
  }

  Future<FetchCleaningOrderDetailsModel> patchCleaningRoomAssignments(
    PatchCleaningRoomAssignmentsParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.patchData(
        endPoint:
            '/api/v1/user/cleaning/orders/${params.orderId}/room-assignments',
        data: params.getBody(),
      ),
      jsonConvert: fetchCleaningOrderDetailsModelFromJson,
    );
  }

  Future<FetchOrderDetailsModel> fetchOrderDetails(
    FetchOrderDetailsParams params,
  ) {
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

  Future<CouponCheckModel> checkRestaurantCoupon(
    CheckRestaurantCouponParams params,
  ) {
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
      tryCall: () =>
          dioNetwork.getData(endPoint: '/api/v1/user/restaurants/cart'),
      jsonConvert: fetchRestaurantCartModelFromJson,
    );
  }

  Future<FetchRestaurantCartModel> fetchStoreCart() {
    return wrapHandlingApi(
      tryCall: () =>
          dioNetwork.getData(endPoint: '/api/v1/user/supermarket/cart'),
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

  Future<PlaceRestaurantOrderModel> placeStoreOrder(
    PlaceStoreOrderParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/supermarket/orders',
        data: params.getBody(),
      ),
      jsonConvert: placeRestaurantOrderModelFromJson,
    );
  }

  Future<OrdersActionResultModel> updateStoreCartItemQuantity(
    UpdateCartItemQuantityParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.patchData(
        endPoint: '/api/v1/user/supermarket/cart/items/${params.itemId}',
        data: params.getBody(),
      ),
      jsonConvert: ordersActionResultModelFromJson,
    );
  }

  Future<OrdersActionResultModel> deleteStoreCartItem(
    DeleteCartItemParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.deleteData(
        endPoint: '/api/v1/user/supermarket/cart/items/${params.itemId}',
      ),
      jsonConvert: ordersActionResultModelFromJson,
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

  Future<FetchRestaurantOrderTrackingModel> fetchStoreOrderTracking(
    FetchRestaurantOrderTrackingParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/orders/supermarket/${params.orderId}/tracking',
      ),
      jsonConvert: fetchRestaurantOrderTrackingModelFromJson,
    );
  }

  Future<UserSosResponseModel> createUserSos(CreateUserSosParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/sos',
        data: params.getBody(),
      ),
      jsonConvert: userSosResponseModelFromJson,
    );
  }

  Future<FetchSosAlertsModel> fetchSosAlerts(FetchSosAlertsParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/sos-alerts',
        params: params.getParams(),
      ),
      jsonConvert: fetchSosAlertsModelFromJson,
    );
  }

  Future<SosAlertModel> fetchSosAlertDetails(
    FetchSosAlertDetailsParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () =>
          dioNetwork.getData(endPoint: '/api/v1/sos-alerts/${params.alertId}'),
      jsonConvert: sosAlertModelFromJson,
    );
  }

  Future<CleaningSosAlertModel> createCleaningUserSos(
    CreateCleaningUserSosParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/cleaning/orders/${params.orderId}/sos',
        data: params.getBody(),
      ),
      jsonConvert: cleaningSosAlertModelFromJson,
    );
  }
}
