import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/profile_api_models.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class DeleteAddressUseCase
    implements UseCase<ActionResultModel, DeleteAddressParams> {
  final ProfileRepo profileRepo;

  DeleteAddressUseCase({required this.profileRepo});

  @override
  DataResponse<ActionResultModel> call(DeleteAddressParams params) {
    return profileRepo.deleteAddress(params);
  }
}

class DeleteAddressParams with Params {
  final int addressId;

  DeleteAddressParams({required this.addressId});

  @override
  BodyMap getBody() => {};
}
