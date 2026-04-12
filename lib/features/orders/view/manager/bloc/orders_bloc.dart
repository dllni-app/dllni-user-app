import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/profile/domain/models/address_list_item.dart';

import '../../../data/models/cleaning_orders_api_models.dart';
import '../../../data/models/orders_api_models.dart';
import '../../../domain/usecases/cancel_cleaning_order_use_case.dart';
import '../../../domain/usecases/check_restaurant_coupon_use_case.dart';
import '../../../domain/usecases/delete_cart_item_use_case.dart';
import '../../../domain/usecases/delete_store_cart_item_use_case.dart';
import '../../../domain/usecases/fetch_cleaning_orders_use_case.dart';
import '../../../domain/usecases/fetch_orders_use_case.dart';
import '../../../domain/usecases/fetch_restaurant_cart_use_case.dart';
import '../../../domain/usecases/fetch_store_cart_use_case.dart';
import '../../../domain/usecases/place_restaurant_order_use_case.dart';
import '../../../domain/usecases/place_store_order_use_case.dart';
import '../../../domain/usecases/update_cart_item_quantity_use_case.dart';
import '../../../domain/usecases/update_store_cart_item_quantity_use_case.dart';

part 'orders_event.dart';

part 'orders_state.dart';

@injectable
class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final FetchOrdersUseCase fetchOrdersUseCase;
  final FetchCleaningOrdersUseCase fetchCleaningOrdersUseCase;
  final CancelCleaningOrderUseCase cancelCleaningOrderUseCase;
  final FetchRestaurantCartUseCase fetchRestaurantCartUseCase;
  final FetchStoreCartUseCase fetchStoreCartUseCase;
  final UpdateCartItemQuantityUseCase updateCartItemQuantityUseCase;
  final UpdateStoreCartItemQuantityUseCase updateStoreCartItemQuantityUseCase;
  final DeleteCartItemUseCase deleteCartItemUseCase;
  final DeleteStoreCartItemUseCase deleteStoreCartItemUseCase;
  final CheckRestaurantCouponUseCase checkRestaurantCouponUseCase;
  final PlaceRestaurantOrderUseCase placeRestaurantOrderUseCase;
  final PlaceStoreOrderUseCase placeStoreOrderUseCase;

  OrdersBloc(
    this.fetchOrdersUseCase,
    this.fetchCleaningOrdersUseCase,
    this.cancelCleaningOrderUseCase,
    this.fetchRestaurantCartUseCase,
    this.fetchStoreCartUseCase,
    this.updateCartItemQuantityUseCase,
    this.updateStoreCartItemQuantityUseCase,
    this.deleteCartItemUseCase,
    this.deleteStoreCartItemUseCase,
    this.checkRestaurantCouponUseCase,
    this.placeRestaurantOrderUseCase,
    this.placeStoreOrderUseCase,
  ) : super(OrdersState()) {
    on<OrdersSectionChangedEvent>(_onSectionChanged);
    on<FetchOrdersEvent>(_onFetchOrders);
    on<LoadMoreOrdersEvent>(_onLoadMoreOrders);
    on<FetchCartForActiveSectionEvent>(_onFetchCartForActiveSection);
    on<FetchRestaurantCartEvent>(_onFetchRestaurantCart);
    on<FetchStoreCartEvent>(_onFetchStoreCart);
    on<UpdateRestaurantCartItemEvent>(_onUpdateRestaurantCartItem);
    on<UpdateStoreCartItemEvent>(_onUpdateStoreCartItem);
    on<DeleteRestaurantCartItemEvent>(_onDeleteRestaurantCartItem);
    on<DeleteStoreCartItemEvent>(_onDeleteStoreCartItem);
    on<ApplyRestaurantCouponEvent>(_onApplyRestaurantCoupon);
    on<ApplyStoreCouponEvent>(_onApplyStoreCoupon);
    on<CartNoteChangedEvent>(_onCartNoteChanged);
    on<CartFulfillmentTypeChangedEvent>(_onCartFulfillmentTypeChanged);
    on<StoreReceiveModeChangedEvent>(_onStoreReceiveModeChanged);
    on<StoreScheduledAtChangedEvent>(_onStoreScheduledAtChanged);
    on<CartSelectedAddressChangedEvent>(_onCartSelectedAddressChanged);
    on<CancelCleaningOrderEvent>(_onCancelCleaningOrder);
    on<PlaceRestaurantOrderEvent>(_onPlaceRestaurantOrder);
    on<PlaceStoreOrderEvent>(_onPlaceStoreOrder);
  }

  static const List<String> _sections = <String>[
    'supermarket',
    'restaurant',
    'cleaning',
  ];

  String _sectionByIndex(int index) {
    if (index < 0 || index >= _sections.length) return 'restaurant';
    return _sections[index];
  }

  bool _isStoresSection() => _sectionByIndex(state.selectedTabIndex) == 'supermarket';
  bool _isCleaningSection() => _sectionByIndex(state.selectedTabIndex) == 'cleaning';

  Future<void> _onSectionChanged(OrdersSectionChangedEvent event, Emitter<OrdersState> emit) async {
    emit(
      state.copyWith(
        selectedTabIndex: event.tabIndex,
        status: BlocStatus.init,
        orders: const <OrderResourceModel>[],
        cleaningOrders: const <CleaningOrderModel>[],
        currentPage: 1,
        lastPage: 1,
        clearError: true,
      ),
    );
    add(FetchOrdersEvent(isReload: true));
  }

  Future<void> _onFetchCartForActiveSection(FetchCartForActiveSectionEvent event, Emitter<OrdersState> emit) async {
    if (_isStoresSection()) {
      add(FetchStoreCartEvent());
      return;
    }
    add(FetchRestaurantCartEvent());
  }

  Future<void> _onFetchOrders(FetchOrdersEvent event, Emitter<OrdersState> emit) async {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    if (_isCleaningSection()) {
      final response = await fetchCleaningOrdersUseCase(
        FetchCleaningOrdersParams(
          perPage: state.perPage,
          page: 1,
        ),
      );
      response.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failed, errorMessage: failure.message)),
        (result) => emit(
          state.copyWith(
            status: BlocStatus.success,
            cleaningOrders: result.data,
            currentPage: result.meta?.currentPage ?? 1,
            lastPage: result.meta?.lastPage ?? 1,
            clearError: true,
          ),
        ),
      );
      return;
    }
    final response = await fetchOrdersUseCase(FetchOrdersParams(section: _sectionByIndex(state.selectedTabIndex), perPage: state.perPage, page: 1));
    response.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failed, errorMessage: failure.message)),
      (result) => emit(
        state.copyWith(
          status: BlocStatus.success,
          orders: result.data,
          currentPage: result.meta?.currentPage ?? 1,
          lastPage: result.meta?.lastPage ?? 1,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onLoadMoreOrders(LoadMoreOrdersEvent event, Emitter<OrdersState> emit) async {
    if (state.isLoadingMore) return;
    if (state.currentPage >= state.lastPage) return;
    emit(state.copyWith(isLoadingMore: true));
    final nextPage = state.currentPage + 1;
    if (_isCleaningSection()) {
      final response = await fetchCleaningOrdersUseCase(
        FetchCleaningOrdersParams(
          perPage: state.perPage,
          page: nextPage,
        ),
      );
      response.fold(
        (_) => emit(state.copyWith(isLoadingMore: false)),
        (result) => emit(
          state.copyWith(
            isLoadingMore: false,
            cleaningOrders: <CleaningOrderModel>[...state.cleaningOrders, ...result.data],
            currentPage: result.meta?.currentPage ?? nextPage,
            lastPage: result.meta?.lastPage ?? state.lastPage,
          ),
        ),
      );
      return;
    }
    final response = await fetchOrdersUseCase(
      FetchOrdersParams(section: _sectionByIndex(state.selectedTabIndex), perPage: state.perPage, page: nextPage),
    );
    response.fold(
      (_) => emit(state.copyWith(isLoadingMore: false)),
      (result) => emit(
        state.copyWith(
          isLoadingMore: false,
          orders: <OrderResourceModel>[...state.orders, ...result.data],
          currentPage: result.meta?.currentPage ?? nextPage,
          lastPage: result.meta?.lastPage ?? state.lastPage,
        ),
      ),
    );
  }

  Future<void> _onFetchRestaurantCart(FetchRestaurantCartEvent event, Emitter<OrdersState> emit) async {
    emit(state.copyWith(restaurantCartStatus: BlocStatus.loading, clearRestaurantCartError: true));
    final response = await fetchRestaurantCartUseCase(NoParams());
    response.fold(
      (failure) =>
          emit(state.copyWith(restaurantCartStatus: BlocStatus.failed, restaurantCartErrorMessage: failure.message, clearRestaurantCart: true)),
      (result) => emit(
        state.copyWith(
          restaurantCartStatus: BlocStatus.success,
          replaceRestaurantCart: true,
          restaurantCart: result.data,
          clearRestaurantCartError: true,
        ),
      ),
    );
  }

  Future<void> _onFetchStoreCart(FetchStoreCartEvent event, Emitter<OrdersState> emit) async {
    emit(state.copyWith(storeCartStatus: BlocStatus.loading, clearStoreCartError: true));
    final response = await fetchStoreCartUseCase(NoParams());
    response.fold(
      (failure) => emit(state.copyWith(storeCartStatus: BlocStatus.failed, storeCartErrorMessage: failure.message, clearStoreCart: true)),
      (result) =>
          emit(state.copyWith(storeCartStatus: BlocStatus.success, replaceStoreCart: true, storeCart: result.data, clearStoreCartError: true)),
    );
  }

  Future<void> _onUpdateRestaurantCartItem(UpdateRestaurantCartItemEvent event, Emitter<OrdersState> emit) async {
    emit(state.copyWith(isMutatingCartItem: true));
    final response = await updateCartItemQuantityUseCase(UpdateCartItemQuantityParams(itemId: event.itemId, quantity: event.quantity));
    await response.fold((failure) async => emit(state.copyWith(isMutatingCartItem: false, restaurantCartErrorMessage: failure.message)), (_) async {
      emit(state.copyWith(isMutatingCartItem: false));
      add(FetchRestaurantCartEvent());
    });
  }

  Future<void> _onDeleteRestaurantCartItem(DeleteRestaurantCartItemEvent event, Emitter<OrdersState> emit) async {
    emit(state.copyWith(isMutatingCartItem: true));
    final response = await deleteCartItemUseCase(DeleteCartItemParams(itemId: event.itemId));
    await response.fold((failure) async => emit(state.copyWith(isMutatingCartItem: false, restaurantCartErrorMessage: failure.message)), (_) async {
      emit(state.copyWith(isMutatingCartItem: false));
      add(FetchRestaurantCartEvent());
    });
  }

  Future<void> _onUpdateStoreCartItem(UpdateStoreCartItemEvent event, Emitter<OrdersState> emit) async {
    emit(state.copyWith(isMutatingStoreCartItem: true));
    final response = await updateStoreCartItemQuantityUseCase(UpdateCartItemQuantityParams(itemId: event.itemId, quantity: event.quantity));
    await response.fold((failure) async => emit(state.copyWith(isMutatingStoreCartItem: false, storeCartErrorMessage: failure.message)), (_) async {
      emit(state.copyWith(isMutatingStoreCartItem: false));
      add(FetchStoreCartEvent());
    });
  }

  Future<void> _onDeleteStoreCartItem(DeleteStoreCartItemEvent event, Emitter<OrdersState> emit) async {
    emit(state.copyWith(isMutatingStoreCartItem: true));
    final response = await deleteStoreCartItemUseCase(DeleteCartItemParams(itemId: event.itemId));
    await response.fold((failure) async => emit(state.copyWith(isMutatingStoreCartItem: false, storeCartErrorMessage: failure.message)), (_) async {
      emit(state.copyWith(isMutatingStoreCartItem: false));
      add(FetchStoreCartEvent());
    });
  }

  Future<void> _onApplyRestaurantCoupon(ApplyRestaurantCouponEvent event, Emitter<OrdersState> emit) async {
    emit(state.copyWith(couponStatus: BlocStatus.loading, clearCouponError: true));
    final response = await checkRestaurantCouponUseCase(CheckRestaurantCouponParams(couponCode: event.couponCode));
    response.fold(
      (failure) => emit(state.copyWith(couponStatus: BlocStatus.failed, couponErrorMessage: failure.message)),
      (result) => emit(state.copyWith(couponStatus: BlocStatus.success, couponData: result.data, clearCouponError: true)),
    );
  }

  Future<void> _onApplyStoreCoupon(ApplyStoreCouponEvent event, Emitter<OrdersState> emit) async {
    emit(state.copyWith(storeCouponStatus: BlocStatus.loading, clearStoreCouponError: true));
    final response = await checkRestaurantCouponUseCase(
      CheckRestaurantCouponParams(
        couponCode: event.couponCode,
        section: 'supermarket',
      ),
    );
    response.fold(
      (failure) => emit(state.copyWith(storeCouponStatus: BlocStatus.failed, storeCouponErrorMessage: failure.message)),
      (result) => emit(state.copyWith(storeCouponStatus: BlocStatus.success, storeCouponData: result.data, clearStoreCouponError: true)),
    );
  }

  void _onCartNoteChanged(CartNoteChangedEvent event, Emitter<OrdersState> emit) {
    emit(state.copyWith(cartNote: event.note));
  }

  void _onCartFulfillmentTypeChanged(CartFulfillmentTypeChangedEvent event, Emitter<OrdersState> emit) {
    emit(state.copyWith(selectedFulfillmentType: event.fulfillmentType));
  }

  void _onStoreReceiveModeChanged(StoreReceiveModeChangedEvent event, Emitter<OrdersState> emit) {
    emit(
      state.copyWith(
        storeReceiveMode: event.receiveMode,
        storeScheduledAt: event.receiveMode == 'immediate' ? null : state.storeScheduledAt,
        replaceStoreScheduledAt: event.receiveMode == 'immediate',
      ),
    );
  }

  void _onStoreScheduledAtChanged(StoreScheduledAtChangedEvent event, Emitter<OrdersState> emit) {
    emit(state.copyWith(storeScheduledAt: event.scheduledAt, replaceStoreScheduledAt: true));
  }

  void _onCartSelectedAddressChanged(CartSelectedAddressChangedEvent event, Emitter<OrdersState> emit) {
    emit(state.copyWith(selectedAddress: event.address, replaceSelectedAddress: true));
  }

  Future<void> _onCancelCleaningOrder(CancelCleaningOrderEvent event, Emitter<OrdersState> emit) async {
    emit(
      state.copyWith(
        cancelCleaningStatus: BlocStatus.loading,
        clearCancelCleaningError: true,
      ),
    );
    final response = await cancelCleaningOrderUseCase(
      CancelCleaningOrderParams(
        cleaningOrderId: event.orderId,
        reason: event.reason,
      ),
    );
    response.fold(
      (failure) => emit(
        state.copyWith(
          cancelCleaningStatus: BlocStatus.failed,
          cancelCleaningErrorMessage: failure.message,
        ),
      ),
      (_) {
        emit(
          state.copyWith(
            cancelCleaningStatus: BlocStatus.success,
            clearCancelCleaningError: true,
          ),
        );
        add(FetchOrdersEvent(isReload: true));
      },
    );
  }

  Future<void> _onPlaceRestaurantOrder(PlaceRestaurantOrderEvent event, Emitter<OrdersState> emit) async {
    final isDelivery = (state.selectedFulfillmentType ?? 'delivery') == 'delivery';
    final parsedAddressId = int.tryParse(state.selectedAddress?.id ?? '');
    final couponCode = state.couponData?.isAvailable == true ? state.couponData?.couponCode : null;
    final note = state.cartNote.trim().isEmpty ? null : state.cartNote.trim();

    emit(state.copyWith(placeOrderStatus: BlocStatus.loading, clearPlaceOrderError: true));

    final response = await placeRestaurantOrderUseCase(
      PlaceRestaurantOrderParams(
        fulfillmentType: state.selectedFulfillmentType ?? 'delivery',
        addressId: isDelivery ? parsedAddressId : null,
        couponCode: couponCode,
        note: note,
      ),
    );

    await response.fold((failure) async => emit(state.copyWith(placeOrderStatus: BlocStatus.failed, placeOrderErrorMessage: failure.message)), (
      _,
    ) async {
      emit(state.copyWith(placeOrderStatus: BlocStatus.success, clearPlaceOrderError: true));
      add(FetchRestaurantCartEvent());
      add(FetchOrdersEvent(isReload: true));
    });
  }

  Future<void> _onPlaceStoreOrder(PlaceStoreOrderEvent event, Emitter<OrdersState> emit) async {
    final isDelivery = (state.selectedFulfillmentType ?? 'delivery') == 'delivery';
    final mappedFulfillmentType = isDelivery ? 'delivery' : 'dine_in';
    final merchantId = state.storeCart?.merchant?.id;
    final parsedAddressId = int.tryParse(state.selectedAddress?.id ?? '');
    final couponCode = state.storeCouponData?.isAvailable == true ? state.storeCouponData?.couponCode : null;
    final note = state.cartNote.trim().isEmpty ? null : state.cartNote.trim();
    final receiveMode = isDelivery ? state.storeReceiveMode : 'immediate';
    final scheduledAt = (isDelivery && receiveMode == 'scheduled') ? state.storeScheduledAt : null;

    if (merchantId == null) {
      emit(
        state.copyWith(
          placeStoreOrderStatus: BlocStatus.failed,
          placeStoreOrderErrorMessage: 'تعذر تحديد المتجر الحالي، يرجى تحديث السلة.',
        ),
      );
      return;
    }
    if (isDelivery && parsedAddressId == null) {
      emit(
        state.copyWith(
          placeStoreOrderStatus: BlocStatus.failed,
          placeStoreOrderErrorMessage: 'يرجى اختيار عنوان توصيل صالح',
        ),
      );
      return;
    }
    if (isDelivery && receiveMode == 'scheduled' && scheduledAt == null) {
      emit(
        state.copyWith(
          placeStoreOrderStatus: BlocStatus.failed,
          placeStoreOrderErrorMessage: 'يرجى تحديد موعد الاستلام.',
        ),
      );
      return;
    }

    emit(state.copyWith(placeStoreOrderStatus: BlocStatus.loading, clearPlaceStoreOrderError: true));

    final response = await placeStoreOrderUseCase(
      PlaceStoreOrderParams(
        merchantId: merchantId,
        fulfillmentType: mappedFulfillmentType,
        receiveMode: receiveMode,
        scheduledAt: scheduledAt,
        addressId: isDelivery ? parsedAddressId : null,
        couponCode: couponCode,
        note: note,
      ),
    );

    await response.fold(
      (failure) async => emit(state.copyWith(placeStoreOrderStatus: BlocStatus.failed, placeStoreOrderErrorMessage: failure.message)),
      (_) async {
        emit(state.copyWith(placeStoreOrderStatus: BlocStatus.success, clearPlaceStoreOrderError: true));
        add(FetchStoreCartEvent());
        add(FetchOrdersEvent(isReload: true));
      },
    );
  }
}
