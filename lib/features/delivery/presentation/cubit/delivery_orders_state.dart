part of 'delivery_orders_cubit.dart';

class DeliveryOrdersState extends Equatable {
  const DeliveryOrdersState({
    this.loading = false,
    this.loadingMore = false,
    this.orders = const <DeliveryOrderModel>[],
    this.meta,
    this.error,
  });

  final bool loading;
  final bool loadingMore;
  final List<DeliveryOrderModel> orders;
  final DeliveryOrdersMetaModel? meta;
  final String? error;

  bool get hasMore {
    final current = meta?.currentPage ?? 1;
    final last = meta?.lastPage ?? 1;
    return current < last;
  }

  DeliveryOrdersState copyWith({
    bool? loading,
    bool? loadingMore,
    List<DeliveryOrderModel>? orders,
    DeliveryOrdersMetaModel? meta,
    String? error,
  }) {
    return DeliveryOrdersState(
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      orders: orders ?? this.orders,
      meta: meta ?? this.meta,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, loadingMore, orders, meta, error];
}
