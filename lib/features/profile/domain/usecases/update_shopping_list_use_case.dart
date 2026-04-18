import 'package:common_package/common_package.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/shopping_lists_api_models.dart';
import '../repository/shopping_lists_repo.dart';
import 'create_shopping_list_use_case.dart';

@lazySingleton
class UpdateShoppingListUseCase
    implements UseCase<ShoppingListDetailResponseModel, UpdateShoppingListParams> {
  final ShoppingListsRepo shoppingListsRepo;

  UpdateShoppingListUseCase({required this.shoppingListsRepo});

  @override
  DataResponse<ShoppingListDetailResponseModel> call(UpdateShoppingListParams params) {
    return shoppingListsRepo.updateShoppingList(params);
  }
}

class UpdateShoppingListParams with Params {
  final int shoppingListId;
  final String? name;
  final String? description;
  final bool? isActive;

  /// When non-null, PATCH includes full `schedule` (same shape as create).
  final ShoppingListFrequencyType? scheduleFrequencyType;
  final List<int> scheduleWeekDays;
  final List<int> scheduleMonthDays;
  final List<ShoppingListPeriodParam> schedulePeriods;
  final bool scheduleIsActive;

  UpdateShoppingListParams({
    required this.shoppingListId,
    this.name,
    this.description,
    this.isActive,
    this.scheduleFrequencyType,
    this.scheduleWeekDays = const <int>[],
    this.scheduleMonthDays = const <int>[],
    this.schedulePeriods = const <ShoppingListPeriodParam>[],
    this.scheduleIsActive = true,
  });

  @override
  BodyMap getBody() {
    final map = <String, dynamic>{
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (isActive != null) 'isActive': isActive,
    };
    final scheduleFt = scheduleFrequencyType;
    if (scheduleFt != null) {
      map['schedule'] = <String, dynamic>{
        'frequencyType': scheduleFt.apiValue,
        if (scheduleWeekDays.isNotEmpty) 'weekDays': scheduleWeekDays,
        if (scheduleMonthDays.isNotEmpty) 'monthDays': scheduleMonthDays,
        'periods': schedulePeriods.map((e) => e.toJson()).toList(),
        'isActive': scheduleIsActive,
      };
    }
    return map;
  }
}
