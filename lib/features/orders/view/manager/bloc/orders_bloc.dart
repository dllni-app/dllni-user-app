import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/profile/domain/models/address_list_item.dart';

import '../../../data/models/cleaning_orders_api_models.dart';
import '../../../data/models/merchant_cart_models.dart';
import '../../../data/models/orders_api_models.dart';
import '../../helpers/cleaning_lifecycle_error_mapper.dart';
import '../../helpers/cleaning_order_polling_equality.dart';
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
    on<FetchOrdersEvent>(
      _onFetchOrders,
      transformer: paginationEventTransformer(),
    );
    on<FetchCartForActiveSectionEvent>(_onFetchCartForActiveSection);
    on<FetchRestaurantCartEvent>(_onFetchRestaurantCart);
    on<FetchStoreCartEvent>(_onFetchStoreCart);
    on<SelectRestaurantCartEvent>(_onSelectRestaurantCart);
    on<SelectStoreCartEvent>(_onSelectStoreCart);
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

  bool _isStoresSection() =>
      _sectionByIndex(state.selectedTabIndex) == 'supermarket';

  bool _isCleaningSection() =>
      _sectionByIndex(state.selectedTabIndex) == 'cleaning';

  RestaurantCartDataModel? _cartById(
    List<RestaurantCartDataModel> carts,
    int cartId,
  ) {
    for (final cart in carts) {
      if (cart.id == cartId) return cart;
    }
    return null;
  }

  List<RestaurantCartDataModel> _upsertCart(
    List<RestaurantCartDataModel> carts,
    RestaurantCartDataModel? cart,
  ) {
    if (cart?.id == null) return carts;
    if (cart!.items.isEmpty) {
      return carts.where((item) => item.id != cart.id).toList();
    }
    final next = List<RestaurantCartDataModel>.from(carts);
    final index = next.indexWhere((item) => item.id == cart.id);
    if (index == -1) {
      next.add(cart);
    } else {
      next[index] = cart;
    }
    return next;
  }

  Future<void> _onSectionChanged(
    OrdersSectionChangedEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedTabIndex: event.tabIndex,
        orders: const PaginationStateModel<OrderResourceModel>(perPage: 10),
        cleaningOrders: const PaginationStateModel<CleaningOrderModel>(
          perPage: 10,
        ),
        clearError: true,
      ),
    );
    add(FetchOrdersEvent(isReload: true));
  }

  Future<void> _onFetchCartForActiveSection(
    FetchCartForActiveSectionEvent event,
    Emitter<OrdersState> emit,
  ) async {
    if (_isStoresSection()) {
      add(FetchStoreCartEvent());
      return;
    }
    add(FetchRestaurantCartEvent());
  }

  Future<void> _onFetchOrders(
    FetchOrdersEvent event,
    Emitter<OrdersState> emit,
  ) async {
    final isCleaning = _isCleaningSection();
    final isLoadMore = event.loadMore && !event.isReload;
    if (isCleaning) {
      final pagination = state.cleaningOrders;
      if (isLoadMore && pagination.isEndPage) return;
      if (event.silentRefresh) {
        if (pagination.status == BlocStatus.loading) return;
        final perPage = pagination.perPage;
        final response = await fetchCleaningOrdersUseCase(
          FetchCleaningOrdersParams(perPage: perPage, page: 1),
        );
        response.fold((_) {}, (result) {
          final mergedList = mergeCleaningOrdersSilentPage1(
            current: pagination.list,
            fetched: result.data,
            perPage: perPage,
          );
          if (cleaningOrderListsReferentiallyEqual(
            pagination.list,
            mergedList,
          )) {
            return;
          }
          final resolvedPerPage = result.meta?.perPage ?? perPage;
          final resolvedTotal = result.meta?.total ?? pagination.total;
          emit(
            state.copyWith(
              cleaningOrders: pagination.copyWith(
                list: mergedList,
                total: resolvedTotal,
                perPage: resolvedPerPage,
                isEndPage: result.data.length < resolvedPerPage,
                status: BlocStatus.success,
              ),
              clearError: true,
            ),
          );
        });
        return;
      }
      emit(
        state.copyWith(
          cleaningOrders: pagination.setLoading(isReload: event.isReload),
          clearError: true,
        ),
      );
      final page = isLoadMore ? pagination.pageNumber : 1;
      final perPage = pagination.perPage;
      final response = await fetchCleaningOrdersUseCase(
        FetchCleaningOrdersParams(perPage: perPage, page: page),
      );
      response.fold(
        (failure) => emit(
          state.copyWith(
            cleaningOrders: pagination.setFaild(errorMessage: failure.message),
            errorMessage: failure.message,
          ),
        ),
        (result) {
          emit(
            state.copyWith(
              cleaningOrders: pagination.setSuccess(
                data: result.data,
                total: result.meta?.total ?? pagination.total,
                perPage: result.meta?.perPage ?? perPage,
              ),
              clearError: true,
            ),
          );
        },
      );
      return;
    }

    final pagination = state.orders;
    if (isLoadMore && pagination.isEndPage) return;
    emit(
      state.copyWith(
        orders: pagination.setLoading(isReload: event.isReload),
        clearError: true,
      ),
    );
    final page = isLoadMore ? pagination.pageNumber : 1;
    final perPage = pagination.perPage;

    final response = await fetchOrdersUseCase(
      FetchOrdersParams(
        section: _sectionByIndex(state.selectedTabIndex),
        perPage: perPage,
        page: page,
      ),
    );
    response.fold(
      (failure) => emit(
        state.copyWith(
          orders: pagination.setFaild(errorMessage: failure.message),
          errorMessage: failure.message,
        ),
      ),
      (result) {
        emit(
          state.copyWith(
            orders: pagination.setSuccess(
              data: result.data,
              total: result.meta?.total ?? pagination.total,
              perPage: result.meta?.perPage ?? perPage,
            ),
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> _onFetchRestaurantCart(
    FetchRestaurantCartEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(
      state.copyWith(
        restaurantCartStatus: BlocStatus.loading,
        clearRestaurantCartError: true,
      ),
    );
    final response = await fetchRestaurantCartUseCase(NoParams());
    response.fold(
      (failure) => emit(
        state.copyWith(
          restaurantCartStatus: BlocStatus.failed,
          restaurantCartErrorMessage: failure.message,
          clearRestaurantCart: true,
          replaceRestaurantCarts: true,
          restaurantCarts: const <RestaurantCartDataModel>[],
        ),
      ),
      (result) => emit(
        state.copyWith(
          restaurantCartStatus: BlocStatus.success,
          replaceRestaurantCarts: true,
          restaurantCarts: result.data,
          replaceRestaurantCart: true,
          restaurantCart: result.data.isEmpty ? null : result.data.first,
          clearRestaurantCartError: true,
        ),
      ),
    );
  }

  Future<void> _onFetchStoreCart(
    FetchStoreCartEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(
      state.copyWith(
        storeCartStatus: BlocStatus.loading,
        clearStoreCartError: true,
      ),
    );
    final response = await fetchStoreCartUseCase(NoParams());
    response.fold(
      (failure) => emit(
        state.copyWith(
          storeCartStatus: BlocStatus.failed,
          storeCartErrorMessage: failure.message,
          clearStoreCart: true,
          replaceStoreCarts: true,
          storeCarts: const <RestaurantCartDataModel>[],
        ),
      ),
      (result) => emit(
        state.copyWith(
          storeCartStatus: BlocStatus.success,
          replaceStoreCarts: true,
          storeCarts: result.data,
          replaceStoreCart: true,
          storeCart: result.data.isEmpty ? null : result.data.first,
          clearStoreCartError: true,
        ),
      ),
    );
  }

  void _onSelectRestaurantCart(
    SelectRestaurantCartEvent event,
    Emitter<OrdersState> emit,
  ) {
    emit(
      state.copyWith(
        replaceRestaurantCart: true,
        restaurantCart: _cartById(state.restaurantCarts, event.cartId),
      ),
    );
  }

  void _onSelectStoreCart(
    SelectStoreCartEvent event,
    Emitter<OrdersState> emit,
  ) {
    emit(
      state.copyWith(
        replaceStoreCart: true,
        storeCart: _cartById(state.storeCarts, event.cartId),
      ),
    );
  }

  Future<void> _onUpdateRestaurantCartItem(
    UpdateRestaurantCartItemEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(isMutatingCartItem: true));
    final response = await updateCartItemQuantityUseCase(
      UpdateCartItemQuantityParams(
        cartId: event.cartId,
        itemId: event.itemId,
        quantity: event.quantity,
      ),
    );
    response.fold(
      (failure) => emit(
        state.copyWith(
          isMutatingCartItem: false,
          restaurantCartErrorMessage: failure.message,
        ),
      ),
      (result) {
        final carts = _upsertCart(state.restaurantCarts, result.data);
        emit(
          state.copyWith(
            isMutatingCartItem: false,
            replaceRestaurantCarts: true,
            restaurantCarts: carts,
            replaceRestaurantCart: true,
            restaurantCart: _cartById(carts, event.cartId),
          ),
        );
      },
    );
  }

  Future<void> _onDeleteRestaurantCartItem(
    DeleteRestaurantCartItemEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(isMutatingCartItem: true));
    final response = await deleteCartItemUseCase(
      DeleteCartItemParams(cartId: event.cartId, itemId: event.itemId),
    );
    response.fold(
      (failure) => emit(
        state.copyWith(
          isMutatingCartItem: false,
          restaurantCartErrorMessage: failure.message,
        ),
      ),
      (result) {
        final carts = result.data?.id == null
            ? state.restaurantCarts.where((cart) => cart.id != event.cartId).toList()
            : _upsertCart(state.restaurantCarts, result.data);
        emit(
          state.copyWith(
            isMutatingCartItem: false,
            replaceRestaurantCarts: true,
            restaurantCarts: carts,
            replaceRestaurantCart: true,
            restaurantCart: _cartById(carts, event.cartId) ??
                (carts.isEmpty ? null : carts.first),
          ),
        );
      },
    );
  }

  Future<void> _onUpdateStoreCartItem(
    UpdateStoreCartItemEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(isMutatingStoreCartItem: true));
    final response = await updateStoreCartItemQuantityUseCase(
      UpdateCartItemQuantityParams(
        cartId: event.cartId,
        itemId: event.itemId,
        quantity: event.quantity,
      ),
    );
    response.fold(
      (failure) => emit(
        state.copyWith(
          isMutatingStoreCartItem: false,
          storeCartErrorMessage: failure.message,
        ),
      ),
      (result) {
        final carts = _upsertCart(state.storeCarts, result.data);
        emit(
          state.copyWith(
            isMutatingStoreCartItem: false,
            replaceStoreCarts: true,
            storeCarts: carts,
            replaceStoreCart: true,
            storeCart: _cartById(carts, event.cartId),
          ),
        );
      },
    );
  }

  Future<void> _onDeleteStoreCartItem(
    DeleteStoreCartItemEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(isMutatingStoreCartItem: true));
    final response = await deleteStoreCartItemUseCase(
      DeleteCartItemParams(cartId: event.cartId, itemId: event.itemId),
    );
    response.fold(
      (failure) => emit(
        state.copyWith(
          isMutatingStoreCartItem: false,
          storeCartErrorMessage: failure.message,
        ),
      ),
      (result) {
        final carts = result.data?.id == null
            ? state.storeCarts.where((cart) => cart.id != event.cartId).toList()
            : _upsertCart(state.storeCarts, result.data);
        emit(
          state.copyWith(
            isMutatingStoreCartItem: false,
            replaceStoreCarts: true,
            storeCarts: carts,
            replaceStoreCart: true,
            storeCart: _cartById(carts, event.cartId) ??
                (carts.isEmpty ? null : carts.first),
          ),
        );
      },
    );
  }

  Future<void> _onApplyRestaurantCoupon(
    ApplyRestaurantCouponEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(couponStatus: BlocStatus.loading, clearCouponError: true));
    final response = await checkRestaurantCouponUseCase(
      CheckRestaurantCouponParams(couponCode: event.couponCode),
    );
    response.fold(
      (failure) => emit(state.copyWith(couponStatus: BlocStatus.failed, couponErrorMessage: failure.message)),
      (result) => emit(state.copyWith(couponStatus: BlocStatus.success, couponData: result.data, clearCouponError: true)),
    );
  }

  Future<void> _onApplyStoreCoupon(
    ApplyStoreCouponEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(storeCouponStatus: BlocStatus.loading, clearStoreCouponError: true));
    final response = await checkRestaurantCouponUseCase(
      CheckRestaurantCouponParams(couponCode: event.couponCode, section: 'supermarket'),
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
    emit(state.copyWith(cancelCleaningStatus: BlocStatus.loading, clearCancelCleaningError: true));
    final response = await cancelCleaningOrderUseCase(
      CancelCleaningOrderParams(cleaningOrderId: event.orderId, reason: event.reason),
    );
    response.fold(
      (failure) => emit(
        state.copyWith(
          cancelCleaningStatus: BlocStatus.failed,
          cancelCleaningErrorMessage: CleaningLifecycleErrorMapper.mapCancelFailure(failure),
        ),
      ),
      (_) {
        final List<OrderResourceModel> list = List.from(state.orders.list)
          ..removeWhere((e) => e.id == event.orderId);
        emit(
          state.copyWith(
            cancelCleaningStatus: BlocStatus.success,
            clearCancelCleaningError: true,
            orders: state.orders.copyWith(list: list),
          ),
        );
        add(FetchOrdersEvent(isReload: true, orderDeletedId: event.orderId));
      },
    );
  }

  Future<void> _onPlaceRestaurantOrder(
    PlaceRestaurantOrderEvent event,
    Emitter<OrdersState> emit,
  ) async {
    final isDelivery = (state.selectedFulfillmentType ?? 'delivery') == 'delivery';
    final parsedAddressId = int.tryParse(state.selectedAddress?.id ?? '');
    final couponCode = state.couponData?.isAvailable == true ? state.couponData?.couponCode : null;
    final note = state.cartNote.trim().isEmpty ? null : state.cartNote.trim();

    emit(state.copyWith(placeOrderStatus: BlocStatus.loading, clearPlaceOrderError: true));

    final response = await placeRestaurantOrderUseCase(
      PlaceRestaurantOrderParams(
        cartId: event.cartId,
        fulfillmentType: state.selectedFulfillmentType ?? 'delivery',
        receiveMode: 'immediate',
        addressId: isDelivery ? parsedAddressId : null,
        couponCode: couponCode,
        note: note,
      ),
    );

    response.fold(
      (failure) => emit(state.copyWith(placeOrderStatus: BlocStatus.failed, placeOrderErrorMessage: failure.message)),
      (_) {
        final carts = state.restaurantCarts.where((cart) => cart.id != event.cartId).toList();
        emit(
          state.copyWith(
            placeOrderStatus: BlocStatus.success,
            clearPlaceOrderError: true,
            replaceRestaurantCarts: true,
            restaurantCarts: carts,
            replaceRestaurantCart: true,
            restaurantCart: carts.isEmpty ? null : carts.first,
          ),
        );
        add(FetchOrdersEvent(isReload: true));
      },
    );
  }

  Future<void> _onPlaceStoreOrder(
    PlaceStoreOrderEvent event,
    Emitter<OrdersState> emit,
  ) async {
    final isDelivery = (state.selectedFulfillmentType ?? 'delivery') == 'delivery';
    final mappedFulfillmentType = isDelivery ? 'delivery' : 'dine_in';
    final parsedAddressId = int.tryParse(state.selectedAddress?.id ?? '');
    final couponCode = state.storeCouponData?.isAvailable == true ? state.storeCouponData?.couponCode : null;
    final note = state.cartNote.trim().isEmpty ? null : state.cartNote.trim();
    final receiveMode = isDelivery ? state.storeReceiveMode : 'immediate';
    final scheduledAt = (isDelivery && receiveMode == 'scheduled') ? state.storeScheduledAt : null;

    if (isDelivery && parsedAddressId == null) {
      emit(state.copyWith(placeStoreOrderStatus: BlocStatus.failed, placeStoreOrderErrorMessage: 'يرجى اختيار عنوان توصيل صالح'));
      return;
    }
    if (isDelivery && receiveMode == 'scheduled' && scheduledAt == null) {
      emit(state.copyWith(placeStoreOrderStatus: BlocStatus.failed, placeStoreOrderErrorMessage: 'يرجى تحديد موعد الاستلام.'));
      return;
    }

    emit(state.copyWith(placeStoreOrderStatus: BlocStatus.loading, clearPlaceStoreOrderError: true));

    final response = await placeStoreOrderUseCase(
      PlaceStoreOrderParams(
        cartId: event.cartId,
        fulfillmentType: mappedFulfillmentType,
        receiveMode: receiveMode,
        scheduledAt: scheduledAt,
        addressId: isDelivery ? parsedAddressId : null,
        couponCode: couponCode,
        note: note,
      ),
    );

    response.fold(
      (failure) => emit(state.copyWith(placeStoreOrderStatus: BlocStatus.failed, placeStoreOrderErrorMessage: failure.message)),
      (_) {
        final carts = state.storeCarts.where((cart) => cart.id != event.cartId).toList();
        emit(
          state.copyWith(
            placeStoreOrderStatus: BlocStatus.success,
            clearPlaceStoreOrderError: true,
            replaceStoreCarts: true,
            storeCarts: carts,
            replaceStoreCart: true,
            storeCart: carts.isEmpty ? null : carts.first,
          ),
        );
        add(FetchOrdersEvent(isReload: true));
      },
    );
  }
}
