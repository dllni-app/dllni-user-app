import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';

import '../../domain/repository/rs_favourite_repo.dart';
import 'package:common_package/helpers/typedef.dart';
import '../source/rs_favourite_remote_data_source.dart';
import '../../domain/usecases/fetch_rs_favourites_use_case.dart';
import '../models/fetch_rs_favourites_model.dart';

@LazySingleton(as: RsFavouriteRepo)
class RsFavouriteRepoImpl with HandlingException implements RsFavouriteRepo {
  final RsFavouriteRemoteDataSource rsFavouriteRemoteDataSource;

  RsFavouriteRepoImpl({required this.rsFavouriteRemoteDataSource});

  @override
  DataResponse<FetchRsFavouritesModel> fetchRsFavourites(FetchRsFavouritesParams params) {
    return wrapHandlingException(
      tryCall: () => rsFavouriteRemoteDataSource.fetchRsFavourites(params),
    );
  }}

