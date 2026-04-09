import 'package:common_package/helpers/typedef.dart';

import '../../data/models/create_cleaning_order_response_model.dart';
import '../../data/models/estimate_price_response_model.dart';
import '../../data/models/previous_workers_response_model.dart';
import '../usecases/create_cleaning_order_use_case.dart';
import '../usecases/estimate_cleaning_price_use_case.dart';
import '../usecases/get_previous_cleaning_workers_use_case.dart';

abstract class ClMainRepo {
  DataResponse<EstimatePriceResponseModel> estimateCleaningPrice(EstimateCleaningPriceParams params);

  DataResponse<PreviousWorkersResponseModel> getPreviousCleaningWorkers(GetPreviousCleaningWorkersParams params);

  DataResponse<CreateCleaningOrderResponseModel> createCleaningOrder(CreateCleaningOrderParams params);
}
