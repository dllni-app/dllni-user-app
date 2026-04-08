import 'package:common_package/helpers/typedef.dart';

import '../../data/models/login_response_model.dart';
import '../usecases/login_params.dart';

abstract class AuthRepo {
  DataResponse<LoginResponseModel> login(LoginParams params);
}
