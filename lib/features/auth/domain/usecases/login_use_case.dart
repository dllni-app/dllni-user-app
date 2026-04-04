import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/login_model.dart';
import '../repository/auth_repo.dart';

@lazySingleton
class LoginUseCase implements UseCase<LoginModel, LoginParams> {
  final AuthRepo auth;

  LoginUseCase({required this.auth});

  @override
  DataResponse<LoginModel> call(LoginParams params) {
    return auth.login(params);
  }
}

class LoginParams with Params {
  final String phone;
  final String password;

  LoginParams({required this.phone, required this.password});

  @override
  BodyMap getBody() => {'phone': phone, 'password': password};
}
