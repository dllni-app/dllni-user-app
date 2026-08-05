import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/previous_workers_response_model.dart';
import '../repository/cl_main_repo.dart';

@lazySingleton
class GetPreviousCleaningWorkersUseCase
    implements
        UseCase<
          PreviousWorkersResponseModel,
          GetPreviousCleaningWorkersParams
        > {
  final ClMainRepo clMainRepo;

  GetPreviousCleaningWorkersUseCase({required this.clMainRepo});

  @override
  DataResponse<PreviousWorkersResponseModel> call(
    GetPreviousCleaningWorkersParams params,
  ) {
    return clMainRepo.getPreviousCleaningWorkers(params);
  }
}

class GetPreviousCleaningWorkersParams with Params {
  final int page;
  final int perPage;
  final String? propertyType;
  final String? scheduledDate;
  final String? scheduledTime;
  final double? durationHours;

  GetPreviousCleaningWorkersParams({
    this.page = 1,
    this.perPage = 10,
    this.propertyType,
    this.scheduledDate,
    this.scheduledTime,
    this.durationHours,
  });

  @override
  QueryParams getParams() {
    return {
      'page': page,
      'per_page': perPage,
      if (scheduledDate != null && scheduledDate!.isNotEmpty)
        'scheduledDate': scheduledDate,
      if (scheduledTime != null && scheduledTime!.isNotEmpty)
        'scheduledTime': scheduledTime,
      if (durationHours != null && durationHours! > 0)
        'durationHours': durationHours,
    };
  }
}
