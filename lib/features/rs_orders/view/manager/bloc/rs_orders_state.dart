part of 'rs_orders_bloc.dart';

enum RsOrderFulfillmentType { delivery, pickup }

class RsOrdersState {
  const RsOrdersState({
    required this.ordersStatus,
    required this.orderDetailsStatus,
    required this.checkoutStatus,
    required this.orders,
    required this.selectedOrder,
    required this.items,
    required this.notes,
    required this.fulfillmentType,
    required this.deliveryAddress,
    required this.restaurantLocationTitle,
    required this.restaurantLocationStreet,
    required this.deliveryFee,
    required this.appliedCouponCode,
    required this.couponDiscount,
    this.message,
    this.isMessageSuccess = false,
  });

  final BlocStatus ordersStatus;
  final BlocStatus orderDetailsStatus;
  final BlocStatus checkoutStatus;
  final List<OrderResourceModel> orders;
  final OrderResourceModel? selectedOrder;
  final List<RsOrderItem> items;
  final String notes;
  final RsOrderFulfillmentType fulfillmentType;
  final RsOrderAddress deliveryAddress;
  final String restaurantLocationTitle;
  final String restaurantLocationStreet;
  final int deliveryFee;
  final String? appliedCouponCode;
  final int couponDiscount;
  final String? message;
  final bool isMessageSuccess;

  int get itemsSubtotal => items.fold<int>(0, (sum, item) => sum + item.totalPrice);

  int get totalBeforeDiscount => itemsSubtotal + (fulfillmentType == RsOrderFulfillmentType.delivery ? deliveryFee : 0);

  int get totalAmount => totalBeforeDiscount - couponDiscount;

  bool get hasItems => items.isNotEmpty;

  RsOrdersState copyWith({
    BlocStatus? ordersStatus,
    BlocStatus? orderDetailsStatus,
    BlocStatus? checkoutStatus,
    List<OrderResourceModel>? orders,
    OrderResourceModel? selectedOrder,
    bool clearSelectedOrder = false,
    List<RsOrderItem>? items,
    String? notes,
    RsOrderFulfillmentType? fulfillmentType,
    RsOrderAddress? deliveryAddress,
    String? restaurantLocationTitle,
    String? restaurantLocationStreet,
    int? deliveryFee,
    String? appliedCouponCode,
    int? couponDiscount,
    String? message,
    bool clearMessage = false,
    bool? isMessageSuccess,
  }) {
    return RsOrdersState(
      ordersStatus: ordersStatus ?? this.ordersStatus,
      orderDetailsStatus: orderDetailsStatus ?? this.orderDetailsStatus,
      checkoutStatus: checkoutStatus ?? this.checkoutStatus,
      orders: orders ?? this.orders,
      selectedOrder: clearSelectedOrder ? null : (selectedOrder ?? this.selectedOrder),
      items: items ?? this.items,
      notes: notes ?? this.notes,
      fulfillmentType: fulfillmentType ?? this.fulfillmentType,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      restaurantLocationTitle: restaurantLocationTitle ?? this.restaurantLocationTitle,
      restaurantLocationStreet: restaurantLocationStreet ?? this.restaurantLocationStreet,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      appliedCouponCode: appliedCouponCode ?? this.appliedCouponCode,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      message: clearMessage ? null : (message ?? this.message),
      isMessageSuccess: isMessageSuccess ?? this.isMessageSuccess,
    );
  }

  factory RsOrdersState.initial() {
    return RsOrdersState(
      ordersStatus: BlocStatus.init,
      orderDetailsStatus: BlocStatus.init,
      checkoutStatus: BlocStatus.init,
      orders: const [],
      selectedOrder: null,
      items: const [],
      notes: '',
      fulfillmentType: RsOrderFulfillmentType.delivery,
      deliveryAddress: const RsOrderAddress(id: '', label: '', cityLine: '', streetLine: ''),
      restaurantLocationTitle: '',
      restaurantLocationStreet: '',
      deliveryFee: 0,
      appliedCouponCode: null,
      couponDiscount: 0,
    );
  }
}
