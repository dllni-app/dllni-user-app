import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/profile/domain/models/address_list_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/models/orders_api_models.dart';
import '../../../domain/usecases/check_restaurant_coupon_use_case.dart';
import '../../../domain/usecases/delete_cart_item_use_case.dart';
import '../../../domain/usecases/fetch_order_details_use_case.dart';
import '../../../domain/usecases/update_cart_item_quantity_use_case.dart';

part 'restaurant_order_checkout_state.dart';

@injectable
class RestaurantOrderCheckoutCubit extends Cubit<RestaurantOrderCheckoutState> {
  final FetchOrderDetailsUseCase fetchOrderDetailsUseCase;
  final UpdateCartItemQuantityUseCase updateCartItemQuantityUseCase;
  final DeleteCartItemUseCase deleteCartItemUseCase;
  final CheckRestaurantCouponUseCase checkRestaurantCouponUseCase;

  RestaurantOrderCheckoutCubit(
    this.fetchOrderDetailsUseCase,
    this.updateCartItemQuantityUseCase,
    this.deleteCartItemUseCase,
    this.checkRestaurantCouponUseCase,
  ) : super(RestaurantOrderCheckoutState());

  Future<void> loadOrder({
    required String section,
    required int orderId,
    bool showLoading = true,
  }) async {
    if (showLoading) {
      emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    }
    final response = await fetchOrderDetailsUseCase(
      FetchOrderDetailsParams(section: section, orderId: orderId),
    );
    response.fold(
      (failure) => emit(
        state.copyWith(
          status: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (result) {
        final order = result.data;
        emit(
          state.copyWith(
            status: BlocStatus.success,
            order: order,
            selectedFulfillmentType:
                state.selectedFulfillmentType ?? order?.fulfillment?.type ?? 'delivery',
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> updateQuantity({
    required String section,
    required int orderId,
    required int cartId,
    required int itemId,
    required int quantity,
  }) async {
    emit(state.copyWith(isMutatingItem: true));
    final response = await updateCartItemQuantityUseCase(
      UpdateCartItemQuantityParams(
        cartId: cartId,
        itemId: itemId,
        quantity: quantity,
      ),
    );
    await response.fold(
      (failure) async => emit(
        state.copyWith(
          isMutatingItem: false,
          errorMessage: failure.message,
        ),
      ),
      (_) async {
        emit(state.copyWith(isMutatingItem: false));
        await loadOrder(section: section, orderId: orderId, showLoading: false);
      },
    );
  }

  Future<void> deleteItem({
    required String section,
    required int orderId,
    required int cartId,
    required int itemId,
  }) async {
    emit(state.copyWith(isMutatingItem: true));
    final response = await deleteCartItemUseCase(
      DeleteCartItemParams(cartId: cartId, itemId: itemId),
    );
    await response.fold(
      (failure) async => emit(
        state.copyWith(
          isMutatingItem: false,
          errorMessage: failure.message,
        ),
      ),
      (_) async {
        emit(state.copyWith(isMutatingItem: false));
        await loadOrder(section: section, orderId: orderId, showLoading: false);
      },
    );
  }

  Future<void> applyCoupon(String code) async {
    emit(
      state.copyWith(
        couponStatus: BlocStatus.loading,
        clearCouponError: true,
      ),
    );
    final response = await checkRestaurantCouponUseCase(
      CheckRestaurantCouponParams(couponCode: code),
    );
    response.fold(
      (failure) => emit(
        state.copyWith(
          couponStatus: BlocStatus.failed,
          couponErrorMessage: failure.message,
        ),
      ),
      (result) => emit(
        state.copyWith(
          couponStatus: BlocStatus.success,
          couponData: result.data,
          clearCouponError: true,
        ),
      ),
    );
  }

  void setNote(String note) {
    emit(state.copyWith(note: note));
  }

  void setFulfillmentType(String type) {
    emit(state.copyWith(selectedFulfillmentType: type));
  }

  void setSelectedAddress(AddressListItem? address) {
    emit(state.copyWith(selectedAddress: address));
  }
}
