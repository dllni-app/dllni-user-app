import 'dart:convert';

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

EstimatePriceResponseModel estimatePriceResponseModelFromJson(dynamic json) {
  if (json is String && json.isNotEmpty) {
    return EstimatePriceResponseModel.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    );
  }
  if (json is Map<String, dynamic>) {
    return EstimatePriceResponseModel.fromJson(json);
  }
  return const EstimatePriceResponseModel();
}

class EstimatePriceResponseModel {
  final EstimateSizeModel? size;
  final EstimatePricingModel? pricing;
  final EstimateQuoteModel? quote;
  final EstimateRecommendationModel? recommendation;
  final EstimateWorkerAcceptanceModel? workerAcceptance;
  final CleaningAssignmentMode? assignmentMode;
  final List<CleaningWorkerRoomAssignment> workerRoomAssignments;

  const EstimatePriceResponseModel({
    this.size,
    this.pricing,
    this.quote,
    this.recommendation,
    this.workerAcceptance,
    this.assignmentMode,
    this.workerRoomAssignments = const [],
  });

  int? get suggestedTeamSize =>
      recommendation?.suggestedTeamSize ?? workerAcceptance?.required;

  factory EstimatePriceResponseModel.fromJson(Map<String, dynamic> json) {
    final assignmentModeRaw =
        (json['assignmentMode'] ?? json['assignment_mode']) as String?;
    return EstimatePriceResponseModel(
      size: json['size'] is Map<String, dynamic>
          ? EstimateSizeModel.fromJson(json['size'] as Map<String, dynamic>)
          : null,
      pricing: json['pricing'] is Map<String, dynamic>
          ? EstimatePricingModel.fromJson(
              json['pricing'] as Map<String, dynamic>,
            )
          : null,
      quote: json['quote'] is Map<String, dynamic>
          ? EstimateQuoteModel.fromJson(json['quote'] as Map<String, dynamic>)
          : null,
      recommendation: json['recommendation'] is Map<String, dynamic>
          ? EstimateRecommendationModel.fromJson(
              json['recommendation'] as Map<String, dynamic>,
            )
          : null,
      workerAcceptance:
          json['workerAcceptance'] is Map<String, dynamic> ||
              json['worker_acceptance'] is Map<String, dynamic>
          ? EstimateWorkerAcceptanceModel.fromJson(
              (json['workerAcceptance'] ?? json['worker_acceptance'])
                  as Map<String, dynamic>,
            )
          : null,
      assignmentMode: assignmentModeRaw == null
          ? null
          : CleaningAssignmentModeX.fromApi(assignmentModeRaw),
      workerRoomAssignments: parseWorkerRoomAssignments(
        json['workerRoomAssignments'] ?? json['worker_room_assignments'],
      ),
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
              .whereType<Map<String, dynamic>>()
              .map(EstimateServiceLineModel.fromJson)
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
