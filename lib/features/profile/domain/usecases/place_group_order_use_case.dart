import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/group_order_api_models.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class PlaceGroupOrderUseCase implements UseCase<GroupOrderActionModel, PlaceGroupOrderParams> {
  final ProfileRepo profileRepo;

  PlaceGroupOrderUseCase({required this.profileRepo});

  @override
  DataResponse<GroupOrderActionModel> call(PlaceGroupOrderParams params) {
    return profileRepo.placeGroupOrder(params);
  }
}

class PlaceGroupOrderParams with Params {
  final int groupOrderId;

  PlaceGroupOrderParams({required this.groupOrderId});
}
