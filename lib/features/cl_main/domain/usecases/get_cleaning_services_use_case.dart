import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/cleaning_services_response_model.dart';
import '../repository/cl_main_repo.dart';

@lazySingleton
class GetCleaningServicesUseCase
    implements
        UseCase<CleaningServicesResponseModel, GetCleaningServicesParams> {
  final ClMainRepo clMainRepo;

  GetCleaningServicesUseCase({required this.clMainRepo});

  @override
  DataResponse<CleaningServicesResponseModel> call(
    GetCleaningServicesParams params,
  ) {
    return clMainRepo.getCleaningServices(params);
  }
}

class GetCleaningServicesParams with Params {
  final String category;
  final bool activeOnly;

  GetCleaningServicesParams({required this.category, this.activeOnly = true});

  @override
  BodyMap getBody() => const {};

  @override
  QueryParams getParams() {
    return {
      'filter[category]': category,
      if (activeOnly) 'filter[isActive]': 1,
    };
  }
}
