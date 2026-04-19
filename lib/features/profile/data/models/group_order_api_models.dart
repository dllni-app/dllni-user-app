int? _goAsInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value');
}

double? _goAsDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse('$value');
}

String? _goAsString(dynamic value) {
  if (value == null) return null;
  return '$value';
}

bool _goAsBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == '1' || normalized == 'true';
  }
  return false;
}

Map<String, dynamic> _goAsMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

List<Map<String, dynamic>> _goAsMapList(dynamic value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
}

GroupOrderActionModel groupOrderActionModelFromJson(dynamic json) =>
    GroupOrderActionModel.fromJson(_goAsMap(json));

GroupOrderActiveListModel groupOrderActiveListModelFromJson(dynamic json) =>
    GroupOrderActiveListModel.fromJson(_goAsMap(json));

GroupOrderDetailsModel groupOrderDetailsModelFromJson(dynamic json) =>
    GroupOrderDetailsModel.fromJson(_goAsMap(json));

GroupOrderMenuSectionsResponseModel groupOrderMenuSectionsResponseModelFromJson(
  dynamic json,
) => GroupOrderMenuSectionsResponseModel.fromJson(_goAsMap(json));

class GroupOrderActionModel {
  final String? message;
  final int? groupOrderId;
  final int? participantId;
  final String? status;
  final int? itemId;
  final int? itemsCount;
  final double? subtotal;
  final int? placedOrderId;
  final GroupOrderDetailsModel? details;

  const GroupOrderActionModel({
    this.message,
    this.groupOrderId,
    this.participantId,
    this.status,
    this.itemId,
    this.itemsCount,
    this.subtotal,
    this.placedOrderId,
    this.details,
  });

  factory GroupOrderActionModel.fromJson(Map<String, dynamic> json) {
    final data = _goAsMap(json['data']);
    final groupOrderPayload = _goAsMap(data['groupOrder']);
    final detailsPayload = groupOrderPayload.isNotEmpty
        ? <String, dynamic>{'groupOrder': groupOrderPayload}
        : (data.isNotEmpty ? data : json);
    return GroupOrderActionModel(
      message: _goAsString(json['message']) ?? _goAsString(data['message']),
      groupOrderId:
          _goAsInt(data['groupOrderId']) ??
          _goAsInt(data['group_order_id']) ??
          _goAsInt(groupOrderPayload['id']),
      participantId: _goAsInt(data['participantId'] ?? data['participant_id']),
      status: _goAsString(data['status']) ?? _goAsString(groupOrderPayload['status']),
      itemId: _goAsInt(data['itemId'] ?? data['item_id']),
      itemsCount: _goAsInt(data['itemsCount'] ?? data['items_count']),
      subtotal: _goAsDouble(data['subtotal']),
      placedOrderId:
          _goAsInt(data['placedOrderId']) ?? _goAsInt(data['placed_order_id']),
      details: GroupOrderDetailsModel.fromJson(detailsPayload),
    );
  }
}

class GroupOrderActiveListModel {
  final List<GroupOrderDetailsModel> data;

  const GroupOrderActiveListModel({
    this.data = const <GroupOrderDetailsModel>[],
  });

  factory GroupOrderActiveListModel.fromJson(Map<String, dynamic> json) {
    final data = _goAsMapList(json['data']).map(GroupOrderDetailsModel.fromJson).toList();
    return GroupOrderActiveListModel(data: data);
  }
}

class GroupOrderDetailsModel {
  final GroupOrderCoreModel? groupOrder;
  final List<GroupOrderParticipantModel> participants;
  final GroupOrderCountsModel? counts;
  final GroupOrderAmountsModel? amounts;

  const GroupOrderDetailsModel({
    this.groupOrder,
    this.participants = const <GroupOrderParticipantModel>[],
    this.counts,
    this.amounts,
  });

  factory GroupOrderDetailsModel.fromJson(Map<String, dynamic> json) {
    final data = _goAsMap(json['data']);
    final payload = data.isNotEmpty ? data : json;
    final groupOrderMap = _goAsMap(payload['groupOrder']);
    final fallbackGroupOrderMap = _goAsMap(payload['group_order']);
    final participantsList = _goAsMapList(payload['participants']);

    return GroupOrderDetailsModel(
      groupOrder: (groupOrderMap.isNotEmpty || fallbackGroupOrderMap.isNotEmpty)
          ? GroupOrderCoreModel.fromJson(
              groupOrderMap.isNotEmpty ? groupOrderMap : fallbackGroupOrderMap,
            )
          : null,
      participants: participantsList.map(GroupOrderParticipantModel.fromJson).toList(),
      counts: _goAsMap(payload['counts']).isNotEmpty
          ? GroupOrderCountsModel.fromJson(_goAsMap(payload['counts']))
          : null,
      amounts: _goAsMap(payload['amounts']).isNotEmpty
          ? GroupOrderAmountsModel.fromJson(_goAsMap(payload['amounts']))
          : null,
    );
  }
}

