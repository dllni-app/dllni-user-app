import 'package:common_package/helpers/typedef.dart';

import '../../data/models/auth_action_response_model.dart';
import '../../data/models/login_response_model.dart';
import '../../data/models/register_response_model.dart';
import '../usecases/auth_phone_params.dart';
import '../usecases/login_params.dart';
import '../usecases/register_params.dart';
import '../usecases/verify_account_params.dart';

abstract class AuthRepo {
  DataResponse<LoginResponseModel> login(LoginParams params);

  DataResponse<RegisterResponseModel> register(RegisterParams params);

  DataResponse<LoginResponseModel> verifyAccount(VerifyAccountParams params);

  DataResponse<AuthActionResponseModel> resendAccountCode(AuthPhoneParams params);
}
