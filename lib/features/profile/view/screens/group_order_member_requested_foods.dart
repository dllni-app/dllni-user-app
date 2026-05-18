import '../../data/models/group_order_api_models.dart';
import '../widgets/group_order_food_row.dart';

/// Rows for the current member only (matched by [currentUserId] vs [GroupOrderParticipantModel.userId]).
List<GroupOrderFoodRow> buildMemberRequestedFoodRows({
  required GroupOrderDetailsModel details,
  required Map<int, String> typeByProductId,
  int? currentUserId,
}) {
  if (currentUserId == null || currentUserId <= 0) {
    return const <GroupOrderFoodRow>[];
  }
  GroupOrderParticipantModel? mine;
  for (final p in details.participants) {
    final uid = p.userId;
    if (uid != null && uid == currentUserId) {
      mine = p;
      break;
    }
  }
  if (mine == null) {
    return const <GroupOrderFoodRow>[];
  }
  final rows = <GroupOrderFoodRow>[];
  for (final item in mine.items) {
    rows.add(
      GroupOrderFoodRow(
        itemId: item.itemId,
        productId: item.productId,
        name: item.name ?? '-',
        quantity: item.quantity,
        type: typeByProductId[item.productId] ?? 'غير مصنف',
        subtitle: item.notes ?? '',
        imageUrl: item.imageUrl,
      ),
    );
  }
  return rows;
}
