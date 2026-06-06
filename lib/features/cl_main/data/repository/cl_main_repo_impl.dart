import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';
import 'package:common_package/helpers/typedef.dart';

import '../../data/models/cleaning_banners_response_model.dart';
import '../../data/models/cleaning_services_response_model.dart';
import '../../domain/usecases/create_cleaning_order_use_case.dart';
import '../../domain/usecases/estimate_cleaning_price_use_case.dart';
import '../../domain/usecases/get_cleaning_banners_use_case.dart';
import '../../domain/usecases/get_cleaning_services_use_case.dart';
import '../../domain/usecases/get_previous_cleaning_workers_use_case.dart';
import '../../domain/repository/cl_main_repo.dart';
import '../models/create_cleaning_order_response_model.dart';
import '../models/estimate_price_response_model.dart';
import '../models/previous_workers_response_model.dart';
import '../source/cl_main_remote_data_source.dart';

@LazySingleton(as: ClMainRepo)
class ClMainRepoImpl with HandlingException implements ClMainRepo {
  final ClMainRemoteDataSource clMainRemoteDataSource;

  ClMainRepoImpl({required this.clMainRemoteDataSource});

  @override
  DataResponse<EstimatePriceResponseModel> estimateCleaningPrice(
    EstimateCleaningPriceParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => clMainRemoteDataSource.estimateCleaningPrice(params),
    );
  }

  @override
  DataResponse<PreviousWorkersResponseModel> getPreviousCleaningWorkers(
    GetPreviousCleaningWorkersParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => clMainRemoteDataSource.getPreviousCleaningWorkers(params),
    );
  }

  @override
  DataResponse<CleaningServicesResponseModel> getCleaningServices(
    GetCleaningServicesParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => clMainRemoteDataSource.getCleaningServices(params),
    );
  }

  @override
  DataResponse<CreateCleaningOrderResponseModel> createCleaningOrder(
    CreateCleaningOrderParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => clMainRemoteDataSource.createCleaningOrder(params),
    );
  }

  @override
  DataResponse<CleaningBannersResponseModel> getCleaningBanners(
    GetCleaningBannersParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => clMainRemoteDataSource.getCleaningBanners(params),
    );
  }
}
