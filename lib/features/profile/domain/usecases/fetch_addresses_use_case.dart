import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/profile_api_models.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class FetchAddressesUseCase
    implements UseCase<FetchAddressesModel, FetchAddressesParams> {
  final ProfileRepo profileRepo;

  FetchAddressesUseCase({required this.profileRepo});

  @override
  DataResponse<FetchAddressesModel> call(FetchAddressesParams params) {
    return profileRepo.fetchAddresses(params);
  }
}

class FetchAddressesParams with Params {}
