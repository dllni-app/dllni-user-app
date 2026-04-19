part of 'orders_bloc.dart';

class OrdersState {
  final PaginationStateModel<OrderResourceModel> orders;
  final PaginationStateModel<CleaningOrderModel> cleaningOrders;
  final int selectedTabIndex;
  final String? errorMessage;
  final BlocStatus? restaurantCartStatus;
  final RestaurantCartDataModel? restaurantCart;
  final String? restaurantCartErrorMessage;
  final BlocStatus? storeCartStatus;
  final RestaurantCartDataModel? storeCart;
  final String? storeCartErrorMessage;
  final bool isMutatingCartItem;
  final bool isMutatingStoreCartItem;
  final BlocStatus? couponStatus;
  final CouponCheckDataModel? couponData;
  final String? couponErrorMessage;
  final BlocStatus? storeCouponStatus;
  final CouponCheckDataModel? storeCouponData;
  final String? storeCouponErrorMessage;
  final BlocStatus? placeOrderStatus;
  final String? placeOrderErrorMessage;
  final BlocStatus? placeStoreOrderStatus;
  final String? placeStoreOrderErrorMessage;
  final BlocStatus? cancelCleaningStatus;
  final String? cancelCleaningErrorMessage;
  final String cartNote;
  final String? selectedFulfillmentType;
  final String storeReceiveMode;
  final String? storeScheduledAt;
  final AddressListItem? selectedAddress;

  OrdersState({
    this.orders = const PaginationStateModel<OrderResourceModel>(perPage: 10),
    this.cleaningOrders = const PaginationStateModel<CleaningOrderModel>(perPage: 10),
    this.selectedTabIndex = 0,
    this.errorMessage,
    this.restaurantCartStatus,
    this.restaurantCart,
    this.restaurantCartErrorMessage,
    this.storeCartStatus,
    this.storeCart,
    this.storeCartErrorMessage,
    this.isMutatingCartItem = false,
    this.isMutatingStoreCartItem = false,
    this.couponStatus,
    this.couponData,
    this.couponErrorMessage,
    this.storeCouponStatus,
    this.storeCouponData,
    this.storeCouponErrorMessage,
    this.placeOrderStatus,
    this.placeOrderErrorMessage,
    this.placeStoreOrderStatus,
    this.placeStoreOrderErrorMessage,
    this.cancelCleaningStatus,
    this.cancelCleaningErrorMessage,
    this.cartNote = '',
    this.selectedFulfillmentType = 'delivery',
    this.storeReceiveMode = 'immediate',
    this.storeScheduledAt,
    this.selectedAddress,
  });

