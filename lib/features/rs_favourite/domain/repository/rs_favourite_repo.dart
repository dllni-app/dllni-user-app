import 'package:common_package/helpers/typedef.dart';
import '../usecases/fetch_rs_favourites_use_case.dart';
import '../../data/models/fetch_rs_favourites_model.dart';
abstract class RsFavouriteRepo {
  DataResponse<FetchRsFavouritesModel> fetchRsFavourites(FetchRsFavouritesParams params);
}
