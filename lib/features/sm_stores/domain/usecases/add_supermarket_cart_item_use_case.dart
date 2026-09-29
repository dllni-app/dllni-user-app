import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/add_supermarket_cart_item_model.dart';
import '../repository/sm_stores_repo.dart';

@lazySingleton
class AddSupermarketCartItemUseCase
    implements
        UseCase<AddSupermarketCartItemModel, AddSupermarketCartItemParams> {
  final SmStoresRepo smStores;

  AddSupermarketCartItemUseCase({required this.smStores});

  @override
  DataResponse<AddSupermarketCartItemModel> call(
    AddSupermarketCartItemParams params,
  ) {
    return smStores.addSupermarketCartItem(params);
  }
}

class AddSupermarketCartItemParams with Params {
  final int productId;
  final int quantity;
  final List<int> modifierIds;
  final int? substituteProductId;
  final String? note;

  AddSupermarketCartItemParams({
    required this.productId,
    required this.quantity,
    this.modifierIds = const <int>[],
    this.substituteProductId,
    this.note,
  });

  @override
  BodyMap getBody() => {
    'productId': productId,
    'quantity': quantity,
    if (modifierIds.isNotEmpty) 'modifierIds': modifierIds,
    if (substituteProductId != null) 'substituteProductId': substituteProductId,
    if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
  };
}
