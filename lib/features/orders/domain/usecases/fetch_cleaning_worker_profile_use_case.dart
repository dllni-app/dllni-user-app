import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/cleaning_worker_profile_model.dart';
import '../repository/orders_repo.dart';

@lazySingleton
class FetchCleaningWorkerProfileUseCase
    implements
        UseCase<
          FetchCleaningWorkerProfileModel,
          FetchCleaningWorkerProfileParams
        > {
  FetchCleaningWorkerProfileUseCase({required this.ordersRepo});

  final OrdersRepo ordersRepo;

  @override
  DataResponse<FetchCleaningWorkerProfileModel> call(
    FetchCleaningWorkerProfileParams params,
  ) {
    return ordersRepo.fetchCleaningWorkerProfile(params);
  }
}

class FetchCleaningWorkerProfileParams with Params {
  FetchCleaningWorkerProfileParams({required this.workerId});

  final int workerId;
}
