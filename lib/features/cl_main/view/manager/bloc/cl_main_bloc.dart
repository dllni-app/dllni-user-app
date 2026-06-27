import 'dart:async';

import 'package:common_package/helpers/pagination_helper.dart';
import 'package:common_package/helpers/droppable_helper.dart';
import 'package:dllni_user_app/core/models/cleaning_gender_preference.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/create_cleaning_order_use_case.dart';
import '../../../domain/usecases/estimate_cleaning_price_use_case.dart';
import '../../../domain/usecases/get_cleaning_services_use_case.dart';
import '../../../domain/usecases/get_previous_cleaning_workers_use_case.dart';
import '../../../domain/models/cleaning_assignment_mode.dart';
import '../../../domain/models/work_environment_confirmation.dart';
import '../../../data/models/cleaning_services_response_model.dart';
import '../../../data/models/create_cleaning_order_response_model.dart';
import '../../../data/models/previous_workers_response_model.dart';
import '../../helpers/cl_previous_workers_gender_filter.dart';
import '../../helpers/cl_worker_room_assignment_errors.dart';

part 'cl_main_event.dart';
part 'cl_main_state.dart';

@injectable
class ClMainBloc extends Bloc<ClMainEvent, ClMainState> {
  final EstimateCleaningPriceUseCase estimateCleaningPriceUseCase;
  final GetCleaningServicesUseCase getCleaningServicesUseCase;
  final GetPreviousCleaningWorkersUseCase getPreviousCleaningWorkersUseCase;
  final CreateCleaningOrderUseCase createCleaningOrderUseCase;

  ClMainBloc({
    required this.estimateCleaningPriceUseCase,
    required this.getCleaningServicesUseCase,
    required this.getPreviousCleaningWorkersUseCase,
    required this.createCleaningOrderUseCase,
  }) : super(ClMainState()) {
    on<EstimateCleaningPriceEvent>(_estimateCleaningPrice);
    on<GetCleaningServicesEvent>(_getCleaningServices);
    on<GetPreviousCleaningWorkersEvent>(
      _getPreviousCleaningWorkers,
      transformer: paginationEventTransformer(),
    );
    on<SetPreferredWorkerEvent>(_setPreferredWorker);
    on<SetPreferredWorkersEvent>(_setPreferredWorkers);
    on<AddPreferredWorkerEvent>(_addPreferredWorker);
    on<UpdatePreferredWorkersEvent>(_updatePreferredWorkers);
    on<RemovePreferredWorkerEvent>(_removePreferredWorker);
    on<TogglePreferredWorkerEvent>(_togglePreferredWorker);
    on<ClearPreferredWorkersEvent>(_clearPreferredWorkers);
    on<SetGenderPreferenceEvent>(_setGenderPreference);
    on<SetAssignmentModeEvent>(_setAssignmentMode);
    on<SetNumberOfWorkersEvent>(_setNumberOfWorkers);
    on<SetWorkerRoomSlotEvent>(_setWorkerRoomSlot);
    on<ClearWorkerRoomAssignmentsEvent>(_clearWorkerRoomAssignments);
    on<CreateCleaningOrderEvent>(_createCleaningOrder);
    on<ResetCreateOrderStatusEvent>(_resetCreateOrderStatus);
  }

  FutureOr<void> _getCleaningServices(
    GetCleaningServicesEvent event,
    Emitter<ClMainState> emit,
  ) async {
    emit(
      state.copyWith(
        cleaningServicesStatus: BlocStatus.loading,
        clearErrorMessage: true,
      ),
    );
    final response = await getCleaningServicesUseCase(event.params);
    response.fold(
      (failure) {
        emit(
          state.copyWith(
            cleaningServicesStatus: BlocStatus.failed,
            errorMessage: failure.message,
          ),
        );
      },
      (result) {
        emit(
          state.copyWith(
            cleaningServicesStatus: BlocStatus.success,
            cleaningServices: result.data,
            clearErrorMessage: true,
          ),
        );
      },
    );
  }

