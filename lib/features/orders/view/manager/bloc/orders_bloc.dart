import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/profile/domain/models/address_list_item.dart';

import '../../../data/models/orders_api_models.dart';
import '../../../domain/usecases/check_restaurant_coupon_use_case.dart';
import '../../../domain/usecases/delete_cart_item_use_case.dart';
import '../../../domain/usecases/fetch_orders_use_case.dart';
import '../../../domain/usecases/fetch_restaurant_cart_use_case.dart';
import '../../../domain/usecases/place_restaurant_order_use_case.dart';
import '../../../domain/usecases/update_cart_item_quantity_use_case.dart';

part 'orders_event.dart';
part 'orders_state.dart';

@injectable
class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final FetchOrdersUseCase fetchOrdersUseCase;
  final FetchRestaurantCartUseCase fetchRestaurantCartUseCase;
  final UpdateCartItemQuantityUseCase updateCartItemQuantityUseCase;
  final DeleteCartItemUseCase deleteCartItemUseCase;
  final CheckRestaurantCouponUseCase checkRestaurantCouponUseCase;
  final PlaceRestaurantOrderUseCase placeRestaurantOrderUseCase;

  OrdersBloc(
    this.fetchOrdersUseCase,
    this.fetchRestaurantCartUseCase,
    this.updateCartItemQuantityUseCase,
    this.deleteCartItemUseCase,
    this.checkRestaurantCouponUseCase,
    this.placeRestaurantOrderUseCase,
  ) : super(OrdersState()) {
    on<OrdersSectionChangedEvent>(_onSectionChanged);
    on<FetchOrdersEvent>(_onFetchOrders);
    on<LoadMoreOrdersEvent>(_onLoadMoreOrders);
    on<FetchRestaurantCartEvent>(_onFetchRestaurantCart);
    on<UpdateRestaurantCartItemEvent>(_onUpdateRestaurantCartItem);
    on<DeleteRestaurantCartItemEvent>(_onDeleteRestaurantCartItem);
    on<ApplyRestaurantCouponEvent>(_onApplyRestaurantCoupon);
    on<CartNoteChangedEvent>(_onCartNoteChanged);
    on<CartFulfillmentTypeChangedEvent>(_onCartFulfillmentTypeChanged);
    on<CartSelectedAddressChangedEvent>(_onCartSelectedAddressChanged);
    on<PlaceRestaurantOrderEvent>(_onPlaceRestaurantOrder);
  }

  static const List<String> _sections = <String>[
    'stores',
    'restaurant',
    'cleaning',
  ];

  String _sectionByIndex(int index) {
    if (index < 0 || index >= _sections.length) return 'restaurant';
    return _sections[index];
  }

  Future<void> _onSectionChanged(
    OrdersSectionChangedEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedTabIndex: event.tabIndex,
        status: BlocStatus.init,
        orders: const <OrderResourceModel>[],
        currentPage: 1,
        lastPage: 1,
        clearError: true,
      ),
    );
    add(FetchOrdersEvent(isReload: true));
  }

  Future<void> _onFetchOrders(
    FetchOrdersEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(
      state.copyWith(
        status: BlocStatus.loading,
        clearError: true,
      ),
    );
    final response = await fetchOrdersUseCase(
      FetchOrdersParams(
        section: _sectionByIndex(state.selectedTabIndex),
        perPage: state.perPage,
        page: 1,
      ),
    );
    response.fold(
      (failure) => emit(
        state.copyWith(
          status: BlocStatus.failed,
          errorMessage: failure.message,
        ),
      ),
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

  Future<void> _onLoadMoreOrders(
    LoadMoreOrdersEvent event,
    Emitter<OrdersState> emit,
  ) async {
    if (state.isLoadingMore) return;
    if (state.currentPage >= state.lastPage) return;
    emit(state.copyWith(isLoadingMore: true));
    final nextPage = state.currentPage + 1;
    final response = await fetchOrdersUseCase(
      FetchOrdersParams(
        section: _sectionByIndex(state.selectedTabIndex),
        perPage: state.perPage,
        page: nextPage,
      ),
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
        ),
      ),
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

  Future<void> _onUpdateRestaurantCartItem(
    UpdateRestaurantCartItemEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(isMutatingCartItem: true));
    final response = await updateCartItemQuantityUseCase(
      UpdateCartItemQuantityParams(
        itemId: event.itemId,
        quantity: event.quantity,
      ),
    );
    await response.fold(
      (failure) async => emit(
        state.copyWith(
          isMutatingCartItem: false,
          restaurantCartErrorMessage: failure.message,
        ),
      ),
      (_) async {
        emit(state.copyWith(isMutatingCartItem: false));
        add(FetchRestaurantCartEvent());
      },
    );
  }

  Future<void> _onDeleteRestaurantCartItem(
    DeleteRestaurantCartItemEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(isMutatingCartItem: true));
    final response = await deleteCartItemUseCase(
      DeleteCartItemParams(itemId: event.itemId),
    );
    await response.fold(
      (failure) async => emit(
        state.copyWith(
          isMutatingCartItem: false,
          restaurantCartErrorMessage: failure.message,
        ),
      ),
      (_) async {
        emit(state.copyWith(isMutatingCartItem: false));
        add(FetchRestaurantCartEvent());
      },
    );
  }

  Future<void> _onApplyRestaurantCoupon(
    ApplyRestaurantCouponEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(
      state.copyWith(
        couponStatus: BlocStatus.loading,
        clearCouponError: true,
      ),
    );
    final response = await checkRestaurantCouponUseCase(
      CheckRestaurantCouponParams(couponCode: event.couponCode),
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

  void _onCartNoteChanged(
    CartNoteChangedEvent event,
    Emitter<OrdersState> emit,
  ) {
    emit(state.copyWith(cartNote: event.note));
  }

  void _onCartFulfillmentTypeChanged(
    CartFulfillmentTypeChangedEvent event,
    Emitter<OrdersState> emit,
  ) {
    emit(state.copyWith(selectedFulfillmentType: event.fulfillmentType));
  }

  void _onCartSelectedAddressChanged(
    CartSelectedAddressChangedEvent event,
    Emitter<OrdersState> emit,
  ) {
    emit(
      state.copyWith(
        selectedAddress: event.address,
        replaceSelectedAddress: true,
      ),
    );
  }

  Future<void> _onPlaceRestaurantOrder(
    PlaceRestaurantOrderEvent event,
    Emitter<OrdersState> emit,
  ) async {
    final isDelivery = (state.selectedFulfillmentType ?? 'delivery') == 'delivery';
    final parsedAddressId = int.tryParse(state.selectedAddress?.id ?? '');
    final couponCode = state.couponData?.isAvailable == true
        ? state.couponData?.couponCode
        : null;
    final note = state.cartNote.trim().isEmpty ? null : state.cartNote.trim();

    emit(
      state.copyWith(
        placeOrderStatus: BlocStatus.loading,
        clearPlaceOrderError: true,
      ),
    );

    final response = await placeRestaurantOrderUseCase(
      PlaceRestaurantOrderParams(
        fulfillmentType: state.selectedFulfillmentType ?? 'delivery',
        addressId: isDelivery ? parsedAddressId : null,
        couponCode: couponCode,
        note: note,
      ),
    );

    await response.fold(
      (failure) async => emit(
        state.copyWith(
          placeOrderStatus: BlocStatus.failed,
          placeOrderErrorMessage: failure.message,
        ),
      ),
      (_) async {
        emit(
          state.copyWith(
            placeOrderStatus: BlocStatus.success,
            clearPlaceOrderError: true,
          ),
        );
        add(FetchRestaurantCartEvent());
        add(FetchOrdersEvent(isReload: true));
      },
    );
  }
}
