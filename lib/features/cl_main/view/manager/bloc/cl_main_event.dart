part of 'cl_main_bloc.dart';

abstract class ClMainEvent {}

class EstimateCleaningPriceEvent extends ClMainEvent {
  final EstimateCleaningPriceParams params;

  EstimateCleaningPriceEvent({required this.params});
}

class GetPreviousCleaningWorkersEvent extends ClMainEvent {
  final GetPreviousCleaningWorkersParams params;

  GetPreviousCleaningWorkersEvent({required this.params});
}

class SetPreferredWorkerEvent extends ClMainEvent {
  final int? workerId;

  SetPreferredWorkerEvent({required this.workerId});
}

class CreateCleaningOrderEvent extends ClMainEvent {
  final CreateCleaningOrderParams params;

  CreateCleaningOrderEvent({required this.params});
}

class ResetCreateOrderStatusEvent extends ClMainEvent {}
