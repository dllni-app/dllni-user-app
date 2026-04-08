import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/profile_api_models.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class FetchCouponsUseCase implements UseCase<FetchCouponsModel, NoParams> {
  final ProfileRepo profileRepo;

  FetchCouponsUseCase({required this.profileRepo});

  @override
  DataResponse<FetchCouponsModel> call(NoParams params) {
    return profileRepo.fetchCoupons(params);
  }
}
