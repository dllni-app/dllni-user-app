import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/rs_profile_api_models.dart';
import '../repository/rs_profile_repo.dart';

@lazySingleton
class FetchNotificationsUseCase
    implements UseCase<FetchNotificationsPageModel, FetchNotificationsParams> {
  final RsProfileRepo rsProfileRepo;

  FetchNotificationsUseCase({required this.rsProfileRepo});

  @override
  DataResponse<FetchNotificationsPageModel> call(
    FetchNotificationsParams params,
  ) {
    return rsProfileRepo.fetchNotifications(params);
  }
}

class FetchNotificationsParams with Params {
  final int page;
  final int perPage;
  final bool? unreadOnly;

  FetchNotificationsParams({this.page = 1, this.perPage = 10, this.unreadOnly});

  @override
  QueryParams getParams() => {
    'page': page,
    'perPage': perPage,
    if (unreadOnly != null) 'filter[unread]': unreadOnly! ? 1 : 0,
  };
}
