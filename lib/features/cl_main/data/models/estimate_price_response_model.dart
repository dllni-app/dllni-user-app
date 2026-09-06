import 'dart:convert';

import '../../../../core/models/cleaning_service_extras.dart';
import '../../domain/models/cleaning_assignment_mode.dart';
import '../../domain/models/cl_worker_room_assignment_result.dart';

double? _toDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

bool? _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) {
    if (value == 1) return true;
    if (value == 0) return false;
  }
  final normalized = value?.toString().trim().toLowerCase();
  if (normalized == 'true' || normalized == '1') return true;
  if (normalized == 'false' || normalized == '0') return false;
  return null;
}

Map<String, dynamic> _toMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return const <String, dynamic>{};
}

EstimatePriceResponseModel estimatePriceResponseModelFromJson(dynamic json) {
  if (json is String && json.isNotEmpty) {
    return EstimatePriceResponseModel.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    );
  }
  if (json is Map<String, dynamic>) {
    return EstimatePriceResponseModel.fromJson(json);
  }
  if (json is Map) {
    return EstimatePriceResponseModel.fromJson(_toMap(json));
  }
  return const EstimatePriceResponseModel();
}

class EstimatePriceResponseModel {
  final EstimateSizeModel? size;
  final EstimatePricingModel? pricing;
  final EstimateScheduleModel? schedule;
  final EstimateQuoteModel? quote;
  final EstimateRecommendationModel? recommendation;
  final EstimateWorkerAcceptanceModel? workerAcceptance;
  final CleaningAssignmentMode? assignmentMode;
  final int? requiredWorkers;
  final double? maxHoursPerWorker;
  final List<CleaningWorkerRoomAssignment> workerRoomAssignments;
  final List<CleaningMaterialLineModel> materials;
  final List<CleaningSpecialServiceLineModel> specialServices;
  final CleaningOpenTimeModel? openTime;

  const EstimatePriceResponseModel({
    this.size,
    this.pricing,
    this.schedule,
    this.quote,
    this.recommendation,
    this.workerAcceptance,
    this.assignmentMode,
    this.requiredWorkers,
    this.maxHoursPerWorker,
    this.workerRoomAssignments = const [],
    this.materials = const <CleaningMaterialLineModel>[],
    this.specialServices = const <CleaningSpecialServiceLineModel>[],
    this.openTime,
  });

  int? get suggestedTeamSize =>
      recommendation?.suggestedTeamSize ?? workerAcceptance?.required;

  factory EstimatePriceResponseModel.fromJson(Map<String, dynamic> json) {
    final assignmentModeRaw =
        (json['assignmentMode'] ?? json['assignment_mode']) as String?;
    final estimationRaw = json['estimation'];
    final estimation = estimationRaw is Map
        ? _toMap(estimationRaw)
        : const <String, dynamic>{};
    return EstimatePriceResponseModel(
      size: json['size'] is Map
          ? EstimateSizeModel.fromJson(_toMap(json['size']))
          : null,
      pricing: json['pricing'] is Map
          ? EstimatePricingModel.fromJson(_toMap(json['pricing']))
          : null,
      schedule: json['schedule'] is Map
          ? EstimateScheduleModel.fromJson(_toMap(json['schedule']))
          : null,
      quote: json['quote'] is Map
          ? EstimateQuoteModel.fromJson(_toMap(json['quote']))
          : null,
      recommendation: json['recommendation'] is Map
          ? EstimateRecommendationModel.fromJson(_toMap(json['recommendation']))
          : null,
      workerAcceptance:
          json['workerAcceptance'] is Map || json['worker_acceptance'] is Map
          ? EstimateWorkerAcceptanceModel.fromJson(
              _toMap(json['workerAcceptance'] ?? json['worker_acceptance']),
            )
          : null,
      assignmentMode: assignmentModeRaw == null
          ? null
          : CleaningAssignmentModeX.fromApi(assignmentModeRaw),
      requiredWorkers: _toInt(
        json['requiredWorkers'] ??
            json['required_workers'] ??
            estimation['requiredWorkers'] ??
            estimation['required_workers'],
      ),
      maxHoursPerWorker: _toDouble(
        json['maxHoursPerWorker'] ??
            json['max_hours_per_worker'] ??
            estimation['maxHoursPerWorker'] ??
            estimation['max_hours_per_worker'],
      ),
      workerRoomAssignments: parseWorkerRoomAssignments(
        json['workerRoomAssignments'] ?? json['worker_room_assignments'],
      ),
      materials: cleaningMaterialLinesFromJson(
        json['materials'] ??
            _toMap(json['pricing'])['materials'] ??
            _toMap(json['pricing'])['material_lines'],
      ),
      specialServices: cleaningSpecialServiceLinesFromJson(
        json['specialServices'] ??
            json['special_services'] ??
            _toMap(json['pricing'])['specialServices'] ??
            _toMap(json['pricing'])['special_services'],
      ),
      openTime: _openTimeFromJson(
        json['openTime'] ??
            json['open_time'] ??
            _toMap(json['pricing'])['openTime'] ??
            _toMap(json['pricing'])['open_time'],
      ),
    );
  }
}

