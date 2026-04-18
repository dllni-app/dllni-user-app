import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/typedef.dart';

import '../repository/profile_repo.dart';
import '../../data/models/get_shopping_list_model.dart';

@lazySingleton
class GetShoppingListUseCase implements UseCase<GetShoppingListModel, GetShoppingListParams> {

  final ProfileRepo profile;

  GetShoppingListUseCase({required this.profile});

  @override
  DataResponse<GetShoppingListModel> call(GetShoppingListParams params) {
    return profile.getShoppingList(params);
  }
}

class GetShoppingListParams with Params{}
