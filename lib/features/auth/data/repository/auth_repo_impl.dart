import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';
import 'package:common_package/helpers/typedef.dart';

import '../../domain/repository/auth_repo.dart';
import '../../domain/usecases/login_params.dart';
import '../../domain/usecases/register_params.dart';
import '../models/login_response_model.dart';
import '../models/register_response_model.dart';
import '../source/auth_remote_data_source.dart';

@LazySingleton(as: AuthRepo)
class AuthRepoImpl with HandlingException implements AuthRepo {
  final AuthRemoteDataSource authRemoteDataSource;

  AuthRepoImpl({required this.authRemoteDataSource});

  @override
  DataResponse<LoginResponseModel> login(LoginParams params) {
    return wrapHandlingException(
      tryCall: () => authRemoteDataSource.login(params),
    );
  }

  @override
  DataResponse<RegisterResponseModel> register(RegisterParams params) {
    return wrapHandlingException(
      tryCall: () => authRemoteDataSource.register(params),
    );
  }
}
