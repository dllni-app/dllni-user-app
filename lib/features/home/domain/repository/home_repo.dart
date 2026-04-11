import 'package:common_package/helpers/typedef.dart';

import '../usecases/fetch_user_offers_use_case.dart';
import '../../data/models/fetch_user_offers_model.dart';

abstract class HomeRepo {
  DataResponse<FetchUserOffersModel> fetchUserOffers(FetchUserOffersParams params);
}

