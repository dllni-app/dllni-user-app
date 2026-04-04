part of 'rs_orders_bloc.dart';

abstract class RsOrdersEvent {}

class RsOrdersLoadRequested extends RsOrdersEvent {
  final int page;
  final int perPage;

  RsOrdersLoadRequested({this.page = 1, this.perPage = 20});
}

class RsOrderSelected extends RsOrdersEvent {
  final int orderId;

  RsOrderSelected({required this.orderId});
}

class RsOrderCheckoutSubmitted extends RsOrdersEvent {}

class RsOrderAddCartItemRequested extends RsOrdersEvent {
  final int productId;
  final int quantity;

  RsOrderAddCartItemRequested({required this.productId, this.quantity = 1});
}

class RsOrderItemQuantityChanged extends RsOrdersEvent {
  RsOrderItemQuantityChanged({required this.itemId, required this.quantity});

  final String itemId;
  final int quantity;
}

class RsOrderItemRemoved extends RsOrdersEvent {
  RsOrderItemRemoved(this.itemId);

  final String itemId;
}

class RsOrderCouponApplied extends RsOrdersEvent {
  RsOrderCouponApplied(this.couponCode);

  final String couponCode;
}

class RsOrderNotesChanged extends RsOrdersEvent {
  RsOrderNotesChanged(this.notes);

  final String notes;
}

class RsOrderFulfillmentChanged extends RsOrdersEvent {
  RsOrderFulfillmentChanged(this.fulfillmentType);

  final RsOrderFulfillmentType fulfillmentType;
}

class RsOrderAddressChanged extends RsOrdersEvent {
  RsOrderAddressChanged(this.address);

  final RsOrderAddress address;
}

class RsOrderMessageCleared extends RsOrdersEvent {}

class RsOrderCleared extends RsOrdersEvent {}
