import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/profile_api_models.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class SetDefaultAddressUseCase implements UseCase<ActionResultModel, SetDefaultAddressParams> {
  final ProfileRepo rsProfileRepo;

  SetDefaultAddressUseCase({required this.rsProfileRepo});

  @override
  DataResponse<ActionResultModel> call(SetDefaultAddressParams params) {
    return rsProfileRepo.setDefaultAddress(params);
  }
}

class SetDefaultAddressParams with Params {
  final int addressId;

  SetDefaultAddressParams({required this.addressId});

  @override
  BodyMap getBody() => {};
}
