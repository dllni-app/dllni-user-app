import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';
import 'package:common_package/helpers/typedef.dart';

import '../../domain/usecases/fetch_rs_offers_products_use_case.dart';
import '../models/fetch_rs_offers_products_model.dart';
import '../../domain/repository/rs_offers_repo.dart';
import '../source/rs_offers_remote_data_source.dart';

@LazySingleton(as: RsOffersRepo)
class RsOffersRepoImpl with HandlingException implements RsOffersRepo {
  final RsOffersRemoteDataSource rsOffersRemoteDataSource;

  RsOffersRepoImpl({required this.rsOffersRemoteDataSource});

  @override
  DataResponse<FetchRsOffersProductsModel> fetchRsOffersProducts(FetchRsOffersProductsParams params) {
    return wrapHandlingException(
      tryCall: () => rsOffersRemoteDataSource.fetchRsOffersProducts(params),
    );
  }
}

