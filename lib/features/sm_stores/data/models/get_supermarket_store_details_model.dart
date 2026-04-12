import 'sm_store_product_summary.dart';

String? _asString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is num || value is bool) return value.toString();
  return null;
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? double.tryParse(value)?.toInt();
  }
  return null;
}

bool? _asBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) {
    if (value == 1) return true;
    if (value == 0) return false;
  }
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return null;
}

dynamic _asDynamic(dynamic value) {
  if (value == null) return null;
  if (value is List) {
    return value.map(_asDynamic).toList();
  }
  if (value is Map) {
    final map = <String, dynamic>{};
    value.forEach((key, nestedValue) {
      map['$key'] = _asDynamic(nestedValue);
    });
    return map;
  }
  if (value is String || value is num || value is bool) {
    return value;
  }
  return value.toString();
}

class SupermarketStoreDetailsOwner {
  int? id;
  String? name;
  String? email;
  dynamic phone;
  dynamic phoneVerifiedAt;
  dynamic moduleType;
  String? emailVerifiedAt;
  String? createdAt;
  String? updatedAt;

  SupermarketStoreDetailsOwner({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.phoneVerifiedAt,
    this.moduleType,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory SupermarketStoreDetailsOwner.fromJson(Map<String, dynamic> json) {
    return SupermarketStoreDetailsOwner(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      email: _asString(json['email']),
      phone: _asDynamic(json['phone']),
      phoneVerifiedAt: _asDynamic(json['phoneVerifiedAt']),
      moduleType: _asDynamic(json['moduleType']),
      emailVerifiedAt: _asString(json['emailVerifiedAt']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'phoneVerifiedAt': phoneVerifiedAt,
    'moduleType': moduleType,
    'emailVerifiedAt': emailVerifiedAt,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

GetSupermarketStoreDetailsModel getSupermarketStoreDetailsModelFromJson(
  dynamic str,
) =>
    GetSupermarketStoreDetailsModel.fromJson(
      str is Map<String, dynamic>
          ? str
          : Map<String, dynamic>.from(str as Map),
    );

class GetSupermarketStoreDetailsModel {
  SupermarketStoreDetailsStore? store;

  GetSupermarketStoreDetailsModel({this.store});

  factory GetSupermarketStoreDetailsModel.fromJson(Map<String, dynamic> json) {
    return GetSupermarketStoreDetailsModel(
      store: json['store'] is Map
          ? SupermarketStoreDetailsStore.fromJson(
              Map<String, dynamic>.from(json['store'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {'store': store?.toJson()};
}

class SupermarketStoreDetailsStore {
  int? id;
  int? ownerUserId;
  SupermarketStoreDetailsOwner? owner;
  String? name;
  String? slug;
  String? description;
  String? address;
  dynamic city;
  dynamic neighborhood;
  String? latitude;
  String? longitude;
  String? phone;
  String? email;
  dynamic cover;
  dynamic logo;
  String? averageRating;
  int? totalReviews;
  int? trustScore;
  int? warningCount;
  bool? isActive;
  bool? isFeatured;
  bool? isFavorited;
  dynamic suspensionUntil;
  dynamic distanceKm;
  dynamic highestOfferDiscountValue;
  dynamic highestOffer;
  String? createdAt;
  String? updatedAt;

  List<SupermarketStoreDetailsHour>? storeHours;
  List<SupermarketStoreDetailsCategory>? categories;
  List<SmStoreProductSummary>? products;
  List<SupermarketStoreDetailsOffer>? offers;

  SupermarketStoreDetailsStore({
    this.id,
    this.ownerUserId,
    this.owner,
    this.name,
    this.slug,
    this.description,
    this.address,
    this.city,
    this.neighborhood,
    this.latitude,
    this.longitude,
    this.phone,
    this.email,
    this.cover,
    this.logo,
    this.averageRating,
    this.totalReviews,
    this.trustScore,
    this.warningCount,
    this.isActive,
    this.isFeatured,
    this.isFavorited,
    this.suspensionUntil,
    this.distanceKm,
    this.highestOfferDiscountValue,
    this.highestOffer,
    this.createdAt,
    this.updatedAt,
    this.storeHours,
    this.categories,
    this.products,
    this.offers,
  });

  factory SupermarketStoreDetailsStore.fromJson(Map<String, dynamic> json) {
    return SupermarketStoreDetailsStore(
      id: _asInt(json['id']),
      ownerUserId: _asInt(json['ownerUserId']),
      owner: json['owner'] is Map
          ? SupermarketStoreDetailsOwner.fromJson(
              Map<String, dynamic>.from(json['owner'] as Map),
            )
          : null,
      name: _asString(json['name']),
      slug: _asString(json['slug']),
      description: _asString(json['description']),
      address: _asString(json['address']),
      city: _asDynamic(json['city']),
      neighborhood: _asDynamic(json['neighborhood']),
      latitude: _asString(json['latitude']),
      longitude: _asString(json['longitude']),
      phone: _asString(json['phone']),
      email: _asString(json['email']),
      cover: _asDynamic(json['cover']),
      logo: _asDynamic(json['logo']),
      averageRating: _asString(json['averageRating']),
      totalReviews: _asInt(json['totalReviews']),
      trustScore: _asInt(json['trustScore']),
      warningCount: _asInt(json['warningCount']),
      isActive: _asBool(json['isActive']),
      isFeatured: _asBool(json['isFeatured']),
      isFavorited: _asBool(json['isFavorited']),
      suspensionUntil: _asDynamic(json['suspensionUntil']),
      distanceKm: _asDynamic(json['distanceKm']),
      highestOfferDiscountValue: _asDynamic(json['highestOfferDiscountValue']),
      highestOffer: _asDynamic(json['highestOffer']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
      storeHours: json['storeHours'] is List
          ? (json['storeHours'] as List)
                .whereType<Map>()
                .map(
                  (e) => SupermarketStoreDetailsHour.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : null,
      categories: json['categories'] is List
          ? (json['categories'] as List)
                .whereType<Map>()
                .map(
                  (e) => SupermarketStoreDetailsCategory.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : null,
      products: json['products'] is List
          ? (json['products'] as List)
                .whereType<Map>()
                .map(
                  (e) => SmStoreProductSummary.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : null,
      offers: json['offers'] is List
          ? (json['offers'] as List)
                .whereType<Map>()
                .map(
                  (e) => SupermarketStoreDetailsOffer.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerUserId': ownerUserId,
      'owner': owner?.toJson(),
      'name': name,
      'slug': slug,
      'description': description,
      'address': address,
      'city': city,
      'neighborhood': neighborhood,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'email': email,
      'cover': cover,
      'logo': logo,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'trustScore': trustScore,
      'warningCount': warningCount,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'isFavorited': isFavorited,
      'suspensionUntil': suspensionUntil,
      'distanceKm': distanceKm,
      'highestOfferDiscountValue': highestOfferDiscountValue,
      'highestOffer': highestOffer,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'storeHours': storeHours?.map((e) => e.toJson()).toList(),
      'categories': categories?.map((e) => e.toJson()).toList(),
      'products': products?.map((e) => e.toJson()).toList(),
      'offers': offers?.map((e) => e.toJson()).toList(),
    };
  }
}

class SupermarketStoreDetailsHour {
  int? id;
  int? storeId;
  int? dayOfWeek;
  String? opensAt;
  String? closesAt;
  bool? isClosed;
  String? createdAt;
  String? updatedAt;

  SupermarketStoreDetailsHour({
    this.id,
    this.storeId,
    this.dayOfWeek,
    this.opensAt,
    this.closesAt,
    this.isClosed,
    this.createdAt,
    this.updatedAt,
  });

  factory SupermarketStoreDetailsHour.fromJson(Map<String, dynamic> json) {
    return SupermarketStoreDetailsHour(
      id: _asInt(json['id']),
      storeId: _asInt(json['storeId']),
      dayOfWeek: _asInt(json['dayOfWeek']),
      opensAt: _asString(json['opensAt']),
      closesAt: _asString(json['closesAt']),
      isClosed: _asBool(json['isClosed']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'storeId': storeId,
    'dayOfWeek': dayOfWeek,
    'opensAt': opensAt,
    'closesAt': closesAt,
    'isClosed': isClosed,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

class SupermarketStoreDetailsCategory {
  int? id;
  int? storeId;
  String? name;
  String? slug;
  String? description;
  int? sortOrder;
  String? imagePath;
  bool? isActive;
  int? productsCount;
  String? createdAt;
  String? updatedAt;

  SupermarketStoreDetailsCategory({
    this.id,
    this.storeId,
    this.name,
    this.slug,
    this.description,
    this.sortOrder,
    this.imagePath,
    this.isActive,
    this.productsCount,
    this.createdAt,
    this.updatedAt,
  });

  factory SupermarketStoreDetailsCategory.fromJson(Map<String, dynamic> json) {
    return SupermarketStoreDetailsCategory(
      id: _asInt(json['id']),
      storeId: _asInt(json['storeId']),
      name: _asString(json['name']),
      slug: _asString(json['slug']),
      description: _asString(json['description']),
      sortOrder: _asInt(json['sortOrder']),
      imagePath: _asString(json['imagePath']),
      isActive: _asBool(json['isActive']),
      productsCount: _asInt(json['productsCount']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'storeId': storeId,
    'name': name,
    'slug': slug,
    'description': description,
    'sortOrder': sortOrder,
    'imagePath': imagePath,
    'isActive': isActive,
    'productsCount': productsCount,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

class SupermarketStoreDetailsOffer {
  int? id;
  int? storeId;
  String? name;
  String? description;
  String? offerType;
  dynamic discountValue;
  int? discountPercent;
  String? startsAt;
  String? endsAt;
  bool? isActive;

  SupermarketStoreDetailsOffer({
    this.id,
    this.storeId,
    this.name,
    this.description,
    this.offerType,
    this.discountValue,
    this.discountPercent,
    this.startsAt,
    this.endsAt,
    this.isActive,
  });

  factory SupermarketStoreDetailsOffer.fromJson(Map<String, dynamic> json) {
    return SupermarketStoreDetailsOffer(
      id: _asInt(json['id']),
      storeId: _asInt(json['storeId']),
      name: _asString(json['name']),
      description: _asString(json['description']),
      offerType: _asString(json['offerType']),
      discountValue: _asDynamic(json['discountValue']),
      discountPercent: _asInt(json['discountPercent']),
      startsAt: _asString(json['startsAt']),
      endsAt: _asString(json['endsAt']),
      isActive: _asBool(json['isActive']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'storeId': storeId,
    'name': name,
    'description': description,
    'offerType': offerType,
    'discountValue': discountValue,
    'discountPercent': discountPercent,
    'startsAt': startsAt,
    'endsAt': endsAt,
    'isActive': isActive,
  };
}

/// Returns `HH:mm` from API values like `08:00:00` or `8:00`.
String supermarketStoreDetailsFormatTimeHm(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '';
  final parts = raw.trim().split(':');
  if (parts.length >= 2) {
    final h = parts[0].padLeft(2, '0');
    final m = parts[1].padLeft(2, '0');
    return '$h:$m';
  }
  return raw.trim();
}

bool _supermarketStoreDetailsHourSameSchedule(
  SupermarketStoreDetailsHour a,
  SupermarketStoreDetailsHour b,
) {
  if (a.isClosed != b.isClosed) return false;
  if (a.isClosed == true) return true;
  return a.opensAt == b.opensAt && a.closesAt == b.closesAt;
}

String _supermarketStoreDetailsHourDayRangeLabelAr(int? startDay, int? endDay) {
  if (startDay == null) return '';
  if (endDay == null || startDay == endDay) {
    return supermarketStoreDetailsHourDayLabelAr(startDay);
  }
  return '${supermarketStoreDetailsHourDayLabelAr(startDay)} - ${supermarketStoreDetailsHourDayLabelAr(endDay)}';
}

List<({int startIdx, int endIdx})> _supermarketStoreDetailsHourGroupConsecutiveSame(
  List<SupermarketStoreDetailsHour> sorted,
) {
  if (sorted.isEmpty) return [];
  final ranges = <({int startIdx, int endIdx})>[];
  var i = 0;
  while (i < sorted.length) {
    var j = i;
    final head = sorted[i];
    while (j + 1 < sorted.length) {
      final next = sorted[j + 1];
      final prev = sorted[j];
      final consecutive =
          (next.dayOfWeek ?? -1) == (prev.dayOfWeek ?? -2) + 1;
      if (!consecutive || !_supermarketStoreDetailsHourSameSchedule(head, next)) {
        break;
      }
      j++;
    }
    ranges.add((startIdx: i, endIdx: j));
    i = j + 1;
  }
  return ranges;
}

typedef SupermarketStoreDetailsHourUiRow = ({String dayLabel, String timeText});

/// Sorted, merged consecutive days with the same hours; [timeText] is `مغلق`,
/// `HH:mm - HH:mm`, or empty when no open/close is set.
List<SupermarketStoreDetailsHourUiRow> supermarketStoreDetailsGroupedHourUiRows(
  Iterable<SupermarketStoreDetailsHour>? storeHours,
) {
  final hours = List<SupermarketStoreDetailsHour>.from(storeHours ?? const [])
    ..sort((a, b) => (a.dayOfWeek ?? 0).compareTo(b.dayOfWeek ?? 0));
  if (hours.isEmpty) return [];
  return _supermarketStoreDetailsHourGroupConsecutiveSame(hours).map((range) {
    final first = hours[range.startIdx];
    final last = hours[range.endIdx];
    final dayLabel =
        _supermarketStoreDetailsHourDayRangeLabelAr(first.dayOfWeek, last.dayOfWeek);
    if (first.isClosed == true) {
      return (dayLabel: dayLabel, timeText: 'مغلق');
    }
    final open = supermarketStoreDetailsFormatTimeHm(first.opensAt);
    final close = supermarketStoreDetailsFormatTimeHm(first.closesAt);
    if (open.isEmpty && close.isEmpty) {
      return (dayLabel: dayLabel, timeText: '');
    }
    return (dayLabel: dayLabel, timeText: '$open - $close');
  }).toList();
}

String _supermarketStoreDetailsHourLineStringFromRow(
  SupermarketStoreDetailsHourUiRow r,
) {
  if (r.timeText.isEmpty) return r.dayLabel;
  return '${r.dayLabel}: ${r.timeText}';
}

/// One string per merged row, e.g. `الأحد - الخميس: 08:00 - 22:00`.
List<String> supermarketStoreDetailsGroupedHourLines(
  Iterable<SupermarketStoreDetailsHour>? storeHours,
) {
  return supermarketStoreDetailsGroupedHourUiRows(storeHours)
      .map(_supermarketStoreDetailsHourLineStringFromRow)
      .toList();
}

String supermarketStoreDetailsHourDayLabelAr(int? dayOfWeek) {
  switch (dayOfWeek) {
    case 0:
      return 'الأحد';
    case 1:
      return 'الإثنين';
    case 2:
      return 'الثلاثاء';
    case 3:
      return 'الأربعاء';
    case 4:
      return 'الخميس';
    case 5:
      return 'الجمعة';
    case 6:
      return 'السبت';
    default:
      return 'يوم ${dayOfWeek ?? '-'}';
  }
}

String supermarketStoreDetailsFormatHourLine(SupermarketStoreDetailsHour h) {
  final day = supermarketStoreDetailsHourDayLabelAr(h.dayOfWeek);
  if (h.isClosed == true) {
    return '$day: مغلق';
  }
  final open = supermarketStoreDetailsFormatTimeHm(h.opensAt);
  final close = supermarketStoreDetailsFormatTimeHm(h.closesAt);
  if (open.isEmpty && close.isEmpty) {
    return day;
  }
  return '$day: $open - $close';
}