  FutureOr<void> _estimateCleaningPrice(
    EstimateCleaningPriceEvent event,
    Emitter<ClMainState> emit,
  ) async {
    debugPrint('ClMainBloc estimate request -> ${event.params.getBody()}');
    emit(
      state.copyWith(
        estimatePriceStatus: BlocStatus.loading,
        clearErrorMessage: true,
        clearAssignmentFieldErrors: true,
      ),
    );
    final response = await estimateCleaningPriceUseCase(event.params);
    response.fold(
      (failure) {
        debugPrint('ClMainBloc estimate failed -> ${failure.message}');
        emit(
          state.copyWith(
            estimatePriceStatus: BlocStatus.failed,
            errorMessage: failure.message,
            assignmentFieldErrors: filterWorkerRoomAssignmentFieldErrors(
              failure,
            ),
            clearAssignmentFieldErrors: filterWorkerRoomAssignmentFieldErrors(
              failure,
            ).isEmpty,
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
          'currency=${result.pricing?.currency}, '
          'workerRoomAssignments=${result.workerRoomAssignments.length}',
        );
        emit(
          state.copyWith(
            estimatePriceStatus: BlocStatus.success,
            estimatePrice: result,
            clearAssignmentFieldErrors: true,
          ),
        );
      },
    );
  }

  FutureOr<void> _getPreviousCleaningWorkers(
    GetPreviousCleaningWorkersEvent event,
    Emitter<ClMainState> emit,
  ) async {
    final pagination = state.previousWorkers;
    final isLoadMore = event.loadMore && !event.isReload;
    if (isLoadMore && pagination.isEndPage) return;

    final shouldResetList = event.isReload || !isLoadMore;
    emit(
      state.copyWith(
        previousWorkers: pagination.setLoading(isReload: shouldResetList),
        clearErrorMessage: true,
      ),
    );

    final page = isLoadMore ? pagination.pageNumber : 1;
    final perPage = pagination.perPage;
    final response = await getPreviousCleaningWorkersUseCase(
      GetPreviousCleaningWorkersParams(
        page: page,
        perPage: perPage,
        propertyType: event.params.propertyType,
      ),
    );
    response.fold(
      (failure) {
        emit(
          state.copyWith(
            previousWorkers: state.previousWorkers.setFaild(
              errorMessage: failure.message,
            ),
            errorMessage: failure.message,
          ),
        );
      },
      (result) {
        final workers = result.data ?? const <PreviousWorkerModel>[];
        emit(
          state.copyWith(
            previousWorkers: state.previousWorkers.setSuccess(
              data: workers,
              total: result.meta?.total ?? state.previousWorkers.total,
              perPage: result.meta?.perPage ?? perPage,
            ),
          ),
        );
      },
    );
  }

  List<int> _normalizeWorkerIds(List<int> ids) {
    final normalized = <int>[];
    for (final id in ids) {
      if (id <= 0 || normalized.contains(id)) continue;
      normalized.add(id);
    }
    return normalized;
  }

  ClMainState _stateWithPreferredWorkers(List<int> ids) {
    final normalized = _normalizeWorkerIds(ids);

    return state.copyWith(
      selectedWorkerIds: normalized,
      assignmentMode: normalized.isEmpty
          ? state.assignmentMode
          : CleaningAssignmentMode.preferredWorker,
      clearErrorMessage: true,
      clearAssignmentFieldErrors: true,
    );
  }

  FutureOr<void> _setPreferredWorker(
    SetPreferredWorkerEvent event,
    Emitter<ClMainState> emit,
  ) {
    if (event.workerId == null) {
      emit(
        state.copyWith(
          clearSelectedWorkers: true,
          clearErrorMessage: true,
          clearAssignmentFieldErrors: true,
        ),
      );
      return;
    }

    final updated = List<int>.from(state.selectedWorkerIds);
    if (updated.contains(event.workerId)) {
      updated.remove(event.workerId);
    } else {
      updated.add(event.workerId!);
    }

    emit(_stateWithPreferredWorkers(updated));
  }

  FutureOr<void> _setPreferredWorkers(
    SetPreferredWorkersEvent event,
    Emitter<ClMainState> emit,
  ) {
    emit(_stateWithPreferredWorkers(event.workerIds));
  }

  FutureOr<void> _addPreferredWorker(
    AddPreferredWorkerEvent event,
    Emitter<ClMainState> emit,
  ) {
    emit(_stateWithPreferredWorkers(<int>[
      ...state.selectedWorkerIds,
      event.workerId,
    ]));
  }

  FutureOr<void> _updatePreferredWorkers(
    UpdatePreferredWorkersEvent event,
    Emitter<ClMainState> emit,
  ) {
    emit(_stateWithPreferredWorkers(event.workerIds));
  }

  FutureOr<void> _removePreferredWorker(
    RemovePreferredWorkerEvent event,
    Emitter<ClMainState> emit,
  ) {
    emit(
      _stateWithPreferredWorkers(
        state.selectedWorkerIds.where((id) => id != event.workerId).toList(),
      ),
    );
  }

  FutureOr<void> _togglePreferredWorker(
    TogglePreferredWorkerEvent event,
    Emitter<ClMainState> emit,
  ) {
    final updated = List<int>.from(state.selectedWorkerIds);
    if (updated.contains(event.workerId)) {
      updated.remove(event.workerId);
    } else {
      updated.add(event.workerId);
    }
    emit(_stateWithPreferredWorkers(updated));
  }

  FutureOr<void> _clearPreferredWorkers(
    ClearPreferredWorkersEvent event,
    Emitter<ClMainState> emit,
  ) {
    emit(
      state.copyWith(
        clearSelectedWorkers: true,
        clearErrorMessage: true,
        clearAssignmentFieldErrors: true,
      ),
    );
  }

  FutureOr<void> _setGenderPreference(
    SetGenderPreferenceEvent event,
    Emitter<ClMainState> emit,
  ) {
    final filteredWorkerIds = event.preference == CleaningGenderPreference.any
        ? state.selectedWorkerIds
        : state.selectedWorkerIds.where((workerId) {
            PreviousWorkerModel? selectedWorker;
            for (final worker in state.previousWorkers.list) {
              if (worker.id == workerId) {
                selectedWorker = worker;
                break;
              }
            }
            return selectedWorker == null ||
                selectedWorker.matchesGenderPreference(event.preference);
          }).toList(growable: false);
    final requiresSafetyConfirmation =
        event.preference == CleaningGenderPreference.female;

    emit(
      state.copyWith(
        genderPreference: event.preference,
        safetyConfirmation: requiresSafetyConfirmation
            ? event.workEnvironmentConfirmation
            : null,
        clearSafetyConfirmation:
            !requiresSafetyConfirmation || event.workEnvironmentConfirmation == null,
        selectedWorkerIds: filteredWorkerIds,
        clearErrorMessage: true,
      ),
    );
  }

  Map<String, int> _clampWorkerRoomAssignments(
    Map<String, int> assignments,
    int maxWorkers,
  ) {
    if (maxWorkers < 1 || assignments.isEmpty) return const {};
    return Map<String, int>.fromEntries(
      assignments.entries.where((entry) => entry.value <= maxWorkers),
    );
  }

  FutureOr<void> _setAssignmentMode(
    SetAssignmentModeEvent event,
    Emitter<ClMainState> emit,
  ) {
    if (event.mode == CleaningAssignmentMode.openCount) {
      final safeCount = state.numberOfWorkers < 1 ? 1 : state.numberOfWorkers;
      emit(
        state.copyWith(
          assignmentMode: event.mode,
          clearSelectedWorkers: true,
          numberOfWorkers: safeCount,
          workerRoomAssignments: _clampWorkerRoomAssignments(
            state.workerRoomAssignments,
            safeCount,
          ),
          clearErrorMessage: true,
          clearAssignmentFieldErrors: true,
        ),
      );
    } else {
      emit(
        state.copyWith(
          assignmentMode: event.mode,
          clearWorkerRoomAssignments: true,
          clearErrorMessage: true,
          clearAssignmentFieldErrors: true,
        ),
      );
    }
  }

  FutureOr<void> _setNumberOfWorkers(
    SetNumberOfWorkersEvent event,
    Emitter<ClMainState> emit,
  ) {
    final safeCount = event.count < 1 ? 1 : event.count;
    emit(
      state.copyWith(
        numberOfWorkers: safeCount,
        assignmentMode: CleaningAssignmentMode.openCount,
        clearSelectedWorkers: true,
        workerRoomAssignments: _clampWorkerRoomAssignments(
          state.workerRoomAssignments,
          safeCount,
        ),
        clearErrorMessage: true,
        clearAssignmentFieldErrors: true,
      ),
    );
  }

  FutureOr<void> _setWorkerRoomSlot(
    SetWorkerRoomSlotEvent event,
    Emitter<ClMainState> emit,
  ) {
    final updated = Map<String, int>.from(state.workerRoomAssignments);
    if (event.workerSlot < 1) {
      updated.remove(event.roomKey);
    } else {
      updated[event.roomKey] = event.workerSlot;
    }
    emit(
      state.copyWith(
        workerRoomAssignments: updated,
        clearErrorMessage: true,
        clearAssignmentFieldErrors: true,
      ),
    );
  }

  FutureOr<void> _clearWorkerRoomAssignments(
    ClearWorkerRoomAssignmentsEvent event,
    Emitter<ClMainState> emit,
  ) {
    emit(
      state.copyWith(
        clearWorkerRoomAssignments: true,
        clearErrorMessage: true,
        clearAssignmentFieldErrors: true,
      ),
    );
  }

  FutureOr<void> _createCleaningOrder(
    CreateCleaningOrderEvent event,
    Emitter<ClMainState> emit,
  ) async {
    emit(
      state.copyWith(
        createOrderStatus: BlocStatus.loading,
        clearErrorMessage: true,
        clearAssignmentFieldErrors: true,
      ),
    );
    final response = await createCleaningOrderUseCase(event.params);
    response.fold(
      (failure) {
        final assignmentErrors = filterWorkerRoomAssignmentFieldErrors(failure);
        emit(
          state.copyWith(
            createOrderStatus: BlocStatus.failed,
            errorMessage: failureMessageWithFieldErrors(
              failure,
              fallback: 'فشل تنفيذ الطلب',
            ),
            assignmentFieldErrors: assignmentErrors,
            clearAssignmentFieldErrors: assignmentErrors.isEmpty,
          ),
        );
      },
      (result) {
        emit(
          state.copyWith(
            createOrderStatus: BlocStatus.success,
            createOrderResult: result,
            clearAssignmentFieldErrors: true,
          ),
        );
      },
    );
  }

  FutureOr<void> _resetCreateOrderStatus(
    ResetCreateOrderStatusEvent event,
    Emitter<ClMainState> emit,
  ) {
    emit(state.copyWith(createOrderStatus: BlocStatus.init));
  }
}