class GroupOrderCoreModel {
  final int? id;
  final String? status;
  final String? name;
  final int? restaurantId;
  final String? restaurantName;
  final String? shareToken;
  final String? endsAt;
  final int? secondsRemaining;
  final int? creatorUserId;
  final bool isCreator;
  final int? placedOrderId;
  final String? placedAt;

  const GroupOrderCoreModel({
    this.id,
    this.status,
    this.name,
    this.restaurantId,
    this.restaurantName,
    this.shareToken,
    this.endsAt,
    this.secondsRemaining,
    this.creatorUserId,
    this.isCreator = false,
    this.placedOrderId,
    this.placedAt,
  });

  factory GroupOrderCoreModel.fromJson(Map<String, dynamic> json) {
    return GroupOrderCoreModel(
      id: _goAsInt(json['id']),
      status: _goAsString(json['status']),
      name: _goAsString(json['name']),
      restaurantId: _goAsInt(json['restaurantId'] ?? json['restaurant_id']),
      restaurantName: _goAsString(json['restaurantName'] ?? json['restaurant_name']),
      shareToken: _goAsString(json['shareToken'] ?? json['share_token']),
      endsAt: _goAsString(json['endsAt'] ?? json['ends_at']),
      secondsRemaining: _goAsInt(json['secondsRemaining'] ?? json['seconds_remaining']),
      creatorUserId: _goAsInt(json['creatorUserId'] ?? json['creator_user_id']),
      isCreator: _goAsBool(json['isCreator'] ?? json['is_creator']),
      placedOrderId: _goAsInt(json['placedOrderId'] ?? json['placed_order_id']),
      placedAt: _goAsString(json['placedAt'] ?? json['placed_at']),
    );
  }
}

class GroupOrderParticipantModel {
  final int? participantId;
  final int? userId;
  final String? name;
  final String? status;
  final bool hasResponded;
  final String? submittedAt;
  final double? subtotal;
  final int? itemsCount;
  final List<GroupOrderItemModel> items;

  const GroupOrderParticipantModel({
    this.participantId,
    this.userId,
    this.name,
    this.status,
    this.hasResponded = false,
    this.submittedAt,
    this.subtotal,
    this.itemsCount,
    this.items = const <GroupOrderItemModel>[],
  });

  factory GroupOrderParticipantModel.fromJson(Map<String, dynamic> json) {
    return GroupOrderParticipantModel(
      participantId: _goAsInt(json['participantId'] ?? json['participant_id']),
      userId: _goAsInt(json['userId'] ?? json['user_id']),
      name: _goAsString(json['name']),
      status: _goAsString(json['status']),
      hasResponded: _goAsBool(json['hasResponded'] ?? json['has_responded']),
      submittedAt: _goAsString(json['submittedAt'] ?? json['submitted_at']),
      subtotal: _goAsDouble(json['subtotal']),
      itemsCount: _goAsInt(json['itemsCount'] ?? json['items_count']),
      items: _goAsMapList(json['items']).map(GroupOrderItemModel.fromJson).toList(),
    );
  }
}

class GroupOrderItemModel {
  final int? itemId;
  final int? productId;
  final String? name;
  final int quantity;
  final double? unitPrice;
  final double? lineTotal;
  final String? notes;
  final String? imageUrl;
  final List<GroupOrderItemModifierModel> modifiers;

  const GroupOrderItemModel({
    this.itemId,
    this.productId,
    this.name,
    this.quantity = 1,
    this.unitPrice,
    this.lineTotal,
    this.notes,
    this.imageUrl,
    this.modifiers = const <GroupOrderItemModifierModel>[],
  });

  factory GroupOrderItemModel.fromJson(Map<String, dynamic> json) {
    return GroupOrderItemModel(
      itemId: _goAsInt(json['itemId'] ?? json['item_id'] ?? json['id']),
      productId: _goAsInt(json['productId'] ?? json['product_id']),
      name: _goAsString(json['name']) ?? _goAsString(json['productName'] ?? json['product_name']),
      quantity: _goAsInt(json['quantity']) ?? 1,
      unitPrice: _goAsDouble(json['unitPrice'] ?? json['unit_price']),
      lineTotal: _goAsDouble(
        json['lineTotal'] ?? json['line_total'] ?? json['totalPrice'] ?? json['total_price'],
      ),
      notes: _goAsString(json['notes']),
      imageUrl: _goAsString(json['imageUrl'] ?? json['image_url']),
      modifiers: _goAsMapList(json['modifiers'])
          .map(GroupOrderItemModifierModel.fromJson)
          .toList(),
    );
  }
}

class GroupOrderItemModifierModel {
  final int? id;
  final String? name;
  final double? price;

  const GroupOrderItemModifierModel({
    this.id,
    this.name,
    this.price,
  });

  factory GroupOrderItemModifierModel.fromJson(Map<String, dynamic> json) {
    return GroupOrderItemModifierModel(
      id: _goAsInt(json['id']),
      name: _goAsString(json['name']),
      price: _goAsDouble(json['price']),
    );
  }
}

class GroupOrderCountsModel {
  final int participants;
  final int responded;
  final int pending;
  final int items;

  const GroupOrderCountsModel({
    this.participants = 0,
    this.responded = 0,
    this.pending = 0,
    this.items = 0,
  });

