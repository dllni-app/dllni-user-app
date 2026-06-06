import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/cleaning_banners_response_model.dart';
import '../repository/cl_main_repo.dart';

@lazySingleton
class GetCleaningBannersUseCase
    implements UseCase<CleaningBannersResponseModel, GetCleaningBannersParams> {
  final ClMainRepo clMainRepo;

  GetCleaningBannersUseCase({required this.clMainRepo});

  @override
  DataResponse<CleaningBannersResponseModel> call(
    GetCleaningBannersParams params,
  ) {
    return clMainRepo.getCleaningBanners(params);
  }
}

class GetCleaningBannersParams with Params {
  GetCleaningBannersParams();

  @override
  BodyMap getBody() => const {};

  @override
  QueryParams getParams() => const {};
}
