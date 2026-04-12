import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/register_response_model.dart';
import '../repository/auth_repo.dart';
import 'register_params.dart';

@lazySingleton
class RegisterUseCase implements UseCase<RegisterResponseModel, RegisterParams> {
  final AuthRepo authRepo;

  RegisterUseCase({required this.authRepo});

  @override
  DataResponse<RegisterResponseModel> call(RegisterParams params) {
    return authRepo.register(params);
  }
}
