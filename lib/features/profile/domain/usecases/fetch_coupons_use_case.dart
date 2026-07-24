import 'package:common_package/common_package.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/injection.dart';
import '../../data/models/profile_api_models.dart';
import '../../data/source/platform_coupon_remote_data_source_extension.dart';
import '../../data/source/profile_remote_data_source.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class FetchCouponsUseCase with HandlingException implements UseCase<FetchCouponsModel, NoParams> {
  final ProfileRepo profileRepo;

  FetchCouponsUseCase({required this.profileRepo});

  @override
  DataResponse<FetchCouponsModel> call(NoParams params) {
    return wrapHandlingException(
      tryCall: () => getIt<ProfileRemoteDataSource>().fetchPlatformCoupons(params),
    );
  }
}
