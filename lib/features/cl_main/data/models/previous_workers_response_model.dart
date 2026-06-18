import 'dart:convert';

import '../../../../core/models/cleaning_gender_preference.dart';

PreviousWorkersResponseModel previousWorkersResponseModelFromJson(dynamic json) {
  if (json is String && json.isNotEmpty) {
    return PreviousWorkersResponseModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }
  if (json is Map<String, dynamic>) {
    return PreviousWorkersResponseModel.fromJson(json);
  }
  return const PreviousWorkersResponseModel();
}

class PreviousWorkersResponseModel {
  final List<PreviousWorkerModel>? data;
  final PreviousWorkersLinksModel? links;
  final PreviousWorkersMetaModel? meta;

  const PreviousWorkersResponseModel({
    this.data,
    this.links,
    this.meta,
  });

  factory PreviousWorkersResponseModel.fromJson(Map<String, dynamic> json) {
    final payload = _extractPayload(json);
    return PreviousWorkersResponseModel(
      data: _extractWorkers(payload),
      links: payload['links'] is Map<String, dynamic>
          ? PreviousWorkersLinksModel.fromJson(payload['links'] as Map<String, dynamic>)
          : null,
      meta: payload['meta'] is Map<String, dynamic>
          ? PreviousWorkersMetaModel.fromJson(payload['meta'] as Map<String, dynamic>)
          : null,
    );
  }

  static Map<String, dynamic> _extractPayload(Map<String, dynamic> json) {
    final dataNode = json['data'];
    if (dataNode is Map<String, dynamic>) {
      return dataNode;
    }
    return json;
  }

  static List<PreviousWorkerModel>? _extractWorkers(Map<String, dynamic> payload) {
    final dynamic workersNode = payload['data'] ?? payload['workers'] ?? payload['items'];
    if (workersNode is List) {
      return workersNode.whereType<Map<String, dynamic>>().map(PreviousWorkerModel.fromJson).toList();
    }
    return null;
  }
}

class PreviousWorkerModel {
  final int? id;
  final String? name;
  final String? phone;
  final CleaningGenderPreference? gender;
  final double? rating;
  final int? totalJobs;
  final int? completedJobs;
  final bool? isFavorited;
  final String? lastServiceDate;
  final String? profileImage;
  final List<String>? badges;
  final String? description;
  final PreviousWorkerRatingsModel? ratings;

  const PreviousWorkerModel({
    this.id,
    this.name,
    this.phone,
    this.gender,
    this.rating,
    this.totalJobs,
    this.completedJobs,
    this.isFavorited,
    this.lastServiceDate,
    this.profileImage,
    this.badges,
    this.description,
    this.ratings,
  });

  factory PreviousWorkerModel.fromJson(Map<String, dynamic> json) {
    final ratings = json['ratings'] is Map<String, dynamic>
        ? PreviousWorkerRatingsModel.fromJson(
            json['ratings'] as Map<String, dynamic>,
          )
        : null;
    final averageRating =
        (json['averageRating'] as num?)?.toDouble() ??
        (json['average_rating'] as num?)?.toDouble() ??
        ratings?.average;

    return PreviousWorkerModel(
      id: _extractWorkerId(json),
      name: json['name'] as String? ?? json['full_name'] as String? ?? json['worker_name'] as String?,
      phone: json['phone'] as String?,
      gender: _extractGender(json),
      rating: (json['rating'] as num?)?.toDouble() ?? averageRating,
      totalJobs: (json['totalJobs'] as num?)?.toInt() ?? (json['total_jobs'] as num?)?.toInt(),
      completedJobs:
          (json['completedJobs'] as num?)?.toInt() ??
          (json['completed_jobs'] as num?)?.toInt() ??
          (json['completedJobsWithUser'] as num?)?.toInt() ??
          (json['completed_jobs_with_user'] as num?)?.toInt(),
      isFavorited: json['isFavorited'] as bool? ?? json['is_favorited'] as bool?,
      lastServiceDate:
          json['lastServiceDate'] as String? ??
          json['last_service_date'] as String? ??
          json['lastWorkedDate'] as String? ??
          json['last_worked_date'] as String?,
      profileImage:
          json['profileImage'] as String? ??
          json['profile_image'] as String? ??
          json['avatarUrl'] as String? ??
          json['avatar_url'] as String?,
      badges: (json['badges'] as List?)?.whereType<String>().toList(),
      description: json['description'] as String?,
      ratings: ratings ??
          (averageRating == null
              ? null
              : PreviousWorkerRatingsModel(
                  average: averageRating,
                  count: (json['ratingsCount'] as num?)?.toInt() ??
                      (json['ratings_count'] as num?)?.toInt(),
                )),
    );
  }

