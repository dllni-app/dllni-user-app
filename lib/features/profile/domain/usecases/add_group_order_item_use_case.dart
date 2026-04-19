import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/group_order_api_models.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class AddGroupOrderItemUseCase implements UseCase<GroupOrderActionModel, AddGroupOrderItemParams> {
  final ProfileRepo profileRepo;

  AddGroupOrderItemUseCase({required this.profileRepo});

  @override
  DataResponse<GroupOrderActionModel> call(AddGroupOrderItemParams params) {
    return profileRepo.addGroupOrderItem(params);
  }
}

class AddGroupOrderItemParams with Params {
  final int groupOrderId;
  final int productId;
  final int quantity;
  final String? notes;
  final List<GroupOrderItemModifierInput> modifiers;

  AddGroupOrderItemParams({
    required this.groupOrderId,
    required this.productId,
    this.quantity = 1,
    this.notes,
    this.modifiers = const <GroupOrderItemModifierInput>[],
  });

  @override
  BodyMap getBody() => <String, dynamic>{
        'productId': productId,
        'quantity': quantity,
        if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
        if (modifiers.isNotEmpty)
          'modifiers': modifiers.map((e) => e.toJson()).toList(),
      };
}

class GroupOrderItemModifierInput {
  final int modifierId;
  final int quantity;

  const GroupOrderItemModifierInput({
    required this.modifierId,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'modifierId': modifierId,
        'quantity': quantity,
      };
}
