import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/rs_profile_api_models.dart';
import '../repository/rs_profile_repo.dart';

@lazySingleton
class FetchAddressesUseCase
    implements UseCase<FetchAddressesModel, FetchAddressesParams> {
  final RsProfileRepo rsProfileRepo;

  FetchAddressesUseCase({required this.rsProfileRepo});

  @override
  DataResponse<FetchAddressesModel> call(FetchAddressesParams params) {
    return rsProfileRepo.fetchAddresses(params);
  }
}

class FetchAddressesParams with Params {}
