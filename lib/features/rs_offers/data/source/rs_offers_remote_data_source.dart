import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/api_handler.dart';
import 'package:common_package/helpers/dio_network.dart';

import '../../domain/usecases/fetch_rs_offers_products_use_case.dart';
import '../models/fetch_rs_offers_products_model.dart';

@lazySingleton
class RsOffersRemoteDataSource with HandlingApiManager {
  final DioNetwork dioNetwork;

  RsOffersRemoteDataSource({required this.dioNetwork});

  Future<FetchRsOffersProductsModel> fetchRsOffersProducts(FetchRsOffersProductsParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/restaurants/products/with-offers',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: fetchRsOffersProductsModelFromJson,
    );
  }
}