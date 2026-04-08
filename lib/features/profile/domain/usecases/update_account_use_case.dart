import 'dart:io';

import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/profile_api_models.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class UpdateAccountUseCase
    implements UseCase<UpdateAccountModel, UpdateAccountParams> {
  final ProfileRepo profileRepo;

  UpdateAccountUseCase({required this.profileRepo});

  @override
  DataResponse<UpdateAccountModel> call(UpdateAccountParams params) {
    return profileRepo.updateAccount(params);
  }
}

class UpdateAccountParams with Params {
  final String name;
  final String phone;
  final File? primaryImage;

  UpdateAccountParams({
    required this.name,
    required this.phone,
    this.primaryImage,
  });

  @override
  BodyMap getBody() => <String, dynamic>{
    'name': name,
    'phone': phone,
    if (primaryImage != null) 'primaryImage': primaryImage,
  };
}
