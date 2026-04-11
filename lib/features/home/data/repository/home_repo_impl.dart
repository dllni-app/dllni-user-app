import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';
import 'package:common_package/helpers/typedef.dart';

import '../../domain/repository/home_repo.dart';
import '../../domain/usecases/fetch_user_offers_use_case.dart';
import '../models/fetch_user_offers_model.dart';
import '../source/home_remote_data_source.dart';

@LazySingleton(as: HomeRepo)
class HomeRepoImpl with HandlingException implements HomeRepo {
  final HomeRemoteDataSource homeRemoteDataSource;

  HomeRepoImpl({required this.homeRemoteDataSource});

  @override
  DataResponse<FetchUserOffersModel> fetchUserOffers(FetchUserOffersParams params) {
    return wrapHandlingException(
      tryCall: () => homeRemoteDataSource.fetchUserOffers(params),
    );
  }
}

