import 'package:common_package/helpers/typedef.dart';
import '../usecases/login_use_case.dart';
import '../../data/models/login_model.dart';
abstract class AuthRepo {
  DataResponse<LoginModel> login(LoginParams params);
}
