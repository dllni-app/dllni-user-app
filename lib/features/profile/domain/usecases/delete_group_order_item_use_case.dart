import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/group_order_api_models.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class DeleteGroupOrderItemUseCase implements UseCase<GroupOrderActionModel, DeleteGroupOrderItemParams> {
  final ProfileRepo profileRepo;

  DeleteGroupOrderItemUseCase({required this.profileRepo});

  @override
  DataResponse<GroupOrderActionModel> call(DeleteGroupOrderItemParams params) {
    return profileRepo.deleteGroupOrderItem(params);
  }
}

class DeleteGroupOrderItemParams with Params {
  final int groupOrderId;
  final int itemId;

  DeleteGroupOrderItemParams({
    required this.groupOrderId,
    required this.itemId,
  });
}