CleaningOpenTimeModel? _openTimeFromJson(dynamic value) {
  return value is Map ? CleaningOpenTimeModel.fromJson(_toMap(value)) : null;
}

class EstimateScheduleModel {
  final String mode;
  final int daysCount;
  final double totalHours;
  final List<EstimateScheduleSessionModel> sessions;

  const EstimateScheduleModel({
    required this.mode,
    required this.daysCount,
    required this.totalHours,
    this.sessions = const <EstimateScheduleSessionModel>[],
  });

  factory EstimateScheduleModel.fromJson(Map<String, dynamic> json) {
    final rawSessions = json['sessions'];
    final sessions = rawSessions is List
        ? rawSessions
              .whereType<Map>()
              .map(
                (item) => EstimateScheduleSessionModel.fromJson(_toMap(item)),
              )
              .toList(growable: false)
        : const <EstimateScheduleSessionModel>[];

    return EstimateScheduleModel(
      mode: (json['mode'] ?? (sessions.length > 1 ? 'multi_day' : 'single_day'))
          .toString(),
      daysCount:
          _toInt(json['daysCount'] ?? json['days_count']) ?? sessions.length,
      totalHours:
          _toDouble(json['totalHours'] ?? json['total_hours']) ??
          sessions.fold<double>(0, (sum, item) => sum + item.hours),
      sessions: sessions,
    );
  }

  EstimateScheduleSessionModel? sessionAt(int index) {
    if (index < 0 || index >= sessions.length) return null;
    return sessions[index];
  }
}

class EstimateScheduleSessionModel {
  final int sequence;
  final String? date;
  final String? time;
  final double hours;
  final double? basePrice;
  final double? travelFee;
  final double? adminMargin;
  final double? totalPrice;

  const EstimateScheduleSessionModel({
    required this.sequence,
    this.date,
    this.time,
    required this.hours,
    this.basePrice,
    this.travelFee,
    this.adminMargin,
    this.totalPrice,
  });

  factory EstimateScheduleSessionModel.fromJson(Map<String, dynamic> json) {
    return EstimateScheduleSessionModel(
      sequence: _toInt(json['sequence']) ?? 1,
      date: json['date']?.toString(),
      time: json['time']?.toString(),
      hours: _toDouble(json['hours']) ?? 0,
      basePrice: _toDouble(json['basePrice'] ?? json['base_price']),
      travelFee: _toDouble(json['travelFee'] ?? json['travel_fee']),
      adminMargin: _toDouble(json['adminMargin'] ?? json['admin_margin']),
      totalPrice: _toDouble(json['totalPrice'] ?? json['total_price']),
    );
  }
}

class EstimateWorkerAcceptanceModel {
  final int? required;
  final int? accepted;
  final int? remaining;
  final bool? isFulfilled;

  const EstimateWorkerAcceptanceModel({
    this.required,
    this.accepted,
    this.remaining,
    this.isFulfilled,
  });

  factory EstimateWorkerAcceptanceModel.fromJson(Map<String, dynamic> json) {
    return EstimateWorkerAcceptanceModel(
      required: _toInt(json['required']),
      accepted: _toInt(json['accepted']),
      remaining: _toInt(json['remaining']),
      isFulfilled: _toBool(json['isFulfilled'] ?? json['is_fulfilled']),
    );
  }
}

class EstimateSizeModel {
  final int? estimatedSqm;
  final double? estimatedHours;
  final String? sizeTier;

  const EstimateSizeModel({
    this.estimatedSqm,
    this.estimatedHours,
    this.sizeTier,
  });

  factory EstimateSizeModel.fromJson(Map<String, dynamic> json) {
    return EstimateSizeModel(
      estimatedSqm: (json['estimatedSqm'] as num?)?.toInt(),
      estimatedHours: (json['estimatedHours'] as num?)?.toDouble(),
      sizeTier: json['sizeTier'] as String?,
    );
  }
}

class EstimatePricingModel {
  final double? basePrice;
  final double? travelFee;
  final double? addonsTotal;
  final double? totalPrice;
  final double? distanceKm;
  final double? adminMargin;
  final bool? isPricingFinal;
  final String? currency;
  final double? eventHourlyRate;
  final double? eventHours;
  final List<EstimateServiceLineModel> serviceLines;

