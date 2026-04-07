import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/typedef.dart';

import '../../data/models/fetch_favourite_products_model.dart';
import '../repository/rs_favourite_repo.dart';

@lazySingleton
class FetchFavouriteProductsUseCase implements UseCase<FetchFavouriteProductsModel, FetchFavouriteProductsParams> {
  final RsFavouriteRepo rsFavourite;

  FetchFavouriteProductsUseCase({required this.rsFavourite});

  @override
  DataResponse<FetchFavouriteProductsModel> call(FetchFavouriteProductsParams params) {
    return rsFavourite.fetchFavouriteProducts(params);
  }
}

class FetchFavouriteProductsParams with Params {
  final int page;
  final int perPage;

  FetchFavouriteProductsParams({required this.page, this.perPage = 10});

  @override
  QueryParams getParams() => {'page': page, 'per_page': perPage};
}
