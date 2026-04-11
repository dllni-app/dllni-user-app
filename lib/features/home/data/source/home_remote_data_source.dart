import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/api_handler.dart';
import 'package:common_package/helpers/dio_network.dart';

import '../../domain/usecases/fetch_user_offers_use_case.dart';
import '../models/fetch_user_offers_model.dart';

@lazySingleton
class HomeRemoteDataSource with HandlingApiManager {
  final DioNetwork dioNetwork;

  HomeRemoteDataSource({required this.dioNetwork});

  Future<FetchUserOffersModel> fetchUserOffers(FetchUserOffersParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/offers',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: fetchUserOffersModelFromJson,
    );
  }
}
