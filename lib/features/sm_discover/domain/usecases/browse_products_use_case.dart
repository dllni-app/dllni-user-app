import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/typedef.dart';

import '../repository/sm_discover_repo.dart';
import '../../data/models/browse_products_model.dart';

@lazySingleton
class BrowseProductsUseCase
    implements UseCase<BrowseProductsModel, BrowseProductsParams> {
  final SmDiscoverRepo smDiscover;

  BrowseProductsUseCase({required this.smDiscover});

  @override
  DataResponse<BrowseProductsModel> call(BrowseProductsParams params) {
    return smDiscover.browseProducts(params);
  }
}

class BrowseProductsParams with Params {
  final String? search;
  final int? storeId;
  final int? categoryId;
  final double? priceMin;
  final double? priceMax;
  final bool? isAvailable;
  final String? sort;
  final int page;

  BrowseProductsParams({
    this.search,
    this.storeId,
    this.categoryId,
    this.priceMin,
    this.priceMax,
    this.isAvailable,
    this.sort,
    this.page = 1,
  });

  @override
  QueryParams getParams() {
    return {
      "perPage": 10,
      "page": page,
      if (search != null && search != "") "search": search,
      if (storeId != null) "filter[storeId]": storeId,
      if (categoryId != null) "filter[categoryId]": categoryId,
      if (priceMin != null) "price_min": priceMin,
      if (priceMax != null) "price_max": priceMax,
      if (isAvailable != null) "filter[isAvailable]": isAvailable,
      if (sort != null) "sort": sort,
    };
  }
}
