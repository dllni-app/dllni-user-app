import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/group_order_api_models.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class SubmitGroupOrderUseCase implements UseCase<GroupOrderActionModel, SubmitGroupOrderParams> {
  final ProfileRepo profileRepo;

  SubmitGroupOrderUseCase({required this.profileRepo});

  @override
  DataResponse<GroupOrderActionModel> call(SubmitGroupOrderParams params) {
    return profileRepo.submitGroupOrder(params);
  }
}

class SubmitGroupOrderParams with Params {
  final int groupOrderId;

  SubmitGroupOrderParams({required this.groupOrderId});
}
