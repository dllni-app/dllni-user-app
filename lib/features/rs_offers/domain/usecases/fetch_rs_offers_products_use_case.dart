import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/typedef.dart';

import '../repository/rs_offers_repo.dart';
import '../../data/models/fetch_rs_offers_products_model.dart';

@lazySingleton
class FetchRsOffersProductsUseCase implements UseCase<FetchRsOffersProductsModel, FetchRsOffersProductsParams> {
  final RsOffersRepo rsOffersRepo;

  FetchRsOffersProductsUseCase({required this.rsOffersRepo});

  @override
  DataResponse<FetchRsOffersProductsModel> call(FetchRsOffersProductsParams params) {
    return rsOffersRepo.fetchRsOffersProducts(params);
  }
}

class FetchRsOffersProductsParams with Params {
  final int page;
  final int perPage;

  FetchRsOffersProductsParams({required this.page, this.perPage = 10});

  @override
  QueryParams getParams() => {'page': page, 'per_page': perPage};
}
