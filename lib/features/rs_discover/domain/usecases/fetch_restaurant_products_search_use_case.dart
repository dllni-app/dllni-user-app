import 'package:common_package/helpers/typedef.dart';

import '../../data/models/fetch_restaurant_products_search_model.dart';
import '../repository/rs_discover_repo.dart';

class FetchRestaurantProductsSearchUseCase
    implements
        UseCase<
          FetchRestaurantProductsSearchModel,
          FetchRestaurantProductsSearchParams
        > {
  final RsDiscoverRepo rsDiscoverRepo;

  FetchRestaurantProductsSearchUseCase({required this.rsDiscoverRepo});

  @override
  DataResponse<FetchRestaurantProductsSearchModel> call(
    FetchRestaurantProductsSearchParams params,
  ) {
    return rsDiscoverRepo.fetchRestaurantProductsSearch(params);
  }
}

class FetchRestaurantProductsSearchParams with Params {
  final int page;
  final int perPage;
  final String text;
  final int? restaurantId;

  FetchRestaurantProductsSearchParams({
    required this.page,
    this.perPage = 10,
    this.text = '',
    this.restaurantId,
  });

  @override
  QueryParams getParams() {
    final queryText = text.trim();
    return {
      'page': page,
      'perPage': perPage,
      if (queryText.isNotEmpty) 'text': queryText,
      if (restaurantId != null) 'restaurantId': restaurantId,
    };
  }
}
