import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/group_order_api_models.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class CreateGroupOrderUseCase implements UseCase<GroupOrderActionModel, CreateGroupOrderParams> {
  final ProfileRepo profileRepo;

  CreateGroupOrderUseCase({required this.profileRepo});

  @override
  DataResponse<GroupOrderActionModel> call(CreateGroupOrderParams params) {
    return profileRepo.createGroupOrder(params);
  }
}

class CreateGroupOrderParams with Params {
  final int restaurantId;
  final String? name;

  CreateGroupOrderParams({required this.restaurantId, this.name});

  @override
  BodyMap getBody() => <String, dynamic>{
    'restaurantId': restaurantId,
    if (name != null && name!.trim().isNotEmpty) 'name': name!.trim(),
    'durationMinutes': 30,
  };
}