  OrdersState copyWith({
    PaginationStateModel<OrderResourceModel>? orders,
    PaginationStateModel<CleaningOrderModel>? cleaningOrders,
    int? selectedTabIndex,
    String? errorMessage,
    bool clearError = false,
    BlocStatus? restaurantCartStatus,
    RestaurantCartDataModel? restaurantCart,
    bool replaceRestaurantCart = false,
    String? restaurantCartErrorMessage,
    bool clearRestaurantCartError = false,
    bool clearRestaurantCart = false,
    BlocStatus? storeCartStatus,
    RestaurantCartDataModel? storeCart,
    bool replaceStoreCart = false,
    String? storeCartErrorMessage,
    bool clearStoreCartError = false,
    bool clearStoreCart = false,
    bool? isMutatingCartItem,
    bool? isMutatingStoreCartItem,
    BlocStatus? couponStatus,
    CouponCheckDataModel? couponData,
    String? couponErrorMessage,
    bool clearCouponError = false,
    BlocStatus? storeCouponStatus,
    CouponCheckDataModel? storeCouponData,
    String? storeCouponErrorMessage,
    bool clearStoreCouponError = false,
    BlocStatus? placeOrderStatus,
    String? placeOrderErrorMessage,
    bool clearPlaceOrderError = false,
    BlocStatus? placeStoreOrderStatus,
    String? placeStoreOrderErrorMessage,
    bool clearPlaceStoreOrderError = false,
    BlocStatus? cancelCleaningStatus,
    String? cancelCleaningErrorMessage,
    bool clearCancelCleaningError = false,
    String? cartNote,
    String? selectedFulfillmentType,
    String? storeReceiveMode,
    String? storeScheduledAt,
    bool replaceStoreScheduledAt = false,
    AddressListItem? selectedAddress,
    bool replaceSelectedAddress = false,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      cleaningOrders: cleaningOrders ?? this.cleaningOrders,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      restaurantCartStatus: restaurantCartStatus ?? this.restaurantCartStatus,
      restaurantCart: clearRestaurantCart ? null : (replaceRestaurantCart ? restaurantCart : (restaurantCart ?? this.restaurantCart)),
      restaurantCartErrorMessage: clearRestaurantCartError ? null : (restaurantCartErrorMessage ?? this.restaurantCartErrorMessage),
      storeCartStatus: storeCartStatus ?? this.storeCartStatus,
      storeCart: clearStoreCart ? null : (replaceStoreCart ? storeCart : (storeCart ?? this.storeCart)),
      storeCartErrorMessage: clearStoreCartError ? null : (storeCartErrorMessage ?? this.storeCartErrorMessage),
      isMutatingCartItem: isMutatingCartItem ?? this.isMutatingCartItem,
      isMutatingStoreCartItem: isMutatingStoreCartItem ?? this.isMutatingStoreCartItem,
      couponStatus: couponStatus ?? this.couponStatus,
      couponData: couponData ?? this.couponData,
      couponErrorMessage: clearCouponError ? null : (couponErrorMessage ?? this.couponErrorMessage),
      storeCouponStatus: storeCouponStatus ?? this.storeCouponStatus,
      storeCouponData: storeCouponData ?? this.storeCouponData,
      storeCouponErrorMessage: clearStoreCouponError ? null : (storeCouponErrorMessage ?? this.storeCouponErrorMessage),
      placeOrderStatus: placeOrderStatus ?? this.placeOrderStatus,
      placeOrderErrorMessage: clearPlaceOrderError ? null : (placeOrderErrorMessage ?? this.placeOrderErrorMessage),
      placeStoreOrderStatus: placeStoreOrderStatus ?? this.placeStoreOrderStatus,
      placeStoreOrderErrorMessage: clearPlaceStoreOrderError ? null : (placeStoreOrderErrorMessage ?? this.placeStoreOrderErrorMessage),
      cancelCleaningStatus: cancelCleaningStatus ?? this.cancelCleaningStatus,
      cancelCleaningErrorMessage: clearCancelCleaningError ? null : (cancelCleaningErrorMessage ?? this.cancelCleaningErrorMessage),
      cartNote: cartNote ?? this.cartNote,
      selectedFulfillmentType: selectedFulfillmentType ?? this.selectedFulfillmentType,
      storeReceiveMode: storeReceiveMode ?? this.storeReceiveMode,
      storeScheduledAt: replaceStoreScheduledAt ? storeScheduledAt : (storeScheduledAt ?? this.storeScheduledAt),
      selectedAddress: replaceSelectedAddress ? selectedAddress : (selectedAddress ?? this.selectedAddress),
    );
  }

  bool isStoresSection() => selectedTabIndex == 0;

  RestaurantCartDataModel? activeCart() => isStoresSection() ? storeCart : restaurantCart;

  BlocStatus? activeCartStatus() => isStoresSection() ? storeCartStatus : restaurantCartStatus;

  String? activeCartError() => isStoresSection() ? storeCartErrorMessage : restaurantCartErrorMessage;

  bool activeMutatingCartItem() => isStoresSection() ? isMutatingStoreCartItem : isMutatingCartItem;

  CouponCheckDataModel? activeCouponData() => isStoresSection() ? storeCouponData : couponData;

  BlocStatus? activeCouponStatus() => isStoresSection() ? storeCouponStatus : couponStatus;

  String? activeCouponError() => isStoresSection() ? storeCouponErrorMessage : couponErrorMessage;

  BlocStatus? activePlaceOrderStatus() => isStoresSection() ? placeStoreOrderStatus : placeOrderStatus;

  String? activePlaceOrderError() => isStoresSection() ? placeStoreOrderErrorMessage : placeOrderErrorMessage;
}
