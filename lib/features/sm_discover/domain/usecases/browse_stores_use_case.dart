import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/typedef.dart';

import '../repository/sm_discover_repo.dart';
import '../../data/models/browse_stores_model.dart';

@lazySingleton
class BrowseStoresUseCase
    implements UseCase<BrowseStoresModel, BrowseStoresParams> {
  final SmDiscoverRepo smDiscover;

  BrowseStoresUseCase({required this.smDiscover});

  @override
  DataResponse<BrowseStoresModel> call(BrowseStoresParams params) {
    return smDiscover.browseStores(params);
  }
}

class BrowseStoresParams with Params {
  final String? search;
  final int page;
  final String? sort;
  final double? latitude;
  final double? longitude;
  final bool? openNow;
  final bool? isFeatured;
  final double? averageRatingMin;

  BrowseStoresParams({
    this.search,
    this.page = 1,
    this.sort,
    this.latitude,
    this.longitude,
    this.openNow,
    this.isFeatured,
    this.averageRatingMin,
  });

  @override
  QueryParams getParams() => {
    "page": page,
    "perPage": 10,
    if (search != null && search != "") "search": search,
    if (sort != null) "sort": sort,
    if (latitude != null) "latitude": latitude,
    if (longitude != null) "longitude": longitude,
    if (openNow != null) "filter[openNow]": openNow,
    if (isFeatured != null) "filter[isFeatured]": isFeatured,
    if (averageRatingMin != null) "filter[averageRatingMin]": averageRatingMin,
  };
}
