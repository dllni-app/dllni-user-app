import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/login_response_model.dart';
import '../repository/auth_repo.dart';

@lazySingleton
class FetchCurrentUserUseCase implements UseCase<CurrentUserModel, NoParams> {
  final AuthRepo authRepo;

  FetchCurrentUserUseCase({required this.authRepo});

  @override
  DataResponse<CurrentUserModel> call(NoParams params) {
    return authRepo.fetchCurrentUser();
  }
}
