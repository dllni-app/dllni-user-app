import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/pagination_helper.dart';

import '../../../domain/models/rs_order_address.dart';
import '../../../domain/models/rs_order_item.dart';
import '../../../data/models/rs_orders_api_models.dart';
import '../../../domain/usecases/add_cart_item_use_case.dart';
import '../../../domain/usecases/checkout_order_use_case.dart';
import '../../../domain/usecases/list_orders_use_case.dart';
import '../../../domain/usecases/show_order_use_case.dart';

part 'rs_orders_event.dart';

part 'rs_orders_state.dart';

@lazySingleton
class RsOrdersBloc extends Bloc<RsOrdersEvent, RsOrdersState> {
  final ListOrdersUseCase listOrdersUseCase;
  final ShowOrderUseCase showOrderUseCase;
  final CheckoutOrderUseCase checkoutOrderUseCase;
  final AddCartItemUseCase addCartItemUseCase;

  RsOrdersBloc(
    this.listOrdersUseCase,
    this.showOrderUseCase,
    this.checkoutOrderUseCase,
    this.addCartItemUseCase,
  ) : super(RsOrdersState.initial()) {
    on<RsOrdersLoadRequested>(_onLoadOrders);
    on<RsOrderSelected>(_onOrderSelected);
    on<RsOrderCheckoutSubmitted>(_onCheckoutSubmitted);
    on<RsOrderAddCartItemRequested>(_onAddCartItemRequested);
    on<RsOrderItemQuantityChanged>(_onOrderItemQuantityChanged);
    on<RsOrderItemRemoved>(_onOrderItemRemoved);
    on<RsOrderCouponApplied>(_onOrderCouponApplied);
    on<RsOrderNotesChanged>(_onOrderNotesChanged);
    on<RsOrderFulfillmentChanged>(_onOrderFulfillmentChanged);
    on<RsOrderAddressChanged>(_onOrderAddressChanged);
    on<RsOrderMessageCleared>(_onOrderMessageCleared);
    on<RsOrderCleared>(_onOrderCleared);
  }

  Future<void> _onLoadOrders(RsOrdersLoadRequested event, Emitter<RsOrdersState> emit) async {
    emit(state.copyWith(ordersStatus: BlocStatus.loading));
    final res = await listOrdersUseCase(ListOrdersParams(page: event.page, perPage: event.perPage));
    res.fold(
      (l) => emit(state.copyWith(ordersStatus: BlocStatus.failed, message: l.message, isMessageSuccess: false)),
      (r) async {
        final list = r.data ?? const <OrderResourceModel>[];
        emit(state.copyWith(ordersStatus: BlocStatus.success, orders: list));
        if (list.isNotEmpty && list.first.id != null) {
          add(RsOrderSelected(orderId: list.first.id!));
        } else {
          emit(state.copyWith(clearSelectedOrder: true, items: const []));
        }
      },
    );
  }

  Future<void> _onOrderSelected(RsOrderSelected event, Emitter<RsOrdersState> emit) async {
    emit(state.copyWith(orderDetailsStatus: BlocStatus.loading));
    final res = await showOrderUseCase(ShowOrderParams(orderId: event.orderId));
    res.fold(
      (l) => emit(state.copyWith(orderDetailsStatus: BlocStatus.failed, message: l.message, isMessageSuccess: false)),
      (r) {
        final order = r.data;
        emit(
          state.copyWith(
            orderDetailsStatus: BlocStatus.success,
            selectedOrder: order,
            items: _toOrderItems(order),
            restaurantLocationTitle: order?.restaurant?.name ?? state.restaurantLocationTitle,
          ),
        );
      },
    );
  }

  Future<void> _onCheckoutSubmitted(RsOrderCheckoutSubmitted event, Emitter<RsOrdersState> emit) async {
    final restaurantId = state.selectedOrder?.restaurantId;
    if (restaurantId == null) {
      emit(state.copyWith(message: 'لا يوجد طلب صالح للإرسال', isMessageSuccess: false));
      return;
    }
    emit(state.copyWith(checkoutStatus: BlocStatus.loading));
    final res = await checkoutOrderUseCase(
      CheckoutOrderParams(
        restaurantId: restaurantId,
        orderType: state.fulfillmentType == RsOrderFulfillmentType.delivery ? 'delivery' : 'pickup',
        promoCode: state.appliedCouponCode,
        specialInstructions: state.notes,
      ),
    );
    res.fold(
      (l) => emit(state.copyWith(checkoutStatus: BlocStatus.failed, message: l.message, isMessageSuccess: false)),
      (r) => emit(
        state.copyWith(
          checkoutStatus: BlocStatus.success,
          message: r.message ?? 'تم إرسال الطلب',
          isMessageSuccess: true,
        ),
      ),
    );
  }

  Future<void> _onAddCartItemRequested(RsOrderAddCartItemRequested event, Emitter<RsOrdersState> emit) async {
    final res = await addCartItemUseCase(AddCartItemParams(productId: event.productId, quantity: event.quantity));
    res.fold(
      (l) => emit(state.copyWith(message: l.message, isMessageSuccess: false)),
      (r) => emit(state.copyWith(message: r.message ?? 'تمت الإضافة إلى السلة', isMessageSuccess: true)),
    );
  }

  void _onOrderItemQuantityChanged(RsOrderItemQuantityChanged event, Emitter<RsOrdersState> emit) {
    final updatedItems = state.items.map((item) {
      if (item.id != event.itemId) {
        return item;
      }
      return item.copyWith(quantity: event.quantity.clamp(1, 20).toInt());
    }).toList();
    emit(state.copyWith(items: updatedItems));
  }

  void _onOrderItemRemoved(RsOrderItemRemoved event, Emitter<RsOrdersState> emit) {
    final updatedItems = state.items.where((item) => item.id != event.itemId).toList();
    emit(state.copyWith(items: updatedItems));
  }

  void _onOrderCouponApplied(RsOrderCouponApplied event, Emitter<RsOrdersState> emit) {
    emit(
      state.copyWith(
        appliedCouponCode: null,
        couponDiscount: 0,
        message: 'ميزة تطبيق كوبون الخصم غير متاحة حالياً',
        isMessageSuccess: false,
      ),
    );
  }

  void _onOrderNotesChanged(RsOrderNotesChanged event, Emitter<RsOrdersState> emit) {
    emit(state.copyWith(notes: event.notes));
  }

  void _onOrderFulfillmentChanged(RsOrderFulfillmentChanged event, Emitter<RsOrdersState> emit) {
    emit(state.copyWith(fulfillmentType: event.fulfillmentType));
  }

  void _onOrderAddressChanged(RsOrderAddressChanged event, Emitter<RsOrdersState> emit) {
    emit(state.copyWith(deliveryAddress: event.address));
  }

  void _onOrderMessageCleared(RsOrderMessageCleared event, Emitter<RsOrdersState> emit) {
    emit(state.copyWith(clearMessage: true));
  }

  void _onOrderCleared(RsOrderCleared event, Emitter<RsOrdersState> emit) {
    emit(state.copyWith(items: const [], appliedCouponCode: null, couponDiscount: 0, notes: ''));
  }

  List<RsOrderItem> _toOrderItems(OrderResourceModel? order) {
    final lines = order?.orderItems ?? const <OrderLineItem>[];
    return lines
        .map(
          (e) => RsOrderItem(
            id: '${e.id ?? 0}',
            name: e.product?.name ?? '',
            restaurantName: order?.restaurant?.name ?? '',
            details: '',
            unitPrice: 0,
            quantity: e.quantity ?? 1,
          ),
        )
        .toList();
  }
}
