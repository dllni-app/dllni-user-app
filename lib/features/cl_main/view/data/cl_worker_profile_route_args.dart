import '../../data/models/previous_workers_response_model.dart';

class WorkerProfileRouteArgs {
  const WorkerProfileRouteArgs({required this.workerId, this.worker});

  final String workerId;
  final PreviousWorkerModel? worker;

  factory WorkerProfileRouteArgs.fromPreviousWorker(
    PreviousWorkerModel worker,
  ) {
    return WorkerProfileRouteArgs(
      workerId: worker.id?.toString() ?? '',
      worker: worker,
    );
  }
}
