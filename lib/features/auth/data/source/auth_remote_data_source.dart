import 'package:common_package/helpers/dio_network.dart';
import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/api_handler.dart';
import '../models/login_model.dart';
import '../../domain/usecases/login_use_case.dart';

@lazySingleton
class AuthRemoteDataSource with HandlingApiManager {
  final DioNetwork dioNetwork;

  AuthRemoteDataSource({required this.dioNetwork});

  Future<LoginModel> login(LoginParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(endPoint: '/api/login', data: params.getBody(), params: params.getParams()),
      jsonConvert: loginModelFromJson,
    );
  }}