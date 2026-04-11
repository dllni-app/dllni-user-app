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

class FetchUserOffersParams with Params {}