  const EstimatePricingModel({
    this.basePrice,
    this.travelFee,
    this.addonsTotal,
    this.totalPrice,
    this.distanceKm,
    this.adminMargin,
    this.isPricingFinal,
    this.currency,
    this.eventHourlyRate,
    this.eventHours,
    this.serviceLines = const <EstimateServiceLineModel>[],
  });

  factory EstimatePricingModel.fromJson(Map<String, dynamic> json) {
    final serviceLinesRaw = json['serviceLines'] ?? json['service_lines'];
    final serviceLines = serviceLinesRaw is List
        ? serviceLinesRaw
              .whereType<Map>()
              .map((item) => EstimateServiceLineModel.fromJson(_toMap(item)))
              .toList(growable: false)
        : const <EstimateServiceLineModel>[];

    return EstimatePricingModel(
      basePrice: _toDouble(json['basePrice'] ?? json['base_price']),
      travelFee: _toDouble(json['travelFee'] ?? json['travel_fee']),
      addonsTotal: _toDouble(json['addonsTotal'] ?? json['addons_total']),
      totalPrice: _toDouble(json['totalPrice'] ?? json['total_price']),
      distanceKm: _toDouble(json['distanceKm'] ?? json['distance_km']),
      adminMargin: _toDouble(json['adminMargin'] ?? json['admin_margin']),
      isPricingFinal: _toBool(
        json['isPricingFinal'] ?? json['is_pricing_final'],
      ),
      currency: json['currency'] as String?,
      eventHourlyRate: _toDouble(
        json['eventHourlyRate'] ?? json['event_hourly_rate'],
      ),
      eventHours: _toDouble(json['eventHours'] ?? json['event_hours']),
      serviceLines: serviceLines,
    );
  }
}

class EstimateServiceLineModel {
  final int? cleaningServiceId;
  final String? name;
  final int? quantity;
  final double? unitPrice;
  final double? totalPrice;
  final double? minHours;

  const EstimateServiceLineModel({
    this.cleaningServiceId,
    this.name,
    this.quantity,
    this.unitPrice,
    this.totalPrice,
    this.minHours,
  });

  factory EstimateServiceLineModel.fromJson(Map<String, dynamic> json) {
    return EstimateServiceLineModel(
      cleaningServiceId: _toInt(
        json['cleaningServiceId'] ?? json['cleaning_service_id'],
      ),
      name: json['name'] as String?,
      quantity: _toInt(json['quantity']),
      unitPrice: _toDouble(json['unitPrice'] ?? json['unit_price']),
      totalPrice: _toDouble(json['totalPrice'] ?? json['total_price']),
      minHours: _toDouble(json['minHours'] ?? json['min_hours']),
    );
  }
}

class EstimateRecommendationModel {
  final String? eventType;
  final int? guestCount;
  final String? venueType;
  final String? customService;
  final double? hours;
  final int? selectedServiceCount;
  final int? suggestedTeamSize;

  const EstimateRecommendationModel({
    this.eventType,
    this.guestCount,
    this.venueType,
    this.customService,
    this.hours,
    this.selectedServiceCount,
    this.suggestedTeamSize,
  });

  factory EstimateRecommendationModel.fromJson(Map<String, dynamic> json) {
    return EstimateRecommendationModel(
      eventType: (json['eventType'] ?? json['event_type']) as String?,
      guestCount: _toInt(json['guestCount'] ?? json['guest_count']),
      venueType: (json['venueType'] ?? json['venue_type']) as String?,
      customService:
          (json['customService'] ?? json['custom_service']) as String?,
      hours: _toDouble(json['hours']),
      selectedServiceCount: _toInt(
        json['selectedServiceCount'] ?? json['selected_service_count'],
      ),
      suggestedTeamSize: _toInt(
        json['suggestedTeamSize'] ?? json['suggested_team_size'],
      ),
    );
  }
}

class EstimateQuoteModel {
  final String? quoteId;
  final String? expiresAt;
  final String? algorithmVersion;

  const EstimateQuoteModel({
    this.quoteId,
    this.expiresAt,
    this.algorithmVersion,
  });

  factory EstimateQuoteModel.fromJson(Map<String, dynamic> json) {
    return EstimateQuoteModel(
      quoteId: (json['quoteId'] ?? json['quote_id']) as String?,
      expiresAt: (json['expiresAt'] ?? json['expires_at']) as String?,
      algorithmVersion:
          (json['algorithmVersion'] ?? json['algorithm_version']) as String?,
    );
  }
}
