import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/typedef.dart';

import '../repository/home_repo.dart';
import '../../data/models/fetch_user_offers_model.dart';

@lazySingleton
class FetchUserOffersUseCase
    implements UseCase<FetchUserOffersModel, FetchUserOffersParams> {
  final HomeRepo homeRepo;

  FetchUserOffersUseCase({required this.homeRepo});

  @override
  DataResponse<FetchUserOffersModel> call(FetchUserOffersParams params) {
    return homeRepo.fetchUserOffers(params);
  }
}

class FetchUserOffersParams with Params {
  final int page;
  final int perPage;

  const FetchUserOffersParams({
    this.page = 1,
    this.perPage = 10,
  });

  @override
  QueryParams getParams() {
    return {
      'page': page,
      'per_page': perPage,
    };
  }
}
