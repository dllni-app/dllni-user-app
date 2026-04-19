import '../../data/models/group_order_api_models.dart';

class GroupOrderCreatedGroupItem {
  const GroupOrderCreatedGroupItem({
    required this.title,
    required this.detail,
    required this.groupOrderId,
    required this.initialData,
  });

  final String title;
  final String detail;
  final int groupOrderId;
  final GroupOrderDetailsModel initialData;
}
