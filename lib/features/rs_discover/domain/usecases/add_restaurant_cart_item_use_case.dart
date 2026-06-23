import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/add_restaurant_cart_item_model.dart';
import '../repository/rs_discover_repo.dart';

@lazySingleton
class AddRestaurantCartItemUseCase implements UseCase<AddRestaurantCartItemModel, AddRestaurantCartItemParams> {
  final RsDiscoverRepo rsDiscoverRepo;

  AddRestaurantCartItemUseCase({required this.rsDiscoverRepo});

  @override
  DataResponse<AddRestaurantCartItemModel> call(AddRestaurantCartItemParams params) {
    return rsDiscoverRepo.addRestaurantCartItem(params);
  }
}

class AddRestaurantCartItemParams with Params {
  final int productId;
  final int quantity;
  final String quantityMode;
  final List<int> modifierIds;
  final int? substituteProductId;
  final String specialInstructions;

  AddRestaurantCartItemParams({
    required this.productId,
    this.quantity = 1,
    this.quantityMode = 'increment',
    this.modifierIds = const [],
    this.substituteProductId,
    this.specialInstructions = '',
  });

  @override
  BodyMap getBody() => {
        'productId': productId,
        'quantity': quantity,
        'quantityMode': quantityMode,
        'modifierIds': modifierIds,
        'substituteProductId': substituteProductId,
        'specialInstructions': specialInstructions,
      };
}
