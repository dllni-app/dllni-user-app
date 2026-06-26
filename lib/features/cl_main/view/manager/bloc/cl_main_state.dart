part of 'cl_main_bloc.dart';

class ClMainState {
  final EstimatePriceResponseModel? estimatePrice;
  final BlocStatus estimatePriceStatus;
  final List<CleaningServiceModel> cleaningServices;
  final BlocStatus cleaningServicesStatus;
  final PaginationStateModel<PreviousWorkerModel> previousWorkers;
  final List<int> selectedWorkerIds;
  final CleaningGenderPreference genderPreference;
  final WorkEnvironmentConfirmation? safetyConfirmation;
  final CleaningAssignmentMode assignmentMode;
  final int numberOfWorkers;
  final Map<String, int> workerRoomAssignments;
  final Map<String, List<String>> assignmentFieldErrors;
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
    this.selectedWorkerIds = const <int>[],
    this.genderPreference = CleaningGenderPreference.any,
    this.safetyConfirmation,
    this.assignmentMode = CleaningAssignmentMode.preferredWorker,
    this.numberOfWorkers = 1,
    this.workerRoomAssignments = const <String, int>{},
    this.assignmentFieldErrors = const <String, List<String>>{},
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
    List<int>? selectedWorkerIds,
    bool clearSelectedWorkers = false,
    CleaningGenderPreference? genderPreference,
    WorkEnvironmentConfirmation? safetyConfirmation,
    bool clearSafetyConfirmation = false,
    CleaningAssignmentMode? assignmentMode,
    int? numberOfWorkers,
    Map<String, int>? workerRoomAssignments,
    bool clearWorkerRoomAssignments = false,
    Map<String, List<String>>? assignmentFieldErrors,
    bool clearAssignmentFieldErrors = false,
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
      selectedWorkerIds: clearSelectedWorkers
          ? const <int>[]
          : (selectedWorkerIds ?? this.selectedWorkerIds),
      genderPreference: genderPreference ?? this.genderPreference,
      safetyConfirmation: clearSafetyConfirmation
          ? null
          : (safetyConfirmation ?? this.safetyConfirmation),
      assignmentMode: assignmentMode ?? this.assignmentMode,
      numberOfWorkers: numberOfWorkers ?? this.numberOfWorkers,
      workerRoomAssignments: clearWorkerRoomAssignments
          ? const <String, int>{}
          : (workerRoomAssignments ?? this.workerRoomAssignments),
      assignmentFieldErrors: clearAssignmentFieldErrors
          ? const <String, List<String>>{}
          : (assignmentFieldErrors ?? this.assignmentFieldErrors),
      createOrderResult: createOrderResult ?? this.createOrderResult,
      createOrderStatus: createOrderStatus ?? this.createOrderStatus,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  BlocStatus get previousWorkersStatus => previousWorkers.status;

  int? get primarySelectedWorkerId =>
      selectedWorkerIds.isEmpty ? null : selectedWorkerIds.first;
}
