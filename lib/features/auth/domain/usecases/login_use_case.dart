import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/login_response_model.dart';
import '../repository/auth_repo.dart';
import 'login_params.dart';

@lazySingleton
class LoginUseCase implements UseCase<LoginResponseModel, LoginParams> {
  final AuthRepo authRepo;

  LoginUseCase({required this.authRepo});

  @override
  DataResponse<LoginResponseModel> call(LoginParams params) {
    return authRepo.login(params);
  }
}
