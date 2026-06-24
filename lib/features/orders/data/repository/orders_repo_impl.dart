import 'package:common_package/helpers/error_handler.dart';
import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repository/orders_repo.dart';
import '../../domain/usecases/cancel_cleaning_order_use_case.dart';
import '../../domain/usecases/check_restaurant_coupon_use_case.dart';
import '../../domain/usecases/confirm_cleaning_completion_use_case.dart';
import '../../domain/usecases/confirm_cleaning_start_verification_use_case.dart';
import '../../domain/usecases/extend_cleaning_completion_time_use_case.dart';
import '../../domain/usecases/fetch_cleaning_worker_profile_use_case.dart';
import '../../domain/usecases/delete_cart_item_use_case.dart';
import '../../domain/usecases/fetch_cleaning_order_details_use_case.dart';
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
import '../models/merchant_cart_models.dart';
import '../models/orders_api_models.dart';
import '../models/sos_api_models.dart';
import '../models/submit_cleaning_review_model.dart';
import '../source/orders_remote_data_source.dart';

@LazySingleton(as: OrdersRepo)
class OrdersRepoImpl with HandlingException implements OrdersRepo {
  final OrdersRemoteDataSource ordersRemoteDataSource;

  OrdersRepoImpl({required this.ordersRemoteDataSource});

  @override
  DataResponse<FetchOrdersModel> fetchOrders(FetchOrdersParams params) =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.fetchOrders(params));

  @override
  DataResponse<FetchCleaningOrdersModel> fetchCleaningOrders(
    FetchCleaningOrdersParams params,
  ) =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.fetchCleaningOrders(params));

  @override
  DataResponse<CleaningCancelResultModel> cancelCleaningOrder(
    CancelCleaningOrderParams params,
  ) =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.cancelCleaningOrder(params));

  @override
  DataResponse<FetchCleaningOrderDetailsModel> fetchCleaningOrderDetails(
    FetchCleaningOrderDetailsParams params,
  ) =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.fetchCleaningOrderDetails(params));

  @override
  DataResponse<FetchCleaningOrderDetailsModel> confirmCleaningStartVerification(
    ConfirmCleaningStartVerificationParams params,
  ) =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.confirmCleaningStartVerification(params));

  @override
  DataResponse<FetchCleaningOrderDetailsModel> confirmCleaningCompletion(
    ConfirmCleaningCompletionParams params,
  ) =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.confirmCleaningCompletion(params));

  @override
  DataResponse<FetchCleaningOrderDetailsModel> rejectCleaningCompletion(
    RejectCleaningCompletionParams params,
  ) =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.rejectCleaningCompletion(params));

  @override
  DataResponse<FetchCleaningOrderDetailsModel> extendCleaningCompletionTime(
    ExtendCleaningCompletionTimeParams params,
  ) =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.extendCleaningCompletionTime(params));

  @override
  DataResponse<SubmitCleaningReviewModel> submitCleaningReview(
    SubmitCleaningReviewParams params,
  ) =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.submitCleaningReview(params));

  @override
  DataResponse<FetchCleaningWorkerProfileModel> fetchCleaningWorkerProfile(
    FetchCleaningWorkerProfileParams params,
  ) =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.fetchCleaningWorkerProfile(params));

  @override
  DataResponse<OrdersActionResultModel> patchCleaningOrder(
    PatchCleaningOrderParams params,
  ) =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.patchCleaningOrder(params));

  @override
  DataResponse<FetchCleaningOrderDetailsModel> patchCleaningRoomAssignments(
    PatchCleaningRoomAssignmentsParams params,
  ) =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.patchCleaningRoomAssignments(params));

  @override
  DataResponse<FetchOrderDetailsModel> fetchOrderDetails(
    FetchOrderDetailsParams params,
  ) =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.fetchOrderDetails(params));

  @override
  DataResponse<FetchRestaurantCartModel> updateCartItemQuantity(
    UpdateCartItemQuantityParams params,
  ) =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.updateCartItemQuantity(params));

  @override
  DataResponse<FetchRestaurantCartModel> deleteCartItem(
    DeleteCartItemParams params,
  ) =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.deleteCartItem(params));

  @override
  DataResponse<CouponCheckModel> checkRestaurantCoupon(
    CheckRestaurantCouponParams params,
  ) =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.checkRestaurantCoupon(params));

  @override
  DataResponse<FetchMerchantCartsModel> fetchRestaurantCarts() =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.fetchRestaurantCarts());

  @override
  DataResponse<FetchRestaurantCartModel> fetchRestaurantCartById(
    FetchMerchantCartByIdParams params,
  ) =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.fetchRestaurantCartById(params));

  @override
  DataResponse<FetchMerchantCartsModel> fetchStoreCarts() =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.fetchStoreCarts());

  @override
  DataResponse<FetchRestaurantCartModel> fetchStoreCartById(
    FetchMerchantCartByIdParams params,
  ) =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.fetchStoreCartById(params));

  @override
  DataResponse<CheckoutPreviewModel> previewRestaurantCheckout(
    CheckoutPreviewParams params,
  ) =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.previewRestaurantCheckout(params));

  @override
  DataResponse<CheckoutPreviewModel> previewStoreCheckout(
    CheckoutPreviewParams params,
  ) =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.previewStoreCheckout(params));

  @override
  DataResponse<PlaceRestaurantOrderModel> placeRestaurantOrder(
    PlaceRestaurantOrderParams params,
  ) =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.placeRestaurantOrder(params));

  @override
  DataResponse<PlaceRestaurantOrderModel> placeStoreOrder(
    PlaceStoreOrderParams params,
  ) =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.placeStoreOrder(params));

  @override
  DataResponse<FetchRestaurantCartModel> updateStoreCartItemQuantity(
    UpdateCartItemQuantityParams params,
  ) =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.updateStoreCartItemQuantity(params));

  @override
  DataResponse<FetchRestaurantCartModel> deleteStoreCartItem(
    DeleteCartItemParams params,
  ) =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.deleteStoreCartItem(params));

  @override
  DataResponse<FetchRestaurantOrderTrackingModel> fetchRestaurantOrderTracking(
    FetchRestaurantOrderTrackingParams params,
  ) =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.fetchRestaurantOrderTracking(params));

  @override
  DataResponse<FetchRestaurantOrderTrackingModel> fetchStoreOrderTracking(
    FetchRestaurantOrderTrackingParams params,
  ) =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.fetchStoreOrderTracking(params));

  @override
  DataResponse<UserSosResponseModel> createUserSos(CreateUserSosParams params) =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.createUserSos(params));

  @override
  DataResponse<FetchSosAlertsModel> fetchSosAlerts(
    FetchSosAlertsParams params,
  ) =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.fetchSosAlerts(params));

  @override
  DataResponse<SosAlertModel> fetchSosAlertDetails(
    FetchSosAlertDetailsParams params,
  ) =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.fetchSosAlertDetails(params));

  @override
  DataResponse<CleaningSosAlertModel> createCleaningUserSos(
    CreateCleaningUserSosParams params,
  ) =>
      wrapHandlingException(tryCall: () => ordersRemoteDataSource.createCleaningUserSos(params));
}
