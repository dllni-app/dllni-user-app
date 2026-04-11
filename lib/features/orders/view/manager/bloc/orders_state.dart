part of 'orders_bloc.dart';

class OrdersState {
  final BlocStatus? status;
  final List<OrderResourceModel> orders;
  final int selectedTabIndex;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final bool isLoadingMore;
  final String? errorMessage;
  final BlocStatus? restaurantCartStatus;
  final RestaurantCartDataModel? restaurantCart;
  final String? restaurantCartErrorMessage;
  final bool isMutatingCartItem;
  final BlocStatus? couponStatus;
  final CouponCheckDataModel? couponData;
  final String? couponErrorMessage;
  final BlocStatus? placeOrderStatus;
  final String? placeOrderErrorMessage;
  final String cartNote;
  final String? selectedFulfillmentType;
  final AddressListItem? selectedAddress;

  OrdersState({
    this.status,
    this.orders = const <OrderResourceModel>[],
    this.selectedTabIndex = 1,
    this.perPage = 10,
    this.currentPage = 1,
    this.lastPage = 1,
    this.isLoadingMore = false,
    this.errorMessage,
    this.restaurantCartStatus,
    this.restaurantCart,
    this.restaurantCartErrorMessage,
    this.isMutatingCartItem = false,
    this.couponStatus,
    this.couponData,
    this.couponErrorMessage,
    this.placeOrderStatus,
    this.placeOrderErrorMessage,
    this.cartNote = '',
    this.selectedFulfillmentType = 'delivery',
    this.selectedAddress,
  });

  OrdersState copyWith({
    BlocStatus? status,
    List<OrderResourceModel>? orders,
    int? selectedTabIndex,
    int? perPage,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
    BlocStatus? restaurantCartStatus,
    RestaurantCartDataModel? restaurantCart,
    bool replaceRestaurantCart = false,
    String? restaurantCartErrorMessage,
    bool clearRestaurantCartError = false,
    bool clearRestaurantCart = false,
    bool? isMutatingCartItem,
    BlocStatus? couponStatus,
    CouponCheckDataModel? couponData,
    String? couponErrorMessage,
    bool clearCouponError = false,
    BlocStatus? placeOrderStatus,
    String? placeOrderErrorMessage,
    bool clearPlaceOrderError = false,
    String? cartNote,
    String? selectedFulfillmentType,
    AddressListItem? selectedAddress,
    bool replaceSelectedAddress = false,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      perPage: perPage ?? this.perPage,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      restaurantCartStatus: restaurantCartStatus ?? this.restaurantCartStatus,
      restaurantCart: clearRestaurantCart
          ? null
          : (replaceRestaurantCart
              ? restaurantCart
              : (restaurantCart ?? this.restaurantCart)),
      restaurantCartErrorMessage: clearRestaurantCartError
          ? null
          : (restaurantCartErrorMessage ?? this.restaurantCartErrorMessage),
      isMutatingCartItem: isMutatingCartItem ?? this.isMutatingCartItem,
      couponStatus: couponStatus ?? this.couponStatus,
      couponData: couponData ?? this.couponData,
      couponErrorMessage:
          clearCouponError ? null : (couponErrorMessage ?? this.couponErrorMessage),
      placeOrderStatus: placeOrderStatus ?? this.placeOrderStatus,
      placeOrderErrorMessage: clearPlaceOrderError
          ? null
          : (placeOrderErrorMessage ?? this.placeOrderErrorMessage),
      cartNote: cartNote ?? this.cartNote,
      selectedFulfillmentType:
          selectedFulfillmentType ?? this.selectedFulfillmentType,
      selectedAddress: replaceSelectedAddress
          ? selectedAddress
          : (selectedAddress ?? this.selectedAddress),
    );
  }
}
