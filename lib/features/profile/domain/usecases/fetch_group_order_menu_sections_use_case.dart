import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/group_order_api_models.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class FetchGroupOrderMenuSectionsUseCase
    implements
        UseCase<
          GroupOrderMenuSectionsResponseModel,
          FetchGroupOrderMenuSectionsParams
        > {
  final ProfileRepo profileRepo;

  FetchGroupOrderMenuSectionsUseCase({required this.profileRepo});

  @override
  DataResponse<GroupOrderMenuSectionsResponseModel> call(
    FetchGroupOrderMenuSectionsParams params,
  ) {
    return profileRepo.fetchGroupOrderMenuSections(params);
  }
}

class FetchGroupOrderMenuSectionsParams with Params {
  final int restaurantId;
  final int itemsPerSection;

  FetchGroupOrderMenuSectionsParams({
    required this.restaurantId,
    this.itemsPerSection = 30,
  });

  @override
  QueryParams getParams() => <String, dynamic>{
        'itemsPerSection': itemsPerSection,
      };
}
