import 'package:common_package/common_package.dart';

import '../../../data/models/orders_api_models.dart';
import '../../../domain/usecases/check_restaurant_coupon_use_case.dart';
import 'orders_bloc.dart';

final Expando<bool> _registeredMerchantCouponHandlers = Expando<bool>();

class ApplyMerchantCartCouponEvent extends OrdersEvent {
  final int cartId;
  final String section;
  final String couponCode;

  ApplyMerchantCartCouponEvent({
    required this.cartId,
    required this.section,
    required this.couponCode,
  });
}

class ClearMerchantCartCouponEvent extends OrdersEvent {
  final String section;

  ClearMerchantCartCouponEvent({required this.section});
}

extension MerchantCheckoutCouponBlocExtension on OrdersBloc {
  void ensureMerchantCouponHandlers() {
    if (_registeredMerchantCouponHandlers[this] == true) return;
    _registeredMerchantCouponHandlers[this] = true;

    on<ClearMerchantCartCouponEvent>((event, emit) {
      final isStore = event.section == 'supermarket';
      if (isStore) {
        emit(
          state.copyWith(
            storeCouponStatus: BlocStatus.init,
            storeCouponData: CouponCheckDataModel(),
            clearStoreCouponError: true,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          couponStatus: BlocStatus.init,
          couponData: CouponCheckDataModel(),
          clearCouponError: true,
        ),
      );
    });

    on<ApplyMerchantCartCouponEvent>((event, emit) async {
      final isStore = event.section == 'supermarket';
      final code = event.couponCode.trim();

      if (isStore) {
        emit(
          state.copyWith(
            storeCouponStatus: BlocStatus.loading,
            storeCouponData: CouponCheckDataModel(),
            clearStoreCouponError: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            couponStatus: BlocStatus.loading,
            couponData: CouponCheckDataModel(),
            clearCouponError: true,
          ),
        );
      }

      final response = await checkRestaurantCouponUseCase(
        CheckRestaurantCouponParams(
          couponCode: code,
          section: isStore ? 'supermarket' : 'restaurant',
          cartId: event.cartId,
        ),
      );

      response.fold(
        (failure) {
          if (isStore) {
            emit(
              state.copyWith(
                storeCouponStatus: BlocStatus.failed,
                storeCouponData: CouponCheckDataModel(),
                storeCouponErrorMessage: failure.message,
              ),
            );
            return;
          }

          emit(
            state.copyWith(
              couponStatus: BlocStatus.failed,
              couponData: CouponCheckDataModel(),
              couponErrorMessage: failure.message,
            ),
          );
        },
        (result) {
          if (isStore) {
            emit(
              state.copyWith(
                storeCouponStatus: BlocStatus.success,
                storeCouponData: result.data ?? CouponCheckDataModel(),
                clearStoreCouponError: true,
              ),
            );
            return;
          }

          emit(
            state.copyWith(
              couponStatus: BlocStatus.success,
              couponData: result.data ?? CouponCheckDataModel(),
              clearCouponError: true,
            ),
          );
        },
      );
    });
  }
}
