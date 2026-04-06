int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value');
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse('$value');
}

String? _asString(dynamic value) {
  if (value == null) return null;
  return '$value';
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value == '1' || value.toLowerCase() == 'true';
  return false;
}

FetchFavoriteRestaurantsModel fetchFavoriteRestaurantsModelFromJson(
  dynamic json,
) => FetchFavoriteRestaurantsModel.fromJson(
  Map<String, dynamic>.from(json as Map),
);

FetchAddressesModel fetchAddressesModelFromJson(dynamic json) =>
    FetchAddressesModel.fromJson(Map<String, dynamic>.from(json as Map));

FetchNotificationsPageModel fetchNotificationsPageModelFromJson(dynamic json) =>
    FetchNotificationsPageModel.fromJson(
      Map<String, dynamic>.from(json as Map),
    );

ActionResultModel actionResultModelFromJson(dynamic json) {
  if (json is Map) {
    return ActionResultModel.fromJson(Map<String, dynamic>.from(json));
  }
  return const ActionResultModel();
}

CreateVoteModel createVoteModelFromJson(dynamic json) =>
    CreateVoteModel.fromJson(Map<String, dynamic>.from(json as Map));

ShowVoteModel showVoteModelFromJson(dynamic json) =>
    ShowVoteModel.fromJson(Map<String, dynamic>.from(json as Map));

class FavoriteRestaurantModel {
  final int? id;
  final String? name;
  final String? slug;

  const FavoriteRestaurantModel({this.id, this.name, this.slug});

  factory FavoriteRestaurantModel.fromJson(Map<String, dynamic> json) {
    return FavoriteRestaurantModel(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      slug: _asString(json['slug']),
    );
  }
}

class FetchFavoriteRestaurantsModel {
  final List<FavoriteRestaurantModel>? data;

  const FetchFavoriteRestaurantsModel({this.data});

  factory FetchFavoriteRestaurantsModel.fromJson(Map<String, dynamic> json) {
    return FetchFavoriteRestaurantsModel(
      data: json['data'] is List
          ? (json['data'] as List)
                .whereType<Map>()
                .map(
                  (e) => FavoriteRestaurantModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : null,
    );
  }
}

class AddressResourceModel {
  final int? id;
  final String? label;
  final String? city;
  final String? neighborhood;
  final String? street;
  final String? building;
  final String? floor;
  final String? directions;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  const AddressResourceModel({
    this.id,
    this.label,
    this.city,
    this.neighborhood,
    this.street,
    this.building,
    this.floor,
    this.directions,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  factory AddressResourceModel.fromJson(Map<String, dynamic> json) {
    return AddressResourceModel(
      id: _asInt(json['id']),
      label: _asString(json['label']),
      city: _asString(json['city']),
      neighborhood: _asString(json['neighborhood']),
      street: _asString(json['street']),
      building: _asString(json['building']),
      floor: _asString(json['floor']),
      directions: _asString(json['directions']),
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      isDefault: _asBool(json['isDefault']),
    );
  }
}

class FetchAddressesModel {
  final List<AddressResourceModel>? addresses;

  const FetchAddressesModel({this.addresses});

  factory FetchAddressesModel.fromJson(Map<String, dynamic> json) {
    return FetchAddressesModel(
      addresses: json['addresses'] is List
          ? (json['addresses'] as List)
                .whereType<Map>()
                .map(
                  (e) => AddressResourceModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : null,
    );
  }
}

class NotificationResourceModel {
  final String? id;
  final String? type;
  final String? title;
  final String? body;
  final String? readAt;
  final String? createdAt;

  const NotificationResourceModel({
    this.id,
    this.type,
    this.title,
    this.body,
    this.readAt,
    this.createdAt,
  });

  factory NotificationResourceModel.fromJson(Map<String, dynamic> json) {
    return NotificationResourceModel(
      id: _asString(json['id']),
      type: _asString(json['type']),
      title: _asString(json['title']),
      body: _asString(json['body']),
      readAt: _asString(json['readAt']),
      createdAt: _asString(json['createdAt']),
    );
  }
}

class PaginationMetaModel {
  final int? currentPage;
  final int? perPage;
  final int? total;

  const PaginationMetaModel({this.currentPage, this.perPage, this.total});

  factory PaginationMetaModel.fromJson(Map<String, dynamic> json) {
    return PaginationMetaModel(
      currentPage: _asInt(json['current_page']),
      perPage: _asInt(json['per_page']),
      total: _asInt(json['total']),
    );
  }
}

class FetchNotificationsPageModel {
  final List<NotificationResourceModel>? data;
  final PaginationMetaModel? meta;

  const FetchNotificationsPageModel({this.data, this.meta});

  factory FetchNotificationsPageModel.fromJson(Map<String, dynamic> json) {
    return FetchNotificationsPageModel(
      data: json['data'] is List
          ? (json['data'] as List)
                .whereType<Map>()
                .map(
                  (e) => NotificationResourceModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : null,
      meta: json['meta'] is Map
          ? PaginationMetaModel.fromJson(
              Map<String, dynamic>.from(json['meta'] as Map),
            )
          : null,
    );
  }
}

class ActionResultModel {
  final String? message;

  const ActionResultModel({this.message});

  factory ActionResultModel.fromJson(Map<String, dynamic> json) {
    return ActionResultModel(message: _asString(json['message']));
  }
}

class CreateVoteModel {
  final int? voteId;
  final String? message;

  const CreateVoteModel({this.voteId, this.message});

  factory CreateVoteModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    int? id;
    if (data is Map && data['vote'] is Map) {
      id = _asInt((data['vote'] as Map)['id']);
    } else if (json['vote'] is Map) {
      id = _asInt((json['vote'] as Map)['id']);
    }
    return CreateVoteModel(voteId: id, message: _asString(json['message']));
  }
}

class ShowVoteModel {
  final int? voteId;
  final String? winnerLabel;
  final Map<String, dynamic>? rawData;

  const ShowVoteModel({this.voteId, this.winnerLabel, this.rawData});

  factory ShowVoteModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : <String, dynamic>{};
    final winner = data['winner'] is Map
        ? Map<String, dynamic>.from(data['winner'] as Map)
        : <String, dynamic>{};
    return ShowVoteModel(
      voteId: _asInt(data['id']),
      winnerLabel: _asString(winner['label']),
      rawData: data,
    );
  }
}
