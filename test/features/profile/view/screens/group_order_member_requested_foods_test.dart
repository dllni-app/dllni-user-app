import 'package:dllni_user_app/features/profile/data/models/group_order_api_models.dart';
import 'package:dllni_user_app/features/profile/view/screens/group_order_member_requested_foods.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final details = GroupOrderDetailsModel(
    groupOrder: const GroupOrderCoreModel(id: 1, status: 'active'),
    participants: const <GroupOrderParticipantModel>[
      GroupOrderParticipantModel(
        userId: 10,
        name: 'Other',
        items: <GroupOrderItemModel>[
          GroupOrderItemModel(itemId: 1, productId: 100, name: 'A', quantity: 1),
        ],
      ),
      GroupOrderParticipantModel(
        userId: 42,
        name: 'Me',
        items: <GroupOrderItemModel>[
          GroupOrderItemModel(itemId: 2, productId: 200, name: 'B', quantity: 2),
          GroupOrderItemModel(itemId: 3, productId: 201, name: 'C', quantity: 1),
        ],
      ),
    ],
  );

  const typeMap = <int, String>{200: 'Salads', 201: 'Salads'};

  test('returns only matching participant rows', () {
    final rows = buildMemberRequestedFoodRows(
      details: details,
      typeByProductId: typeMap,
      currentUserId: 42,
    );
    expect(rows, hasLength(2));
    expect(rows.map((e) => e.itemId), containsAll(<int?>[2, 3]));
    expect(rows.every((r) => r.name == 'B' || r.name == 'C'), isTrue);
  });

  test('returns empty when currentUserId is null', () {
    expect(
      buildMemberRequestedFoodRows(
        details: details,
        typeByProductId: typeMap,
        currentUserId: null,
      ),
      isEmpty,
    );
  });

  test('returns empty when no participant matches userId', () {
    expect(
      buildMemberRequestedFoodRows(
        details: details,
        typeByProductId: typeMap,
        currentUserId: 99,
      ),
      isEmpty,
    );
  });
}
