import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';

import '../../domain/repository/sm_home_repo.dart';
import 'package:common_package/helpers/typedef.dart';
import '../source/sm_home_remote_data_source.dart';
import '../../domain/usecases/get_featured_offers_use_case.dart';
import '../models/get_featured_offers_model.dart';
import '../../domain/usecases/get_nearby_stores_use_case.dart';
import '../models/get_nearby_stores_model.dart';
import '../../domain/usecases/change_store_favorite_use_case.dart';
import '../models/change_store_favorite_model.dart';

@LazySingleton(as: SmHomeRepo)
class SmHomeRepoImpl with HandlingException implements SmHomeRepo {
  final SmHomeRemoteDataSource smHomeRemoteDataSource;

  SmHomeRepoImpl({required this.smHomeRemoteDataSource});

  @override
  DataResponse<GetFeaturedOffersModel> getFeaturedOffers(GetFeaturedOffersParams params) {
    return wrapHandlingException(
      tryCall: () => smHomeRemoteDataSource.getFeaturedOffers(params),
    );
  }

  @override
  DataResponse<GetNearbyStoresModel> getNearbyStores(GetNearbyStoresParams params) {
    return wrapHandlingException(
      tryCall: () => smHomeRemoteDataSource.getNearbyStores(params),
    );
  }

  @override
  DataResponse<ChangeStoreFavoriteModel> changeStoreFavorite(ChangeStoreFavoriteParams params) {
    return wrapHandlingException(
      tryCall: () => smHomeRemoteDataSource.changeStoreFavorite(params),
    );
  }}

