import 'dart:convert';

FetchCleaningWorkerProfileModel fetchCleaningWorkerProfileModelFromJson(
  dynamic json,
) {
  if (json is String && json.isNotEmpty) {
    return FetchCleaningWorkerProfileModel.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    );
  }
  if (json is Map<String, dynamic>) {
    return FetchCleaningWorkerProfileModel.fromJson(json);
  }
  return const FetchCleaningWorkerProfileModel();
}

class FetchCleaningWorkerProfileModel {
  const FetchCleaningWorkerProfileModel({this.data});

  final CleaningWorkerProfileModel? data;

  factory FetchCleaningWorkerProfileModel.fromJson(Map<String, dynamic> json) {
    return FetchCleaningWorkerProfileModel(
      data: json['data'] is Map<String, dynamic>
          ? CleaningWorkerProfileModel.fromJson(
              json['data'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class CleaningWorkerProfileModel {
  const CleaningWorkerProfileModel({
    this.id,
    this.userId,
    this.firstName,
    this.gender,
    this.avatar,
    this.bio,
    this.averageRating,
    this.totalCompletedJobs,
    this.trustScore,
    this.acceptanceRate,
    this.cancellationRate,
    this.openDisputesCount,
    this.isActive,
    this.isSuspended,
    this.suspendedUntil,
    this.homeAddress,
    this.homeLatitude,
    this.homeLongitude,
    this.defaultWorkingHours,
    this.user,
    this.zones,
    this.availability,
    this.trustLogs,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int? userId;
  final String? firstName;
  final String? gender;
  final CleaningWorkerAvatarModel? avatar;
  final String? bio;
  final double? averageRating;
  final int? totalCompletedJobs;
  final double? trustScore;
  final double? acceptanceRate;
  final double? cancellationRate;
  final int? openDisputesCount;
  final bool? isActive;
  final bool? isSuspended;
  final String? suspendedUntil;
  final String? homeAddress;
  final double? homeLatitude;
  final double? homeLongitude;
  final Map<String, CleaningWorkerDayAvailabilityModel>? defaultWorkingHours;
  final CleaningWorkerUserModel? user;
  final List<CleaningWorkerZoneModel>? zones;
  final List<CleaningWorkerAvailabilityModel>? availability;
  final List<dynamic>? trustLogs;
  final String? createdAt;
  final String? updatedAt;

  factory CleaningWorkerProfileModel.fromJson(Map<String, dynamic> json) {
    return CleaningWorkerProfileModel(
      id: _asInt(json['id']),
      userId: _asInt(json['userId'] ?? json['user_id']),
      firstName: _asString(json['firstName'] ?? json['first_name']),
      gender: _asString(json['gender']),
      avatar: json['avatar'] is Map<String, dynamic>
          ? CleaningWorkerAvatarModel.fromJson(
              json['avatar'] as Map<String, dynamic>,
            )
          : null,
      bio: _asString(json['bio']),
      averageRating: _asDouble(json['averageRating'] ?? json['average_rating']),
      totalCompletedJobs: _asInt(
        json['totalCompletedJobs'] ?? json['total_completed_jobs'],
      ),
      trustScore: _asDouble(json['trustScore'] ?? json['trust_score']),
      acceptanceRate: _asDouble(
        json['acceptanceRate'] ?? json['acceptance_rate'],
      ),
      cancellationRate: _asDouble(
        json['cancellationRate'] ?? json['cancellation_rate'],
      ),
      openDisputesCount: _asInt(
        json['openDisputesCount'] ?? json['open_disputes_count'],
      ),
      isActive: _asBool(json['isActive'] ?? json['is_active']),
      isSuspended: _asBool(json['isSuspended'] ?? json['is_suspended']),
      suspendedUntil: _asString(
        json['suspendedUntil'] ?? json['suspended_until'],
      ),
      homeAddress: _asString(json['homeAddress'] ?? json['home_address']),
      homeLatitude: _asDouble(json['homeLatitude'] ?? json['home_latitude']),
      homeLongitude: _asDouble(json['homeLongitude'] ?? json['home_longitude']),
      defaultWorkingHours: _parseDefaultWorkingHours(
        json['defaultWorkingHours'],
      ),
      user: json['user'] is Map<String, dynamic>
          ? CleaningWorkerUserModel.fromJson(
              json['user'] as Map<String, dynamic>,
            )
          : null,
      zones: _parseZones(json['zones']),
      availability: _parseAvailability(json['availability']),
      trustLogs: json['trustLogs'] is List
          ? List<dynamic>.from(json['trustLogs'] as List<dynamic>)
          : null,
      createdAt: _asString(json['createdAt'] ?? json['created_at']),
      updatedAt: _asString(json['updatedAt'] ?? json['updated_at']),
    );
  }
}

class CleaningWorkerAvatarModel {
  const CleaningWorkerAvatarModel({
    this.id,
    this.url,
    this.mimeType,
    this.size,
  });

  final int? id;
  final String? url;
  final String? mimeType;
  final int? size;

  factory CleaningWorkerAvatarModel.fromJson(Map<String, dynamic> json) {
    return CleaningWorkerAvatarModel(
      id: _asInt(json['id']),
      url: _asString(json['url']),
      mimeType: _asString(json['mimeType'] ?? json['mime_type']),
      size: _asInt(json['size']),
    );
  }
}

class CleaningWorkerUserModel {
  const CleaningWorkerUserModel({this.id, this.name, this.email, this.phone});

  final int? id;
  final String? name;
  final String? email;
  final String? phone;

  factory CleaningWorkerUserModel.fromJson(Map<String, dynamic> json) {
    return CleaningWorkerUserModel(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      email: _asString(json['email']),
      phone: _asString(json['phone']),
    );
  }
}

class CleaningWorkerZoneModel {
  const CleaningWorkerZoneModel({this.id, this.workerId, this.name, this.city});

  final int? id;
  final int? workerId;
  final String? name;
  final String? city;

  factory CleaningWorkerZoneModel.fromJson(Map<String, dynamic> json) {
    return CleaningWorkerZoneModel(
      id: _asInt(json['id']),
      workerId: _asInt(json['workerId'] ?? json['worker_id']),
      name: _asString(json['name']),
      city: _asString(json['city']),
    );
  }
}

class CleaningWorkerAvailabilityModel {
  const CleaningWorkerAvailabilityModel({
    this.id,
    this.workerId,
    this.day,
    this.from,
    this.to,
  });

  final int? id;
  final int? workerId;
  final String? day;
  final String? from;
  final String? to;

  factory CleaningWorkerAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return CleaningWorkerAvailabilityModel(
      id: _asInt(json['id']),
      workerId: _asInt(json['workerId'] ?? json['worker_id']),
      day: _asString(json['day']),
      from: _asString(json['from']),
      to: _asString(json['to']),
    );
  }
}

class CleaningWorkerDayAvailabilityModel {
  const CleaningWorkerDayAvailabilityModel({this.available, this.data});

  final bool? available;
  final List<Map<String, String>>? data;

  factory CleaningWorkerDayAvailabilityModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawData = json['data'];
    final slots = <Map<String, String>>[];
    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map) {
          final slot = <String, String>{};
          item.forEach((key, value) {
            final keyText = _asString(key);
            final valueText = _asString(value);
            if (keyText != null && valueText != null) {
              slot[keyText] = valueText;
            }
          });
          if (slot.isNotEmpty) {
            slots.add(slot);
          }
        }
      }
    }
    return CleaningWorkerDayAvailabilityModel(
      available: _asBool(json['available']),
      data: slots.isEmpty ? const <Map<String, String>>[] : slots,
    );
  }
}

Map<String, CleaningWorkerDayAvailabilityModel>? _parseDefaultWorkingHours(
  dynamic raw,
) {
  if (raw is! Map) return null;
  final parsed = <String, CleaningWorkerDayAvailabilityModel>{};
  raw.forEach((key, value) {
    if (value is Map<String, dynamic>) {
      parsed['$key'] = CleaningWorkerDayAvailabilityModel.fromJson(value);
      return;
    }
    if (value is Map) {
      parsed['$key'] = CleaningWorkerDayAvailabilityModel.fromJson(
        value.map((k, v) => MapEntry('$k', v)),
      );
    }
  });
  return parsed;
}

List<CleaningWorkerZoneModel>? _parseZones(dynamic raw) {
  if (raw is! List) return null;
  return raw
      .whereType<Map>()
      .map((item) => item.map((k, v) => MapEntry('$k', v)))
      .map(CleaningWorkerZoneModel.fromJson)
      .toList(growable: false);
}

List<CleaningWorkerAvailabilityModel>? _parseAvailability(dynamic raw) {
  if (raw is! List) return null;
  return raw
      .whereType<Map>()
      .map((item) => item.map((k, v) => MapEntry('$k', v)))
      .map(CleaningWorkerAvailabilityModel.fromJson)
      .toList(growable: false);
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? _asDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

bool? _asBool(dynamic value) {
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

String? _asString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is num || value is bool) return '$value';
  return null;
}
