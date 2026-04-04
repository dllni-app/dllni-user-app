import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/rs_orders_api_models.dart';
import '../repository/rs_orders_repo.dart';

@lazySingleton
class AddCartItemUseCase
    implements UseCase<AddCartItemModel, AddCartItemParams> {
  final RsOrdersRepo rsOrdersRepo;

  AddCartItemUseCase({required this.rsOrdersRepo});

  @override
  DataResponse<AddCartItemModel> call(AddCartItemParams params) {
    return rsOrdersRepo.addCartItem(
      productId: params.productId,
      quantity: params.quantity,
      modifierIds: params.modifierIds,
      substituteProductId: params.substituteProductId,
      specialInstructions: params.specialInstructions,
    );
  }
}

class AddCartItemParams with Params {
  final int productId;
  final int quantity;
  final List<int> modifierIds;
  final int? substituteProductId;
  final String specialInstructions;

  AddCartItemParams({
    required this.productId,
    this.quantity = 1,
    this.modifierIds = const [],
    this.substituteProductId,
    this.specialInstructions = '',
  });

  @override
  BodyMap getBody() => {
    'productId': productId,
    'quantity': quantity,
    'modifierIds': modifierIds,
    if (substituteProductId != null) 'substituteProductId': substituteProductId,
    'specialInstructions': specialInstructions,
  };
}
