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

VoteSuggestionsModel voteSuggestionsModelFromJson(dynamic json) =>
    VoteSuggestionsModel.fromJson(Map<String, dynamic>.from(json as Map));

ShowVoteModel showVoteModelFromJson(dynamic json) =>
    ShowVoteModel.fromJson(Map<String, dynamic>.from(json as Map));

FetchActiveVotesModel fetchActiveVotesModelFromJson(dynamic json) =>
    FetchActiveVotesModel.fromJson(Map<String, dynamic>.from(json as Map));

UpdateAccountModel updateAccountModelFromJson(dynamic json) =>
    UpdateAccountModel.fromJson(Map<String, dynamic>.from(json as Map));

FetchCouponsModel fetchCouponsModelFromJson(dynamic json) =>
    FetchCouponsModel.fromJson(Map<String, dynamic>.from(json as Map));

DateTime? _asDateTime(dynamic value) {
  final raw = _asString(value);
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw.replaceFirst(' ', 'T'));
}

class CouponRestaurantModel {
  final int? id;
  final String? name;
  final String? imageUrl;

  const CouponRestaurantModel({this.id, this.name, this.imageUrl});

  factory CouponRestaurantModel.fromJson(Map<String, dynamic> json) {
    return CouponRestaurantModel(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      imageUrl: _asString(json['imageUrl']),
    );
  }
}

class RestaurantCouponModel {
  final int? id;
  final String? code;
  final String? discountType;
  final double? discountValue;
  final int? minOrderAmount;
  final int? usageLimit;
  final int? usageCount;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool isActive;
  final CouponRestaurantModel? restaurant;

  const RestaurantCouponModel({
    this.id,
    this.code,
    this.discountType,
    this.discountValue,
    this.minOrderAmount,
    this.usageLimit,
    this.usageCount,
    this.startsAt,
    this.endsAt,
    this.isActive = false,
    this.restaurant,
  });

  factory RestaurantCouponModel.fromJson(Map<String, dynamic> json) {
    return RestaurantCouponModel(
      id: _asInt(json['id']),
      code: _asString(json['code']),
      discountType: _asString(json['discountType']),
      discountValue: _asDouble(json['discountValue']),
      minOrderAmount: _asInt(json['minOrderAmount']),
      usageLimit: _asInt(json['usageLimit']),
      usageCount: _asInt(json['usageCount']),
      startsAt: _asDateTime(json['startsAt']),
      endsAt: _asDateTime(json['endsAt']),
      isActive: _asBool(json['isActive']),
      restaurant: json['restaurant'] is Map
          ? CouponRestaurantModel.fromJson(
              Map<String, dynamic>.from(json['restaurant'] as Map),
            )
          : null,
    );
  }
}

class FetchCouponsModel {
  final List<RestaurantCouponModel> coupons;

  const FetchCouponsModel({this.coupons = const <RestaurantCouponModel>[]});

  factory FetchCouponsModel.fromJson(Map<String, dynamic> json) {
    return FetchCouponsModel(
      coupons: json['coupons'] is List
          ? (json['coupons'] as List)
                .whereType<Map>()
                .map(
                  (e) => RestaurantCouponModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : const <RestaurantCouponModel>[],
    );
  }
}

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
  final String? mobile;
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
    this.mobile,
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
      mobile: _asString(json['mobile']),
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

class AccountImageModel {
  final int? id;
  final String? name;
  final String? fileName;
  final String? collection;
  final String? url;
  final String? thumbnailUrl;
  final String? size;
  final String? extension;
  final String? type;
  final String? caption;
  final String? createdAt;

  const AccountImageModel({
    this.id,
    this.name,
    this.fileName,
    this.collection,
    this.url,
    this.thumbnailUrl,
    this.size,
    this.extension,
    this.type,
    this.caption,
    this.createdAt,
  });

  factory AccountImageModel.fromJson(Map<String, dynamic> json) {
    return AccountImageModel(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      fileName: _asString(json['fileName']),
      collection: _asString(json['collection']),
      url: _asString(json['url']),
      thumbnailUrl: _asString(json['thumbnailUrl']),
      size: _asString(json['size']),
      extension: _asString(json['extension']),
      type: _asString(json['type']),
      caption: _asString(json['caption']),
      createdAt: _asString(json['createdAt']),
    );
  }
}

class AccountUserModel {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? phoneVerifiedAt;
  final String? moduleType;
  final String? emailVerifiedAt;
  final AccountImageModel? primaryImage;
  final List<AccountImageModel> images;
  final String? createdAt;
  final String? updatedAt;

