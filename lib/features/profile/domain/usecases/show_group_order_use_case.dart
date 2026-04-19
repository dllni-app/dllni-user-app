import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/group_order_api_models.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class ShowGroupOrderUseCase implements UseCase<GroupOrderDetailsModel, ShowGroupOrderParams> {
  final ProfileRepo profileRepo;

  ShowGroupOrderUseCase({required this.profileRepo});

  @override
  DataResponse<GroupOrderDetailsModel> call(ShowGroupOrderParams params) {
    return profileRepo.showGroupOrder(params);
  }
}

class ShowGroupOrderParams with Params {
  final int groupOrderId;

  ShowGroupOrderParams({required this.groupOrderId});
}
