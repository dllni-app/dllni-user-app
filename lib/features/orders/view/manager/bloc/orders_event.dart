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

class FetchCartForActiveSectionEvent extends OrdersEvent {}

class FetchRestaurantCartEvent extends OrdersEvent {}
class FetchStoreCartEvent extends OrdersEvent {}

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

class UpdateStoreCartItemEvent extends OrdersEvent {
  final int itemId;
  final int quantity;

  UpdateStoreCartItemEvent({
    required this.itemId,
    required this.quantity,
  });
}

class DeleteStoreCartItemEvent extends OrdersEvent {
  final int itemId;

  DeleteStoreCartItemEvent({required this.itemId});
}

class ApplyRestaurantCouponEvent extends OrdersEvent {
  final String couponCode;

  ApplyRestaurantCouponEvent({required this.couponCode});
}

class ApplyStoreCouponEvent extends OrdersEvent {
  final String couponCode;

  ApplyStoreCouponEvent({required this.couponCode});
}

class CartNoteChangedEvent extends OrdersEvent {
  final String note;

  CartNoteChangedEvent({required this.note});
}

class CartFulfillmentTypeChangedEvent extends OrdersEvent {
  final String fulfillmentType;

  CartFulfillmentTypeChangedEvent({required this.fulfillmentType});
}

class StoreReceiveModeChangedEvent extends OrdersEvent {
  final String receiveMode;

  StoreReceiveModeChangedEvent({required this.receiveMode});
}

class StoreScheduledAtChangedEvent extends OrdersEvent {
  final String? scheduledAt;

  StoreScheduledAtChangedEvent({this.scheduledAt});
}

class CartSelectedAddressChangedEvent extends OrdersEvent {
  final AddressListItem? address;

  CartSelectedAddressChangedEvent({this.address});
}

class CancelCleaningOrderEvent extends OrdersEvent {
  final int orderId;
  final String reason;

  CancelCleaningOrderEvent({
    required this.orderId,
    required this.reason,
  });
}

class PlaceRestaurantOrderEvent extends OrdersEvent {}
class PlaceStoreOrderEvent extends OrdersEvent {}