  static int? _extractWorkerId(Map<String, dynamic> json) {
    final nestedWorker = json['worker'];
    final dynamic rawId =
        json['id'] ??
        json['worker_id'] ??
        json['workerId'] ??
        json['provider_id'] ??
        (nestedWorker is Map<String, dynamic> ? nestedWorker['id'] ?? nestedWorker['worker_id'] ?? nestedWorker['workerId'] : null);

    if (rawId is num) return rawId.toInt();
    if (rawId is String) return int.tryParse(rawId);
    return null;
  }

  static CleaningGenderPreference? _extractGender(Map<String, dynamic> json) {
    final nestedWorker = json['worker'];
    final profile = json['profile'];
    final dynamic rawGender =
        json['gender'] ??
        json['sex'] ??
        json['worker_gender'] ??
        json['workerGender'] ??
        json['genderPreference'] ??
        json['gender_preference'] ??
        (nestedWorker is Map<String, dynamic>
            ? nestedWorker['gender'] ?? nestedWorker['sex']
            : null) ??
        (profile is Map<String, dynamic> ? profile['gender'] : null);

    return _normalizeGender(rawGender);
  }

  static CleaningGenderPreference? _normalizeGender(dynamic rawGender) {
    final normalized = rawGender?.toString().trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    switch (normalized) {
      case 'male':
      case 'm':
      case 'man':
      case 'عامل':
        return CleaningGenderPreference.male;
      case 'female':
      case 'f':
      case 'woman':
      case 'عاملة':
        return CleaningGenderPreference.female;
      case 'any':
        return CleaningGenderPreference.any;
      default:
        return null;
    }
  }
}

class PreviousWorkerRatingsModel {
  final double? average;
  final int? count;

  const PreviousWorkerRatingsModel({
    this.average,
    this.count,
  });

  factory PreviousWorkerRatingsModel.fromJson(Map<String, dynamic> json) {
    return PreviousWorkerRatingsModel(
      average: (json['average'] as num?)?.toDouble(),
      count: (json['count'] as num?)?.toInt(),
    );
  }
}

class PreviousWorkersLinksModel {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  const PreviousWorkersLinksModel({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  factory PreviousWorkersLinksModel.fromJson(Map<String, dynamic> json) {
    return PreviousWorkersLinksModel(
      first: json['first'] as String?,
      last: json['last'] as String?,
      prev: json['prev'] as String?,
      next: json['next'] as String?,
    );
  }
}

class PreviousWorkersMetaModel {
  final int? currentPage;
  final int? from;
  final int? lastPage;
  final int? perPage;
  final int? to;
  final int? total;

  const PreviousWorkersMetaModel({
    this.currentPage,
    this.from,
    this.lastPage,
    this.perPage,
    this.to,
    this.total,
  });

  factory PreviousWorkersMetaModel.fromJson(Map<String, dynamic> json) {
    return PreviousWorkersMetaModel(
      currentPage: (json['current_page'] as num?)?.toInt(),
      from: (json['from'] as num?)?.toInt(),
      lastPage: (json['last_page'] as num?)?.toInt(),
      perPage: (json['per_page'] as num?)?.toInt(),
      to: (json['to'] as num?)?.toInt(),
      total: (json['total'] as num?)?.toInt(),
    );
  }
}
