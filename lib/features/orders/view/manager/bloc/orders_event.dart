part of 'orders_bloc.dart';

abstract class OrdersEvent {}

class OrdersSectionChangedEvent extends OrdersEvent {
  final int tabIndex;

  OrdersSectionChangedEvent(this.tabIndex);
}

class FetchOrdersEvent extends OrdersEvent with EventWithReload {
  final bool loadMore;
  final bool isReload;
  final bool silentRefresh;
  final int? orderDeletedId;

  FetchOrdersEvent({
    this.loadMore = false,
    this.isReload = false,
    this.silentRefresh = false,
    this.orderDeletedId,
  });
}

class FetchCartForActiveSectionEvent extends OrdersEvent {}

class FetchRestaurantCartEvent extends OrdersEvent {}

class FetchStoreCartEvent extends OrdersEvent {}

class SelectRestaurantCartEvent extends OrdersEvent {
  final int cartId;

  SelectRestaurantCartEvent({required this.cartId});
}

class SelectStoreCartEvent extends OrdersEvent {
  final int cartId;

  SelectStoreCartEvent({required this.cartId});
}

class UpdateRestaurantCartItemEvent extends OrdersEvent {
  final int cartId;
  final int itemId;
  final int quantity;

  UpdateRestaurantCartItemEvent({
    required this.cartId,
    required this.itemId,
    required this.quantity,
  });
}

class DeleteRestaurantCartItemEvent extends OrdersEvent {
  final int cartId;
  final int itemId;

  DeleteRestaurantCartItemEvent({required this.cartId, required this.itemId});
}

class UpdateStoreCartItemEvent extends OrdersEvent {
  final int cartId;
  final int itemId;
  final int quantity;

  UpdateStoreCartItemEvent({
    required this.cartId,
    required this.itemId,
    required this.quantity,
  });
}

class DeleteStoreCartItemEvent extends OrdersEvent {
  final int cartId;
  final int itemId;

  DeleteStoreCartItemEvent({required this.cartId, required this.itemId});
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

  CancelCleaningOrderEvent({required this.orderId, required this.reason});
}

class PlaceRestaurantOrderEvent extends OrdersEvent {
  final int cartId;

  PlaceRestaurantOrderEvent({required this.cartId});
}

class PlaceStoreOrderEvent extends OrdersEvent {
  final int cartId;

  PlaceStoreOrderEvent({required this.cartId});
}
