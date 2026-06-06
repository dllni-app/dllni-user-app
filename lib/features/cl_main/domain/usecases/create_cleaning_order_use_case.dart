import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/models/cleaning_gender_preference.dart';
import '../../data/models/create_cleaning_order_response_model.dart';
import '../models/cleaning_assignment_mode.dart';
import '../models/cleaning_room_size_breakdown.dart';
import '../models/cleaning_type.dart';
import '../repository/cl_main_repo.dart';

@lazySingleton
class CreateCleaningOrderUseCase implements UseCase<CreateCleaningOrderResponseModel, CreateCleaningOrderParams> {
  final ClMainRepo clMainRepo;

  CreateCleaningOrderUseCase({required this.clMainRepo});

  @override
  DataResponse<CreateCleaningOrderResponseModel> call(CreateCleaningOrderParams params) {
    return clMainRepo.createCleaningOrder(params);
  }
}

class CreateCleaningOrderParams with Params {
  final String propertyType;
  final int? bedrooms;
  final int? rooms;
  final int? bathrooms;
  final int? balconies;
  final String? livingRoomSize;
  final CleaningRoomSizeBreakdown? roomSizeBreakdown;
  final CleaningType? cleaningType;
  final String? address;
  final String? locationName;
  final String scheduledDate;
  final String scheduledTime;
  final double? addressLatitude;
  final double? addressLongitude;
  final CleaningGenderPreference genderPreference;
  final int? preferredWorkerId;
  final List<int>? serviceIds;
  final String? eventType;
  final int? guestCount;
  final String? venueType;
  final String? specialRequirement;
  final String? notes;
  final int? numberOfWorkers;
  final CleaningAssignmentMode assignmentMode;
  final bool termsAccepted;
  final List<Map<String, dynamic>>? workerRoomAssignments;

  CreateCleaningOrderParams({
    required this.propertyType,
    required this.bedrooms,
    required this.rooms,
    required this.bathrooms,
    this.balconies,
    required this.livingRoomSize,
    this.roomSizeBreakdown,
    this.cleaningType,
    required this.address,
    required this.locationName,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.addressLatitude,
    required this.addressLongitude,
    this.genderPreference = CleaningGenderPreference.any,
    this.preferredWorkerId,
    this.serviceIds,
    this.assignmentMode = CleaningAssignmentMode.preferredWorker,
    this.numberOfWorkers,
    this.termsAccepted = true,
    this.workerRoomAssignments,
  }) : eventType = null,
       guestCount = null,
       venueType = null,
       specialRequirement = null,
       notes = null;

  CreateCleaningOrderParams.eventAssistance({
    this.propertyType = 'event_assistance',
    required this.scheduledDate,
    required this.scheduledTime,
    required this.eventType,
    required this.guestCount,
    required this.venueType,
    required this.serviceIds,
    this.address,
    this.locationName,
    this.addressLatitude,
    this.addressLongitude,
    this.genderPreference = CleaningGenderPreference.any,
    this.preferredWorkerId,
    this.specialRequirement,
    this.notes,
    this.numberOfWorkers,
    this.assignmentMode = CleaningAssignmentMode.openCount,
    this.termsAccepted = true,
  }) : bedrooms = null,
       workerRoomAssignments = null,
       rooms = null,
       bathrooms = null,
       balconies = null,
       livingRoomSize = null,
       roomSizeBreakdown = null,
       cleaningType = null;

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
        if (address != null && address!.trim().isNotEmpty) 'address': address!.trim(),
        if (locationName != null && locationName!.trim().isNotEmpty) 'location_name': locationName!.trim(),
        'eventType': eventType,
        'guestCount': guestCount,
        'venueType': venueType,
        if (specialRequirement != null && specialRequirement!.trim().isNotEmpty) 'specialRequirement': specialRequirement!.trim(),
        if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
      };
    }
    return {
      'address': address,
      'location_name': locationName,
      'bedrooms': _resolvedBedrooms,
      'rooms': _resolvedRooms,
      'bathrooms': _resolvedBathrooms,
      if (_resolvedBalconies != null) 'balconies': _resolvedBalconies,
      'living_room_size': _resolvedLivingRoomSize,
      if (roomSizeBreakdown != null) 'room_size_breakdown': roomSizeBreakdown!.toJson(),
    };
  }

  @override
  BodyMap getBody() {
    final body = <String, dynamic>{
      'propertyType': propertyType,
      'propertyDetails': _buildPropertyDetails(),
      if (!_isEventAssistance && cleaningType != null) 'cleaningType': cleaningType!.apiValue,
      'scheduledDate': scheduledDate,
      'scheduledTime': scheduledTime,
      if (addressLatitude != null) 'addressLatitude': addressLatitude,
      if (addressLongitude != null) 'addressLongitude': addressLongitude,
      'genderPreference': genderPreference.apiValue,
      'assignmentMode': assignmentMode.apiValue,
      if (preferredWorkerId != null && assignmentMode == CleaningAssignmentMode.preferredWorker) 'preferredWorkerId': preferredWorkerId,
      'termsAccepted': termsAccepted,
    };
    final cleanServiceIds = _sanitizeServiceIds();
    if (cleanServiceIds.isNotEmpty) {
      body['serviceIds'] = cleanServiceIds;
    }
    final resolvedWorkers = _resolvedNumberOfWorkers;
    if (resolvedWorkers != null && resolvedWorkers > 0) {
      body['numberOfWorkers'] = resolvedWorkers;
    }
    final assignments = workerRoomAssignments;
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
}
