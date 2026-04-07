import 'package:common_package/helpers/typedef.dart';

import '../../data/models/fetch_rs_offers_products_model.dart';
import '../usecases/fetch_rs_offers_products_use_case.dart';

abstract class RsOffersRepo {
  DataResponse<FetchRsOffersProductsModel> fetchRsOffersProducts(FetchRsOffersProductsParams params);
}
