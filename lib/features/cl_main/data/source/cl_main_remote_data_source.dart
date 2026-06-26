import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/api_handler.dart';
import 'package:common_package/helpers/dio_network.dart';

import '../../domain/usecases/create_cleaning_order_use_case.dart';
import '../../domain/usecases/estimate_cleaning_price_use_case.dart';
import '../../domain/usecases/get_cleaning_banners_use_case.dart';
import '../../domain/usecases/get_cleaning_services_use_case.dart';
import '../../domain/usecases/get_previous_cleaning_workers_use_case.dart';
import '../models/cleaning_banners_response_model.dart';
import '../models/cleaning_services_response_model.dart';
import '../models/create_cleaning_order_response_model.dart';
import '../models/female_worker_safety_policy_model.dart';
import '../models/previous_workers_response_model.dart';

@lazySingleton
class ClMainRemoteDataSource with HandlingApiManager {
  final DioNetwork dioNetwork;

  ClMainRemoteDataSource({required this.dioNetwork});

  Future<EstimatePriceResponseModel> estimateCleaningPrice(
    EstimateCleaningPriceParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/cleaning/orders/estimate-price',
        data: params.getBody(),
        params: params.getParams(),
      ),
      jsonConvert: estimatePriceResponseModelFromJson,
    );
  }

  Future<PreviousWorkersResponseModel> getPreviousCleaningWorkers(
    GetPreviousCleaningWorkersParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/cleaning/orders/previous-workers',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: previousWorkersResponseModelFromJson,
    );
  }

  Future<CleaningServicesResponseModel> getCleaningServices(
    GetCleaningServicesParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/cleaning-services',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: cleaningServicesResponseModelFromJson,
    );
  }

  Future<CreateCleaningOrderResponseModel> createCleaningOrder(
    CreateCleaningOrderParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/cleaning/orders',
        data: params.getBody(),
        params: params.getParams(),
      ),
      jsonConvert: createCleaningOrderResponseModelFromJson,
    );
  }

  Future<FemaleWorkerSafetyPolicyModel> getFemaleWorkerSafetyPolicy() {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/cleaning/orders/female-worker-safety-policy',
      ),
      jsonConvert: (json)=>FemaleWorkerSafetyPolicyModel.fromJson(json),
    );
  }

  Future<CleaningBannersResponseModel> getCleaningBanners(
    GetCleaningBannersParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/cleaning/home/banners',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: cleaningBannersResponseModelFromJson,
    );
  }
}
