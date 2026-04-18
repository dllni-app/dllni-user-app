import 'package:common_package/common_package.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/shopping_lists_api_models.dart';
import '../repository/shopping_lists_repo.dart';

@lazySingleton
class CreateShoppingListUseCase
    implements
        UseCase<ShoppingListDetailResponseModel, CreateShoppingListParams> {
  final ShoppingListsRepo shoppingListsRepo;

  CreateShoppingListUseCase({required this.shoppingListsRepo});

  @override
  DataResponse<ShoppingListDetailResponseModel> call(
    CreateShoppingListParams params,
  ) {
    return shoppingListsRepo.createShoppingList(params);
  }
}

/// API: `once` | `weekly` | `monthly`
enum ShoppingListFrequencyType {
  once('once'),
  weekly('weekly'),
  monthly('monthly');

  const ShoppingListFrequencyType(this.apiValue);
  final String apiValue;
}

class ShoppingListPeriodParam {
  final String label;
  final String fromTime;
  final String toTime;

  const ShoppingListPeriodParam({
    required this.label,
    required this.fromTime,
    required this.toTime,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
    'label': label,
    'fromTime': fromTime,
    'toTime': toTime,
  };
}

class CreateShoppingListParams with Params {
  final String name;
  final String? description;
  final bool isActive;
  final ShoppingListFrequencyType frequencyType;
  final List<int> weekDays;
  final List<int> monthDays;
  final List<ShoppingListPeriodParam> periods;
  final bool scheduleIsActive;

  CreateShoppingListParams({
    required this.name,
    this.description,
    this.isActive = true,
    required this.frequencyType,
    this.weekDays = const <int>[],
    this.monthDays = const <int>[],
    required this.periods,
    this.scheduleIsActive = true,
  });

  @override
  BodyMap getBody() {
    return <String, dynamic>{
      'name': name,
      'description': description,
      'isActive': isActive,
      'schedule': <String, dynamic>{
        'frequencyType': frequencyType.apiValue,
        if (weekDays.isNotEmpty) 'weekDays': weekDays,
        if (monthDays.isNotEmpty) 'monthDays': monthDays,
        'periods': periods.map((e) => e.toJson()).toList(),
        'isActive': scheduleIsActive,
      },
    };
  }
}
