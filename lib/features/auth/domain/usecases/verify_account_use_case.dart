import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/login_response_model.dart';
import '../repository/auth_repo.dart';
import 'verify_account_params.dart';

@lazySingleton
class VerifyAccountUseCase
    implements UseCase<LoginResponseModel, VerifyAccountParams> {
  final AuthRepo authRepo;

  VerifyAccountUseCase({required this.authRepo});

  @override
  DataResponse<LoginResponseModel> call(VerifyAccountParams params) {
    return authRepo.verifyAccount(params);
  }
}
