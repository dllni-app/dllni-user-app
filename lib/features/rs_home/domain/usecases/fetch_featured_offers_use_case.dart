import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/typedef.dart';

import '../repository/rs_home_repo.dart';
import '../../data/models/fetch_featured_offers_model.dart';

@lazySingleton
class FetchFeaturedOffersUseCase implements UseCase<FetchFeaturedOffersModel, FetchFeaturedOffersParams> {

  final RsHomeRepo rsHome;

  FetchFeaturedOffersUseCase({required this.rsHome});

  @override
  DataResponse<FetchFeaturedOffersModel> call(FetchFeaturedOffersParams params) {
    return rsHome.fetchFeaturedOffers(params);
  }
}

class FetchFeaturedOffersParams with Params{}
