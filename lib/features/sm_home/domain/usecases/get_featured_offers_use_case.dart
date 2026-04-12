import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/typedef.dart';

import '../repository/sm_home_repo.dart';
import '../../data/models/get_featured_offers_model.dart';

@lazySingleton
class GetFeaturedOffersUseCase implements UseCase<GetFeaturedOffersModel, GetFeaturedOffersParams> {

  final SmHomeRepo smHome;

  GetFeaturedOffersUseCase({required this.smHome});

  @override
  DataResponse<GetFeaturedOffersModel> call(GetFeaturedOffersParams params) {
    return smHome.getFeaturedOffers(params);
  }
}

class GetFeaturedOffersParams with Params{}
