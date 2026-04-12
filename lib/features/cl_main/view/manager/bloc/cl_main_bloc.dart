import 'dart:async';

import 'package:common_package/helpers/pagination_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/create_cleaning_order_use_case.dart';
import '../../../domain/usecases/estimate_cleaning_price_use_case.dart';
import '../../../domain/usecases/get_previous_cleaning_workers_use_case.dart';
import '../../../data/models/create_cleaning_order_response_model.dart';
import '../../../data/models/estimate_price_response_model.dart';
import '../../../data/models/previous_workers_response_model.dart';

part 'cl_main_event.dart';
part 'cl_main_state.dart';

@injectable
class ClMainBloc extends Bloc<ClMainEvent, ClMainState> {
  final EstimateCleaningPriceUseCase estimateCleaningPriceUseCase;
  final GetPreviousCleaningWorkersUseCase getPreviousCleaningWorkersUseCase;
  final CreateCleaningOrderUseCase createCleaningOrderUseCase;

  ClMainBloc({
    required this.estimateCleaningPriceUseCase,
    required this.getPreviousCleaningWorkersUseCase,
    required this.createCleaningOrderUseCase,
  }) : super(ClMainState()) {
    on<EstimateCleaningPriceEvent>(_estimateCleaningPrice);
    on<GetPreviousCleaningWorkersEvent>(_getPreviousCleaningWorkers);
    on<SetPreferredWorkerEvent>(_setPreferredWorker);
    on<CreateCleaningOrderEvent>(_createCleaningOrder);
    on<ResetCreateOrderStatusEvent>(_resetCreateOrderStatus);
  }

  FutureOr<void> _estimateCleaningPrice(EstimateCleaningPriceEvent event, Emitter<ClMainState> emit) async {
    debugPrint('ClMainBloc estimate request -> ${event.params.getBody()}');
    emit(state.copyWith(estimatePriceStatus: BlocStatus.loading, clearErrorMessage: true));
    final response = await estimateCleaningPriceUseCase(event.params);
    response.fold(
      (failure) {
        debugPrint('ClMainBloc estimate failed -> ${failure.message}');
        emit(
          state.copyWith(
            estimatePriceStatus: BlocStatus.failed,
            errorMessage: failure.message,
          ),
        );
      },
      (result) {
        debugPrint(
          'ClMainBloc estimate success -> '
          'basePrice=${result.pricing?.basePrice}, '
          'travelFee=${result.pricing?.travelFee}, '
          'addonsTotal=${result.pricing?.addonsTotal}, '
          'totalPrice=${result.pricing?.totalPrice}, '
          'currency=${result.pricing?.currency}',
        );
        emit(
          state.copyWith(
            estimatePriceStatus: BlocStatus.success,
            estimatePrice: result,
          ),
        );
      },
    );
  }

  FutureOr<void> _getPreviousCleaningWorkers(GetPreviousCleaningWorkersEvent event, Emitter<ClMainState> emit) async {
    emit(state.copyWith(previousWorkersStatus: BlocStatus.loading, clearErrorMessage: true));
    final response = await getPreviousCleaningWorkersUseCase(event.params);
    response.fold(
      (failure) {
        emit(
          state.copyWith(
            previousWorkersStatus: BlocStatus.failed,
            errorMessage: failure.message,
          ),
        );
      },
      (result) {
        emit(
          state.copyWith(
            previousWorkersStatus: BlocStatus.success,
            previousWorkers: result,
          ),
        );
      },
    );
  }

  FutureOr<void> _setPreferredWorker(SetPreferredWorkerEvent event, Emitter<ClMainState> emit) {
    emit(
      state.copyWith(
        selectedWorkerId: event.workerId,
        clearErrorMessage: true,
      ),
    );
  }

  FutureOr<void> _createCleaningOrder(CreateCleaningOrderEvent event, Emitter<ClMainState> emit) async {
    emit(state.copyWith(createOrderStatus: BlocStatus.loading, clearErrorMessage: true));
    final response = await createCleaningOrderUseCase(event.params);
    response.fold(
      (failure) {
        emit(
          state.copyWith(
            createOrderStatus: BlocStatus.failed,
            errorMessage: failure.message,
          ),
        );
      },
      (result) {
        emit(
          state.copyWith(
            createOrderStatus: BlocStatus.success,
            createOrderResult: result,
          ),
        );
      },
    );
  }

  FutureOr<void> _resetCreateOrderStatus(ResetCreateOrderStatusEvent event, Emitter<ClMainState> emit) {
    emit(state.copyWith(createOrderStatus: BlocStatus.init));
  }
}
