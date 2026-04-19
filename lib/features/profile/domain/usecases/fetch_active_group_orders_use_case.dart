import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/group_order_api_models.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class FetchActiveGroupOrdersUseCase implements UseCase<GroupOrderActiveListModel, FetchActiveGroupOrdersParams> {
  final ProfileRepo profileRepo;

  FetchActiveGroupOrdersUseCase({required this.profileRepo});

  @override
  DataResponse<GroupOrderActiveListModel> call(FetchActiveGroupOrdersParams params) {
    return profileRepo.fetchActiveGroupOrders(params);
  }
}

class FetchActiveGroupOrdersParams with Params {}
