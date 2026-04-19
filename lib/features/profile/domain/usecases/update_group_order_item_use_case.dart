import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/group_order_api_models.dart';
import 'add_group_order_item_use_case.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class UpdateGroupOrderItemUseCase implements UseCase<GroupOrderActionModel, UpdateGroupOrderItemParams> {
  final ProfileRepo profileRepo;

  UpdateGroupOrderItemUseCase({required this.profileRepo});

  @override
  DataResponse<GroupOrderActionModel> call(UpdateGroupOrderItemParams params) {
    return profileRepo.updateGroupOrderItem(params);
  }
}

class UpdateGroupOrderItemParams with Params {
  final int groupOrderId;
  final int itemId;
  final int quantity;
  final String? notes;
  final List<GroupOrderItemModifierInput> modifiers;

  UpdateGroupOrderItemParams({
    required this.groupOrderId,
    required this.itemId,
    required this.quantity,
    this.notes,
    this.modifiers = const <GroupOrderItemModifierInput>[],
  });

  @override
  BodyMap getBody() => <String, dynamic>{
        'quantity': quantity,
        if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
        if (modifiers.isNotEmpty)
          'modifiers': modifiers.map((e) => e.toJson()).toList(),
      };
}
