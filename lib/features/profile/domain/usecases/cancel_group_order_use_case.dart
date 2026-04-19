import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/group_order_api_models.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class CancelGroupOrderUseCase implements UseCase<GroupOrderActionModel, CancelGroupOrderParams> {
  final ProfileRepo profileRepo;

  CancelGroupOrderUseCase({required this.profileRepo});

  @override
  DataResponse<GroupOrderActionModel> call(CancelGroupOrderParams params) {
    return profileRepo.cancelGroupOrder(params);
  }
}

class CancelGroupOrderParams with Params {
  final int groupOrderId;
  final String? reason;

  CancelGroupOrderParams({required this.groupOrderId, this.reason});

  @override
  BodyMap getBody() => <String, dynamic>{
        if (reason != null && reason!.trim().isNotEmpty) 'reason': reason!.trim(),
      };
}
