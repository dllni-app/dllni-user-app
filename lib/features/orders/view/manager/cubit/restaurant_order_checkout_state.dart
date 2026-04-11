part of 'restaurant_order_checkout_cubit.dart';

class RestaurantOrderCheckoutState {
  final BlocStatus? status;
  final OrderResourceModel? order;
  final bool isMutatingItem;
  final String? errorMessage;

  final BlocStatus? couponStatus;
  final CouponCheckDataModel? couponData;
  final String? couponErrorMessage;

  final String note;
  final String? selectedFulfillmentType;
  final AddressListItem? selectedAddress;

  RestaurantOrderCheckoutState({
    this.status,
    this.order,
    this.isMutatingItem = false,
    this.errorMessage,
    this.couponStatus,
    this.couponData,
    this.couponErrorMessage,
    this.note = '',
    this.selectedFulfillmentType,
    this.selectedAddress,
  });

  RestaurantOrderCheckoutState copyWith({
    BlocStatus? status,
    OrderResourceModel? order,
    bool? isMutatingItem,
    String? errorMessage,
    BlocStatus? couponStatus,
    CouponCheckDataModel? couponData,
    String? couponErrorMessage,
    String? note,
    String? selectedFulfillmentType,
    AddressListItem? selectedAddress,
    bool clearError = false,
    bool clearCouponError = false,
  }) {
    return RestaurantOrderCheckoutState(
      status: status ?? this.status,
      order: order ?? this.order,
      isMutatingItem: isMutatingItem ?? this.isMutatingItem,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      couponStatus: couponStatus ?? this.couponStatus,
      couponData: couponData ?? this.couponData,
      couponErrorMessage: clearCouponError
          ? null
          : (couponErrorMessage ?? this.couponErrorMessage),
      note: note ?? this.note,
      selectedFulfillmentType:
          selectedFulfillmentType ?? this.selectedFulfillmentType,
      selectedAddress: selectedAddress ?? this.selectedAddress,
    );
  }
}
