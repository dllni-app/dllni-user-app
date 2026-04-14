import 'package:common_package/common_package.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/shopping_lists_api_models.dart';
import '../repository/shopping_lists_repo.dart';

@lazySingleton
class CreateShoppingListUseCase
    implements UseCase<ShoppingListDetailResponseModel, CreateShoppingListParams> {
  final ShoppingListsRepo shoppingListsRepo;

  CreateShoppingListUseCase({required this.shoppingListsRepo});

  @override
  DataResponse<ShoppingListDetailResponseModel> call(CreateShoppingListParams params) {
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

/// `dayOfWeek`: 1 = Sunday … 7 = Saturday (API range).
class ShoppingListScheduleParams {
  final ShoppingListFrequencyType frequencyType;
  final int dayOfWeek;

  const ShoppingListScheduleParams({
    required this.frequencyType,
    required this.dayOfWeek,
  });
}

class CreateShoppingListParams with Params {
  final String name;
  final String? description;
  final bool isActive;
  final ShoppingListScheduleParams schedule;

  CreateShoppingListParams({
    required this.name,
    this.description,
    this.isActive = true,
    required this.schedule,
  });

  @override
  BodyMap getBody() {
    return <String, dynamic>{
      'name': name,
      'description': description,
      'isActive': isActive,
      'schedule': <String, dynamic>{
        'frequencyType': schedule.frequencyType.apiValue,
        'dayOfWeek': schedule.dayOfWeek,
      },
    };
  }
}