  const AccountUserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.phoneVerifiedAt,
    this.moduleType,
    this.emailVerifiedAt,
    this.primaryImage,
    this.images = const <AccountImageModel>[],
    this.createdAt,
    this.updatedAt,
  });

  factory AccountUserModel.fromJson(Map<String, dynamic> json) {
    return AccountUserModel(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      email: _asString(json['email']),
      phone: _asString(json['phone']),
      phoneVerifiedAt: _asString(json['phoneVerifiedAt']),
      moduleType: _asString(json['moduleType']),
      emailVerifiedAt: _asString(json['emailVerifiedAt']),
      primaryImage: json['primaryImage'] is Map
          ? AccountImageModel.fromJson(
              Map<String, dynamic>.from(json['primaryImage'] as Map),
            )
          : null,
      images: json['images'] is List
          ? (json['images'] as List)
                .whereType<Map>()
                .map(
                  (e) =>
                      AccountImageModel.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const <AccountImageModel>[],
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
    );
  }
}

class UpdateAccountModel {
  final AccountUserModel? user;

  const UpdateAccountModel({this.user});

  factory UpdateAccountModel.fromJson(Map<String, dynamic> json) {
    return UpdateAccountModel(
      user: json['user'] is Map
          ? AccountUserModel.fromJson(
              Map<String, dynamic>.from(json['user'] as Map),
            )
          : null,
    );
  }
}

class VoteCuisineTypeModel {
  final int? id;
  final String? name;
  final String? slug;

  const VoteCuisineTypeModel({this.id, this.name, this.slug});

  factory VoteCuisineTypeModel.fromJson(Map<String, dynamic> json) {
    return VoteCuisineTypeModel(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      slug: _asString(json['slug']),
    );
  }
}

class VoteProductSuggestionModel {
  final int? id;
  final String? name;
  final double? unitPrice;
  final int? restaurantId;
  final String? restaurantName;

  const VoteProductSuggestionModel({
    this.id,
    this.name,
    this.unitPrice,
    this.restaurantId,
    this.restaurantName,
  });

  factory VoteProductSuggestionModel.fromJson(Map<String, dynamic> json) {
    return VoteProductSuggestionModel(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      unitPrice: _asDouble(json['unitPrice']),
      restaurantId: _asInt(json['restaurantId']),
      restaurantName: _asString(json['restaurantName']),
    );
  }
}

class VoteSuggestionsModel {
  final List<int> durationMinutesPresets;
  final List<VoteCuisineTypeModel> cuisineTypes;
  final List<VoteProductSuggestionModel> suggestions;

  const VoteSuggestionsModel({
    this.durationMinutesPresets = const <int>[],
    this.cuisineTypes = const <VoteCuisineTypeModel>[],
    this.suggestions = const <VoteProductSuggestionModel>[],
  });

