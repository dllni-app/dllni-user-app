import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/profile_api_models.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class UpdateAccountPasswordUseCase
    implements UseCase<ActionResultModel, UpdateAccountPasswordParams> {
  final ProfileRepo profileRepo;

  UpdateAccountPasswordUseCase({required this.profileRepo});

  @override
  DataResponse<ActionResultModel> call(UpdateAccountPasswordParams params) {
    return profileRepo.updateAccountPassword(params);
  }
}

class UpdateAccountPasswordParams with Params {
  final String currentPassword;
  final String newPassword;
  final String newPasswordConfirmation;

  UpdateAccountPasswordParams({
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });

  @override
  BodyMap getBody() => <String, dynamic>{
    'currentPassword': currentPassword,
    'newPassword': newPassword,
    'newPasswordConfirmation': newPasswordConfirmation,
  };
}
