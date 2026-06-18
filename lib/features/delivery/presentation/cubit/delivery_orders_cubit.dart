import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/delivery_order_models.dart';
import '../../domain/usecases/fetch_delivery_orders_use_case.dart';

part 'delivery_orders_state.dart';

@injectable
class DeliveryOrdersCubit extends Cubit<DeliveryOrdersState> {
  DeliveryOrdersCubit(this._fetchOrders) : super(const DeliveryOrdersState());

  final FetchDeliveryOrdersUseCase _fetchOrders;

  Future<void> load({bool reload = false}) async {
    if (state.loading && !reload) return;
    emit(state.copyWith(loading: true, error: reload ? null : state.error));
    final result = await _fetchOrders(FetchDeliveryOrdersParams(page: 1));
    result.fold(
      (failure) => emit(state.copyWith(loading: false, error: failure.message)),
      (response) => emit(
        state.copyWith(
          loading: false,
          orders: response.data,
          meta: response.meta,
          error: null,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    if (state.loadingMore || !state.hasMore) return;
    final nextPage = (state.meta?.currentPage ?? 1) + 1;
    emit(state.copyWith(loadingMore: true));
    final result = await _fetchOrders(
      FetchDeliveryOrdersParams(page: nextPage, perPage: state.meta?.perPage ?? 20),
    );
    result.fold(
      (failure) => emit(state.copyWith(loadingMore: false, error: failure.message)),
      (response) {
        emit(
          state.copyWith(
            loadingMore: false,
            orders: [...state.orders, ...response.data],
            meta: response.meta,
          ),
        );
      },
    );
  }

  bool get hasActiveOrders =>
      state.orders.any((order) => !order.isTerminal);
}
