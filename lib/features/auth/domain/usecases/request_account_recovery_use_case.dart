import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/auth_action_response_model.dart';
import '../repository/auth_repo.dart';
import 'auth_phone_params.dart';

// @lazySingleton
// class RequestAccountRecoveryUseCase implements UseCase<AuthActionResponseModel, AuthPhoneParams> {
//   final AuthRepo authRepo;

//   RequestAccountRecoveryUseCase({required this.authRepo});

//   @override
//   DataResponse<AuthActionResponseModel> call(AuthPhoneParams params) {
//     return authRepo.requestAccountRecovery(params);
//   }
// }
