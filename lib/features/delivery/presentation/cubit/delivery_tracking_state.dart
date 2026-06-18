part of 'delivery_tracking_cubit.dart';

class DeliveryTrackingState extends Equatable {
  const DeliveryTrackingState({
    this.loading = false,
    this.order,
    this.error,
  });

  final bool loading;
  final DeliveryOrderModel? order;
  final String? error;

  DeliveryTrackingState copyWith({
    bool? loading,
    DeliveryOrderModel? order,
    String? error,
  }) {
    return DeliveryTrackingState(
      loading: loading ?? this.loading,
      order: order ?? this.order,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, order, error];
}
