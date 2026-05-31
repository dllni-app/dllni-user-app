part of 'cl_main_bloc.dart';

class ClMainState {
  final EstimatePriceResponseModel? estimatePrice;
  final BlocStatus estimatePriceStatus;
  final List<CleaningServiceModel> cleaningServices;
  final BlocStatus cleaningServicesStatus;
  final PaginationStateModel<PreviousWorkerModel> previousWorkers;
  final int? selectedWorkerId;
  final CreateCleaningOrderResponseModel? createOrderResult;
  final BlocStatus createOrderStatus;
  final String? errorMessage;

  ClMainState({
    this.estimatePrice,
    this.estimatePriceStatus = BlocStatus.init,
    this.cleaningServices = const <CleaningServiceModel>[],
    this.cleaningServicesStatus = BlocStatus.init,
    this.previousWorkers = const PaginationStateModel<PreviousWorkerModel>(
      perPage: 10,
    ),
    this.selectedWorkerId,
    this.createOrderResult,
    this.createOrderStatus = BlocStatus.init,
    this.errorMessage,
  });

  ClMainState copyWith({
    EstimatePriceResponseModel? estimatePrice,
    BlocStatus? estimatePriceStatus,
    List<CleaningServiceModel>? cleaningServices,
    BlocStatus? cleaningServicesStatus,
    PaginationStateModel<PreviousWorkerModel>? previousWorkers,
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
      cleaningServices: cleaningServices ?? this.cleaningServices,
      cleaningServicesStatus:
          cleaningServicesStatus ?? this.cleaningServicesStatus,
      previousWorkers: previousWorkers ?? this.previousWorkers,
      selectedWorkerId: clearSelectedWorker
          ? null
          : (selectedWorkerId ?? this.selectedWorkerId),
      createOrderResult: createOrderResult ?? this.createOrderResult,
      createOrderStatus: createOrderStatus ?? this.createOrderStatus,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  BlocStatus get previousWorkersStatus => previousWorkers.status;
}
