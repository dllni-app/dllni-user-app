import 'package:common_package/helpers/typedef.dart';

class FetchDiscoverRestaurantsParams with Params {
  final int page;
  final int perPage;
  final String? search;
  final String sort;
  final int filterOpenNow;
  final int filterHasOffers;
  final double? latitude;
  final double? longitude;

  FetchDiscoverRestaurantsParams({
    this.page = 1,
    this.perPage = 10,
    this.search,
    this.sort = 'rating',
    this.filterOpenNow = 0,
    this.filterHasOffers = 0,
    this.latitude,
    this.longitude,
  });

  @override
  QueryParams getParams() => {
        'page': page,
        'perPage': perPage,
        if(search != null && search!.isNotEmpty)'search': search,
        'sort': sort,
        'filter[openNow]': filterOpenNow,
        'filter[hasOffers]': filterHasOffers,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };
}
