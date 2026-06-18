import 'package:common_package/common_package.dart';
import 'package:injectable/injectable.dart';

import '../models/login_response_model.dart';
import '../models/register_response_model.dart';
import '../../domain/usecases/login_params.dart';
import '../../domain/usecases/register_params.dart';
import '../../domain/usecases/verify_account_params.dart';

@lazySingleton
class AuthRemoteDataSource with HandlingApiManager {
  final DioNetwork dioNetwork;

  AuthRemoteDataSource({required this.dioNetwork});

  Future<LoginResponseModel> login(LoginParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/login',
        data: params.getBody(),
      ),
      jsonConvert: loginResponseModelFromJson,
    );
  }

  Future<RegisterResponseModel> register(RegisterParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/register',
        data: params.getBody(),
      ),
      jsonConvert: registerResponseModelFromJson,
    );
  }

  Future<LoginResponseModel> verifyAccount(VerifyAccountParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/verify-account',
        data: params.getBody(),
      ),
      jsonConvert: loginResponseModelFromJson,
    );
  }
}
