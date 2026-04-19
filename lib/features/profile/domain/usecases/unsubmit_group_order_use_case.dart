import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/group_order_api_models.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class UnsubmitGroupOrderUseCase implements UseCase<GroupOrderActionModel, UnsubmitGroupOrderParams> {
  final ProfileRepo profileRepo;

  UnsubmitGroupOrderUseCase({required this.profileRepo});

  @override
  DataResponse<GroupOrderActionModel> call(UnsubmitGroupOrderParams params) {
    return profileRepo.unsubmitGroupOrder(params);
  }
}

class UnsubmitGroupOrderParams with Params {
  final int groupOrderId;

  UnsubmitGroupOrderParams({required this.groupOrderId});
}
