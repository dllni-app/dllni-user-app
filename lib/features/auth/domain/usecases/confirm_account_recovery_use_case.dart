import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/auth_action_response_model.dart';
import '../repository/auth_repo.dart';
import 'auth_phone_params.dart';

// @lazySingleton
// class ConfirmAccountRecoveryUseCase implements UseCase<AuthActionResponseModel, ResetPasswordConfirmParams> {
//   final AuthRepo authRepo;

//   ConfirmAccountRecoveryUseCase({required this.authRepo});

//   @override
//   DataResponse<AuthActionResponseModel> call(ResetPasswordConfirmParams params) {
//     return authRepo.confirmAccountRecovery(params);
//   }
// }
