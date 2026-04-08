import 'package:common_package/common_package.dart';
import 'package:injectable/injectable.dart';

import '../models/login_response_model.dart';
import '../../domain/usecases/login_params.dart';

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
}
