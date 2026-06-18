import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/delivery_order_models.dart';
import '../../domain/usecases/fetch_delivery_order_details_use_case.dart';

part 'delivery_tracking_state.dart';

@injectable
class DeliveryTrackingCubit extends Cubit<DeliveryTrackingState> {
  DeliveryTrackingCubit(this._fetchDetails) : super(const DeliveryTrackingState());

  final FetchDeliveryOrderDetailsUseCase _fetchDetails;

  Future<void> load(int orderId, {bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(loading: true, error: null));
    }
    final result = await _fetchDetails(
      FetchDeliveryOrderDetailsParams(orderId: orderId),
    );
    result.fold(
      (failure) => emit(state.copyWith(loading: false, error: failure.message)),
      (response) => emit(
        state.copyWith(
          loading: false,
          order: response.data,
          error: null,
        ),
      ),
    );
  }
}
