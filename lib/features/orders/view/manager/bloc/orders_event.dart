part of 'orders_bloc.dart';

abstract class OrdersEvent {}

class OrdersSectionChangedEvent extends OrdersEvent {
  final int tabIndex;

  OrdersSectionChangedEvent(this.tabIndex);
}

class FetchOrdersEvent extends OrdersEvent {
  final bool isReload;

  FetchOrdersEvent({this.isReload = false});
}

class LoadMoreOrdersEvent extends OrdersEvent {}

class FetchRestaurantCartEvent extends OrdersEvent {}

class UpdateRestaurantCartItemEvent extends OrdersEvent {
  final int itemId;
  final int quantity;

  UpdateRestaurantCartItemEvent({
    required this.itemId,
    required this.quantity,
  });
}

class DeleteRestaurantCartItemEvent extends OrdersEvent {
  final int itemId;

  DeleteRestaurantCartItemEvent({required this.itemId});
}

class ApplyRestaurantCouponEvent extends OrdersEvent {
  final String couponCode;

  ApplyRestaurantCouponEvent({required this.couponCode});
}

class CartNoteChangedEvent extends OrdersEvent {
  final String note;

  CartNoteChangedEvent({required this.note});
}

class CartFulfillmentTypeChangedEvent extends OrdersEvent {
  final String fulfillmentType;

  CartFulfillmentTypeChangedEvent({required this.fulfillmentType});
}

class CartSelectedAddressChangedEvent extends OrdersEvent {
  final AddressListItem? address;

  CartSelectedAddressChangedEvent({this.address});
}

class PlaceRestaurantOrderEvent extends OrdersEvent {}
