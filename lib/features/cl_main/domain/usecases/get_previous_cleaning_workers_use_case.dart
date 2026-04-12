import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/previous_workers_response_model.dart';
import '../repository/cl_main_repo.dart';

@lazySingleton
class GetPreviousCleaningWorkersUseCase implements UseCase<PreviousWorkersResponseModel, GetPreviousCleaningWorkersParams> {
  final ClMainRepo clMainRepo;

  GetPreviousCleaningWorkersUseCase({required this.clMainRepo});

  @override
  DataResponse<PreviousWorkersResponseModel> call(GetPreviousCleaningWorkersParams params) {
    return clMainRepo.getPreviousCleaningWorkers(params);
  }
}

class GetPreviousCleaningWorkersParams with Params {
  final int page;

  GetPreviousCleaningWorkersParams({this.page = 1});

  @override
  QueryParams getParams() {
    return {'page': page};
  }
}
