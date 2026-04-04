import 'package:common_package/helpers/typedef.dart';

import '../../data/models/login_model.dart';
import '../usecases/login_use_case.dart';

abstract class AuthRepo {
  DataResponse<LoginModel> login(LoginParams params);
}
