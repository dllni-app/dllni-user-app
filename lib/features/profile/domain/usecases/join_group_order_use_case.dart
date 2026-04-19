import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/group_order_api_models.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class JoinGroupOrderUseCase implements UseCase<GroupOrderActionModel, JoinGroupOrderParams> {
  final ProfileRepo profileRepo;

  JoinGroupOrderUseCase({required this.profileRepo});

  @override
  DataResponse<GroupOrderActionModel> call(JoinGroupOrderParams params) {
    return profileRepo.joinGroupOrder(params);
  }
}

class JoinGroupOrderParams with Params {
  final String shareToken;

  JoinGroupOrderParams({required this.shareToken});

  @override
  BodyMap getBody() => <String, dynamic>{'shareToken': shareToken};
}
