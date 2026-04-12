part of 'cl_main_bloc.dart';

class ClMainState {
  final EstimatePriceResponseModel? estimatePrice;
  final BlocStatus estimatePriceStatus;
  final PreviousWorkersResponseModel? previousWorkers;
  final BlocStatus previousWorkersStatus;
  final int? selectedWorkerId;
  final CreateCleaningOrderResponseModel? createOrderResult;
  final BlocStatus createOrderStatus;
  final String? errorMessage;

  ClMainState({
    this.estimatePrice,
    this.estimatePriceStatus = BlocStatus.init,
    this.previousWorkers,
    this.previousWorkersStatus = BlocStatus.init,
    this.selectedWorkerId,
    this.createOrderResult,
    this.createOrderStatus = BlocStatus.init,
    this.errorMessage,
  });

  ClMainState copyWith({
    EstimatePriceResponseModel? estimatePrice,
    BlocStatus? estimatePriceStatus,
    PreviousWorkersResponseModel? previousWorkers,
    BlocStatus? previousWorkersStatus,
    int? selectedWorkerId,
    bool clearSelectedWorker = false,
    CreateCleaningOrderResponseModel? createOrderResult,
    BlocStatus? createOrderStatus,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ClMainState(
      estimatePrice: estimatePrice ?? this.estimatePrice,
      estimatePriceStatus: estimatePriceStatus ?? this.estimatePriceStatus,
      previousWorkers: previousWorkers ?? this.previousWorkers,
      previousWorkersStatus: previousWorkersStatus ?? this.previousWorkersStatus,
      selectedWorkerId: clearSelectedWorker ? null : (selectedWorkerId ?? this.selectedWorkerId),
      createOrderResult: createOrderResult ?? this.createOrderResult,
      createOrderStatus: createOrderStatus ?? this.createOrderStatus,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
