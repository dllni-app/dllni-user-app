import 'dart:convert';

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
    return PreviousWorkersResponseModel(
      data: (json['data'] as List?)
          ?.whereType<Map<String, dynamic>>()
          .map(PreviousWorkerModel.fromJson)
          .toList(),
      links: json['links'] is Map<String, dynamic>
          ? PreviousWorkersLinksModel.fromJson(json['links'] as Map<String, dynamic>)
          : null,
      meta: json['meta'] is Map<String, dynamic>
          ? PreviousWorkersMetaModel.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PreviousWorkerModel {
  final int? id;
  final String? name;
  final String? phone;
  final double? rating;
  final int? totalJobs;
  final int? completedJobs;
  final bool? isFavorited;
  final String? lastServiceDate;
  final String? profileImage;
  final List<String>? badges;

  const PreviousWorkerModel({
    this.id,
    this.name,
    this.phone,
    this.rating,
    this.totalJobs,
    this.completedJobs,
    this.isFavorited,
    this.lastServiceDate,
    this.profileImage,
    this.badges,
  });

  factory PreviousWorkerModel.fromJson(Map<String, dynamic> json) {
    return PreviousWorkerModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      totalJobs: (json['totalJobs'] as num?)?.toInt(),
      completedJobs: (json['completedJobs'] as num?)?.toInt(),
      isFavorited: json['isFavorited'] as bool?,
      lastServiceDate: json['lastServiceDate'] as String?,
      profileImage: json['profileImage'] as String?,
      badges: (json['badges'] as List?)?.whereType<String>().toList(),
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
