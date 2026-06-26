part of 'cl_main_bloc.dart';

abstract class ClMainEvent {}

class EstimateCleaningPriceEvent extends ClMainEvent {
  final EstimateCleaningPriceParams params;

  EstimateCleaningPriceEvent({required this.params});
}

class GetCleaningServicesEvent extends ClMainEvent {
  final GetCleaningServicesParams params;

  GetCleaningServicesEvent({required this.params});
}

class GetPreviousCleaningWorkersEvent extends ClMainEvent with EventWithReload {
  final GetPreviousCleaningWorkersParams params;
  final bool loadMore;
  @override
  final bool isReload;

  GetPreviousCleaningWorkersEvent({
    required this.params,
    this.loadMore = false,
    this.isReload = false,
  });
}

class SetPreferredWorkerEvent extends ClMainEvent {
  final int? workerId;

  SetPreferredWorkerEvent({required this.workerId});
}

class SetGenderPreferenceEvent extends ClMainEvent {
  final CleaningGenderPreference preference;
  final WorkEnvironmentConfirmation? workEnvironmentConfirmation;

  SetGenderPreferenceEvent({
    required this.preference,
    this.workEnvironmentConfirmation,
  });
}

class SetAssignmentModeEvent extends ClMainEvent {
  final CleaningAssignmentMode mode;

  SetAssignmentModeEvent({required this.mode});
}

class SetNumberOfWorkersEvent extends ClMainEvent {
  final int count;

  SetNumberOfWorkersEvent({required this.count});
}

class SetWorkerRoomSlotEvent extends ClMainEvent {
  final String roomKey;
  final int workerSlot;

  SetWorkerRoomSlotEvent({required this.roomKey, required this.workerSlot});
}

class ClearWorkerRoomAssignmentsEvent extends ClMainEvent {}

class CreateCleaningOrderEvent extends ClMainEvent {
  final CreateCleaningOrderParams params;

  CreateCleaningOrderEvent({required this.params});
}

class ResetCreateOrderStatusEvent extends ClMainEvent {}