  factory VoteSuggestionsModel.fromJson(Map<String, dynamic> json) {
    final payload = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    return VoteSuggestionsModel(
      durationMinutesPresets: payload['durationMinutesPresets'] is List
          ? (payload['durationMinutesPresets'] as List)
                .map(_asInt)
                .whereType<int>()
                .toList()
          : const <int>[],
      cuisineTypes: payload['cuisineTypes'] is List
          ? (payload['cuisineTypes'] as List)
                .whereType<Map>()
                .map(
                  (e) => VoteCuisineTypeModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : const <VoteCuisineTypeModel>[],
      suggestions: payload['suggestions'] is List
          ? (payload['suggestions'] as List)
                .whereType<Map>()
                .map(
                  (e) => VoteProductSuggestionModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : const <VoteProductSuggestionModel>[],
    );
  }
}

class VoteModel {
  final int? id;
  final String? status;
  final String? foodCategoryHint;
  final int? cuisineTypeId;
  final String? cuisineType;
  final int? durationMinutes;
  final String? endsAt;
  final int? secondsRemaining;
  final int? creatorUserId;
  final bool isCreator;
  final bool isInvited;
  final String? createdAt;

  const VoteModel({
    this.id,
    this.status,
    this.foodCategoryHint,
    this.cuisineTypeId,
    this.cuisineType,
    this.durationMinutes,
    this.endsAt,
    this.secondsRemaining,
    this.creatorUserId,
    this.isCreator = false,
    this.isInvited = false,
    this.createdAt,
  });

  factory VoteModel.fromJson(Map<String, dynamic> json) {
    return VoteModel(
      id: _asInt(json['id']),
      status: _asString(json['status']),
      foodCategoryHint: _asString(json['foodCategoryHint']),
      cuisineTypeId: _asInt(json['cuisineTypeId']),
      cuisineType: _asString(json['cuisineType']),
      durationMinutes: _asInt(json['durationMinutes']),
      endsAt: _asString(json['endsAt']),
      secondsRemaining: _asInt(json['secondsRemaining']),
      creatorUserId: _asInt(json['creatorUserId']),
      isCreator: _asBool(json['isCreator']),
      isInvited: _asBool(json['isInvited']),
      createdAt: _asString(json['createdAt']),
    );
  }
}

class VoteOptionModel {
  final int? id;
  final String? label;
  final int? productId;
  final int? voteCount;
  final double? percent;
  final double? unitPrice;

  const VoteOptionModel({
    this.id,
    this.label,
    this.productId,
    this.voteCount,
    this.percent,
    this.unitPrice,
  });

  factory VoteOptionModel.fromJson(Map<String, dynamic> json) {
    final voteCount =
        _asInt(json['voteCount']) ??
        _asInt(json['vote_count']) ??
        _asInt(json['votes']);
    return VoteOptionModel(
      id: _asInt(json['id']),
      label: _asString(json['label']),
      productId: _asInt(json['productId']),
      voteCount: voteCount,
      percent: _asDouble(json['percent']),
      unitPrice: _asDouble(json['unitPrice']),
    );
  }
}

class VoteVoterModel {
  final int? id;
  final String? name;
  final Map<String, dynamic>? rawData;

  const VoteVoterModel({this.id, this.name, this.rawData});

  factory VoteVoterModel.fromJson(Map<String, dynamic> json) {
    return VoteVoterModel(
      id: _asInt(json['id']),
      name:
          _asString(json['name']) ??
          _asString(json['fullName']) ??
          _asString(json['displayName']),
      rawData: json,
    );
  }
}

class VoteWinnerModel {
  final int? id;
  final String? label;
  final int? productId;

  const VoteWinnerModel({this.id, this.label, this.productId});

  factory VoteWinnerModel.fromJson(Map<String, dynamic> json) {
    return VoteWinnerModel(
      id: _asInt(json['id']),
      label: _asString(json['label']),
      productId: _asInt(json['productId']),
    );
  }
}

class VoteCreatedData {
  final VoteModel? vote;
  final List<VoteOptionModel> options;
  final List<VoteVoterModel> voters;
  final VoteWinnerModel? winner;

  const VoteCreatedData({
    this.vote,
    this.options = const <VoteOptionModel>[],
    this.voters = const <VoteVoterModel>[],
    this.winner,
  });

  factory VoteCreatedData.fromJson(Map<String, dynamic> json) {
    return VoteCreatedData(
      vote: json['vote'] is Map
          ? VoteModel.fromJson(Map<String, dynamic>.from(json['vote'] as Map))
          : null,
      options: json['options'] is List
          ? (json['options'] as List)
                .whereType<Map>()
                .map(
                  (e) => VoteOptionModel.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const <VoteOptionModel>[],
      voters: json['voters'] is List
          ? (json['voters'] as List).map((e) {
              if (e is Map) {
                return VoteVoterModel.fromJson(Map<String, dynamic>.from(e));
              }
              return VoteVoterModel(name: _asString(e));
            }).toList()
          : const <VoteVoterModel>[],
      winner: json['winner'] is Map
          ? VoteWinnerModel.fromJson(
              Map<String, dynamic>.from(json['winner'] as Map),
            )
          : null,
    );
  }
}

class CreateVoteModel {
  final String? message;
  final VoteCreatedData? data;

  const CreateVoteModel({this.message, this.data});

  int? get voteId => data?.vote?.id;

  factory CreateVoteModel.fromJson(Map<String, dynamic> json) {
    final payload = json['data'] is Map
        ? VoteCreatedData.fromJson(
            Map<String, dynamic>.from(json['data'] as Map),
          )
        : (json['vote'] is Map
              ? VoteCreatedData.fromJson(<String, dynamic>{
                  'vote': json['vote'],
                })
              : null);
    return CreateVoteModel(message: _asString(json['message']), data: payload);
  }
}

class FetchActiveVotesModel {
  final List<VoteCreatedData> data;

  const FetchActiveVotesModel({this.data = const <VoteCreatedData>[]});

  factory FetchActiveVotesModel.fromJson(Map<String, dynamic> json) {
    return FetchActiveVotesModel(
      data: json['data'] is List
          ? (json['data'] as List)
                .whereType<Map>()
                .map(
                  (e) => VoteCreatedData.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const <VoteCreatedData>[],
    );
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