  factory GroupOrderCountsModel.fromJson(Map<String, dynamic> json) {
    return GroupOrderCountsModel(
      participants: _goAsInt(json['participants']) ?? 0,
      responded: _goAsInt(json['responded']) ?? 0,
      pending: _goAsInt(json['pending']) ?? 0,
      items: _goAsInt(json['items']) ?? 0,
    );
  }
}

class GroupOrderAmountsModel {
  final double subtotal;
  final double deliveryFee;
  final double total;

  const GroupOrderAmountsModel({
    this.subtotal = 0,
    this.deliveryFee = 0,
    this.total = 0,
  });

  factory GroupOrderAmountsModel.fromJson(Map<String, dynamic> json) {
    return GroupOrderAmountsModel(
      subtotal: _goAsDouble(json['subtotal']) ?? 0,
      deliveryFee: _goAsDouble(json['deliveryFee'] ?? json['delivery_fee']) ?? 0,
      total: _goAsDouble(json['total']) ?? 0,
    );
  }
}

class GroupOrderMenuSectionsResponseModel {
  final int? restaurantId;
  final int itemsPerSection;
  final List<GroupOrderMenuSectionModel> sections;

  const GroupOrderMenuSectionsResponseModel({
    this.restaurantId,
    this.itemsPerSection = 0,
    this.sections = const <GroupOrderMenuSectionModel>[],
  });

  factory GroupOrderMenuSectionsResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return GroupOrderMenuSectionsResponseModel(
      restaurantId: _goAsInt(json['restaurantId'] ?? json['restaurant_id']),
      itemsPerSection: _goAsInt(
            json['itemsPerSection'] ?? json['items_per_section'],
          ) ??
          0,
      sections: _goAsMapList(json['sections'])
          .map(GroupOrderMenuSectionModel.fromJson)
          .toList(),
    );
  }
}

class GroupOrderMenuSectionModel {
  final int? id;
  final String name;
  final int sortOrder;
  final int totalProducts;
  final List<GroupOrderMenuSectionItemModel> items;

  const GroupOrderMenuSectionModel({
    this.id,
    this.name = '',
    this.sortOrder = 0,
    this.totalProducts = 0,
    this.items = const <GroupOrderMenuSectionItemModel>[],
  });

  factory GroupOrderMenuSectionModel.fromJson(Map<String, dynamic> json) {
    return GroupOrderMenuSectionModel(
      id: _goAsInt(json['id']),
      name: _goAsString(json['name']) ?? '',
      sortOrder: _goAsInt(json['sortOrder'] ?? json['sort_order']) ?? 0,
      totalProducts:
          _goAsInt(json['totalProducts'] ?? json['total_products']) ?? 0,
      items: _goAsMapList(json['items'])
          .map(GroupOrderMenuSectionItemModel.fromJson)
          .toList(),
    );
  }
}

class GroupOrderMenuSectionItemModel {
  final int? id;
  final String name;
  final String? description;
  final String? sizeLabel;
  final double? displayPrice;
  final double? originalPrice;
  final String? currency;
  final String? primaryImageUrl;
  final bool isFeatured;
  final bool isFavorite;
  final String sectionName;
  final int? sectionId;

  const GroupOrderMenuSectionItemModel({
    this.id,
    this.name = '',
    this.description,
    this.sizeLabel,
    this.displayPrice,
    this.originalPrice,
    this.currency,
    this.primaryImageUrl,
    this.isFeatured = false,
    this.isFavorite = false,
    this.sectionName = '',
    this.sectionId,
  });

  factory GroupOrderMenuSectionItemModel.fromJson(Map<String, dynamic> json) {
    return GroupOrderMenuSectionItemModel(
      id: _goAsInt(json['id']),
      name: _goAsString(json['name']) ?? '',
      description: _goAsString(json['description']),
      sizeLabel: _goAsString(json['sizeLabel'] ?? json['size_label']),
      displayPrice: _goAsDouble(json['displayPrice'] ?? json['display_price']),
      originalPrice:
          _goAsDouble(json['originalPrice'] ?? json['original_price']),
      currency: _goAsString(json['currency']),
      primaryImageUrl:
          _goAsString(json['primaryImageUrl'] ?? json['primary_image_url']),
      isFeatured: _goAsBool(json['isFeatured'] ?? json['is_featured']),
      isFavorite: _goAsBool(json['isFavorite'] ?? json['is_favorite']),
      sectionName: _goAsString(
            json['sectionName'] ?? json['section_name'],
          ) ??
          '',
      sectionId: _goAsInt(json['sectionId'] ?? json['section_id']),
    );
  }

  GroupOrderMenuSectionItemModel withSection({
    required String sectionName,
    required int? sectionId,
  }) {
    return GroupOrderMenuSectionItemModel(
      id: id,
      name: name,
      description: description,
      sizeLabel: sizeLabel,
      displayPrice: displayPrice,
      originalPrice: originalPrice,
      currency: currency,
      primaryImageUrl: primaryImageUrl,
      isFeatured: isFeatured,
      isFavorite: isFavorite,
      sectionName: sectionName,
      sectionId: sectionId,
    );
  }
}
