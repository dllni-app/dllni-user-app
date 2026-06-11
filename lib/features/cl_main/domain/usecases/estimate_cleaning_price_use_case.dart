import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/estimate_price_response_model.dart';
import '../models/cleaning_assignment_mode.dart';
import '../models/cleaning_room_size_breakdown.dart';
import '../models/cleaning_type.dart';
import '../models/cl_worker_room_assignment_result.dart';
import '../repository/cl_main_repo.dart';

@lazySingleton
class EstimateCleaningPriceUseCase implements UseCase<EstimatePriceResponseModel, EstimateCleaningPriceParams> {
  final ClMainRepo clMainRepo;

  EstimateCleaningPriceUseCase({required this.clMainRepo});

  @override
  DataResponse<EstimatePriceResponseModel> call(EstimateCleaningPriceParams params) {
    return clMainRepo.estimateCleaningPrice(params);
  }
}

class EstimateCleaningPriceParams with Params {
  final String propertyType;
  final int? bedrooms;
  final int? rooms;
  final int? bathrooms;
  final int? balconies;
  final String? livingRoomSize;
  final CleaningRoomSizeBreakdown? roomSizeBreakdown;
  final CleaningType? cleaningType;
  final double? addressLatitude;
  final double? addressLongitude;
  final int? preferredWorkerId;
  final List<int>? serviceIds;
  final String? eventType;
  final int? guestCount;
  final String? venueType;
  final String? customService;
  final double? hours;
  final String? specialRequirement;
  final String? notes;
  final int? numberOfWorkers;
  final CleaningAssignmentMode assignmentMode;
  final List<Map<String, dynamic>>? workerRoomAssignments;

  EstimateCleaningPriceParams({
    required this.propertyType,
    required this.bedrooms,
    required this.rooms,
    required this.bathrooms,
    this.balconies,
    required this.livingRoomSize,
    this.roomSizeBreakdown,
    this.cleaningType,
    required this.addressLatitude,
    required this.addressLongitude,
    this.preferredWorkerId,
    this.serviceIds,
    this.assignmentMode = CleaningAssignmentMode.preferredWorker,
    this.numberOfWorkers,
    this.workerRoomAssignments,
  }) : eventType = null,
       guestCount = null,
       venueType = null,
       customService = null,
       hours = null,
       specialRequirement = null,
       notes = null;

  EstimateCleaningPriceParams.eventAssistance({
    this.propertyType = 'event_assistance',
    required this.eventType,
    required this.guestCount,
    required this.venueType,
    required this.customService,
    required this.hours,
    this.addressLatitude,
    this.addressLongitude,
    this.preferredWorkerId,
    this.specialRequirement,
    this.notes,
    this.numberOfWorkers,
    this.assignmentMode = CleaningAssignmentMode.openCount,
  }) : bedrooms = null,
       workerRoomAssignments = null,
       rooms = null,
       bathrooms = null,
       balconies = null,
       livingRoomSize = null,
       roomSizeBreakdown = null,
       cleaningType = null,
       serviceIds = null;

  bool get _isEventAssistance => propertyType == 'event_assistance';

  List<int> _sanitizeServiceIds() {
    final source = serviceIds ?? const <int>[];
    return source.where((id) => id > 0).toSet().toList(growable: false);
  }

  int? get _resolvedBedrooms => roomSizeBreakdown?.legacyBedroomsCount ?? bedrooms;

  int? get _resolvedRooms => roomSizeBreakdown?.legacyRoomsCount ?? rooms;

  int? get _resolvedBathrooms => roomSizeBreakdown?.legacyBathroomsCount ?? bathrooms;

  int? get _resolvedBalconies => roomSizeBreakdown?.legacyBalconiesCount ?? balconies;

  String get _resolvedLivingRoomSize => roomSizeBreakdown?.legacyLivingRoomSize ?? livingRoomSize ?? CleaningRoomSize.small.apiValue;

  Map<String, dynamic> _buildPropertyDetails() {
    if (_isEventAssistance) {
      return {
        'eventType': eventType,
        'guestCount': guestCount,
        'venueType': venueType,
        'customService': customService?.trim(),
        'hours': hours,
        if (specialRequirement != null && specialRequirement!.trim().isNotEmpty) 'specialRequirement': specialRequirement!.trim(),
        if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
      };
    }
    return {
      'bedrooms': _resolvedBedrooms,
      'rooms': _resolvedRooms,
      'bathrooms': _resolvedBathrooms,
      if (_resolvedBalconies != null) 'balconies': _resolvedBalconies,
      'living_room_size': _resolvedLivingRoomSize,
      if (roomSizeBreakdown != null) 'room_size_breakdown': roomSizeBreakdown!.toBackendJson(),
      if (cleaningType != null) 'cleaning_mode': cleaningType!.cleaningModeValue,
    };
  }

  Map<String, dynamic> _buildBody() {
    final body = <String, dynamic>{
      'propertyType': propertyType,
      'propertyDetails': _buildPropertyDetails(),
      if (addressLatitude != null) 'addressLatitude': addressLatitude,
      if (addressLongitude != null) 'addressLongitude': addressLongitude,
      'assignmentMode': assignmentMode.apiValue,
      if (preferredWorkerId != null && assignmentMode == CleaningAssignmentMode.preferredWorker) 'preferredWorkerId': preferredWorkerId,
    };
    if (!_isEventAssistance) {
      final cleanServiceIds = _sanitizeServiceIds();
      if (cleanServiceIds.isNotEmpty) {
        body['serviceIds'] = cleanServiceIds;
      }
    }
    final resolvedWorkers = _resolvedNumberOfWorkers;
    if (resolvedWorkers != null && resolvedWorkers > 0) {
      body['numberOfWorkers'] = resolvedWorkers;
    }
    final assignments = workerRoomAssignments == null
        ? null
        : filterNonEmptyWorkerRoomAssignmentMaps(workerRoomAssignments!);
    if (assignments != null && assignments.isNotEmpty) {
      body['workerRoomAssignments'] = assignments;
    }
    return body;
  }

  int? get _resolvedNumberOfWorkers {
    if (_isEventAssistance) {
      return numberOfWorkers;
    }
    if (assignmentMode == CleaningAssignmentMode.openCount) {
      return numberOfWorkers ?? 1;
    }
    return 1;
  }

  @override
  BodyMap getBody() {
    return _buildBody();
  }
}
