import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/api_handler.dart';
import 'package:common_package/helpers/dio_network.dart';

import '../../../../core/models/cleaning_service_extras.dart';

import '../../domain/usecases/create_cleaning_order_use_case.dart';
import '../../domain/usecases/estimate_cleaning_price_use_case.dart';
import '../../domain/usecases/get_cleaning_banners_use_case.dart';
import '../../domain/usecases/get_cleaning_services_use_case.dart';
import '../../domain/usecases/get_previous_cleaning_workers_use_case.dart';
import '../models/cleaning_banners_response_model.dart';
import '../models/estimate_price_response_model.dart';
import '../models/cleaning_services_response_model.dart';
import '../models/cleaning_suite_config_model.dart';
import '../models/create_cleaning_order_response_model.dart';
import '../models/female_worker_safety_policy_model.dart';
import '../models/previous_workers_response_model.dart';

@lazySingleton
class ClMainRemoteDataSource with HandlingApiManager {
  final DioNetwork dioNetwork;

  ClMainRemoteDataSource({required this.dioNetwork});

  Future<EstimatePriceResponseModel> estimateBookingV2(
    Map<String, dynamic> booking,
  ) => wrapHandlingApi(
    tryCall: () => dioNetwork.postData(
      endPoint: '/api/v1/user/cleaning/orders/estimate-price',
      data: booking,
    ),
    jsonConvert: estimatePriceResponseModelFromJson,
  );

  /// Fetches the required room materials independently of pricing and address.
  Future<EstimatePriceResponseModel> previewBookingMaterialsV2(
    Map<String, dynamic> booking,
  ) => wrapHandlingApi(
    tryCall: () => dioNetwork.postData(
      endPoint: '/api/v1/user/cleaning/orders/materials-preview',
      data: {'contractVersion': 2, 'rooms': booking['rooms']},
    ),
    jsonConvert: estimatePriceResponseModelFromJson,
  );

  Future<CreateCleaningOrderResponseModel> createBookingV2(
    Map<String, dynamic> booking,
  ) => wrapHandlingApi(
    tryCall: () => dioNetwork.postData(
      endPoint: '/api/v1/user/cleaning/orders',
      data: booking,
    ),
    jsonConvert: createCleaningOrderResponseModelFromJson,
  );

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
    // print(jsonEncode(params.getBody()));
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
      jsonConvert: (json) => FemaleWorkerSafetyPolicyModel.fromJson(json),
    );
  }

  Future<CleaningSuiteConfigModel> getCleaningSuiteConfig() {
    return wrapHandlingApi(
      tryCall: () =>
          dioNetwork.getData(endPoint: '/api/v1/cleaning/suite-config'),
      jsonConvert: cleaningSuiteConfigModelFromJson,
    );
  }

  Future<CleaningBannersResponseModel> getCleaningBanners(
    GetCleaningBannersParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/cleaning/home/content',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: cleaningBannersResponseModelFromJson,
    );
  }
}
