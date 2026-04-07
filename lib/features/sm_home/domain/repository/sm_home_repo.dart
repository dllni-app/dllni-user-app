import 'package:common_package/helpers/typedef.dart';
import '../usecases/get_featured_offers_use_case.dart';
import '../../data/models/get_featured_offers_model.dart';
import '../usecases/get_nearby_stores_use_case.dart';
import '../../data/models/get_nearby_stores_model.dart';
import '../usecases/change_store_favorite_use_case.dart';
import '../../data/models/change_store_favorite_model.dart';
abstract class SmHomeRepo {
  DataResponse<GetFeaturedOffersModel> getFeaturedOffers(GetFeaturedOffersParams params);

  DataResponse<GetNearbyStoresModel> getNearbyStores(GetNearbyStoresParams params);

  DataResponse<ChangeStoreFavoriteModel> changeStoreFavorite(ChangeStoreFavoriteParams params);
}
