import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/models/cleaning_gender_preference.dart';
import '../../data/models/create_cleaning_order_response_model.dart';
import '../models/cleaning_assignment_mode.dart';
import '../models/cleaning_room_size_breakdown.dart';
import '../models/cleaning_type.dart';
import '../models/cl_worker_room_assignment_result.dart';
import '../models/work_environment_confirmation.dart';
import '../repository/cl_main_repo.dart';

@lazySingleton
class CreateCleaningOrderUseCase
    implements UseCase<CreateCleaningOrderResponseModel, CreateCleaningOrderParams> {
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
  final WorkEnvironmentConfirmation? workEnvironmentConfirmation;
  final int? preferredWorkerId;
  final List<int> preferredWorkerIds;
  final List<String>? cleaningServices;
  final String? eventType;
  final int? guestCount;
  final String? venueType;
  final String? customService;
  final double? hours;
  final String? specialRequirement;
  final String? notes;
  final int? numberOfWorkers;
  final CleaningAssignmentMode assignmentMode;
  final bool termsAccepted;
  final List<Map<String, dynamic>>? workerRoomAssignments;
  final int addressId;

  CreateCleaningOrderParams({
    required this.addressId,
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
    this.workEnvironmentConfirmation,
    this.preferredWorkerId,
    this.preferredWorkerIds = const <int>[],
    this.cleaningServices,
    this.assignmentMode = CleaningAssignmentMode.preferredWorker,
    this.numberOfWorkers,
    this.termsAccepted = true,
    this.workerRoomAssignments,
  }) : eventType = null,
       guestCount = null,
       venueType = null,
       customService = null,
       hours = null,
       specialRequirement = null,
       notes = null;

  CreateCleaningOrderParams.eventAssistance({
    required this.addressId,
    this.propertyType = 'event_assistance',
    required this.scheduledDate,
    required this.scheduledTime,
    required this.eventType,
    required this.guestCount,
    required this.venueType,
    required this.customService,
    required this.hours,
    this.address,
    this.locationName,
    this.addressLatitude,
    this.addressLongitude,
    this.genderPreference = CleaningGenderPreference.any,
    this.workEnvironmentConfirmation,
    this.preferredWorkerId,
    this.preferredWorkerIds = const <int>[],
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
       cleaningType = null,
       cleaningServices = null;

  bool get _isEventAssistance => propertyType == 'event_assistance';

  List<int> _sanitizePreferredWorkerIds() {
    final normalized = <int>[];
    final singleId = preferredWorkerId;
    if (singleId != null && singleId > 0) normalized.add(singleId);
    for (final id in preferredWorkerIds) {
      if (id <= 0 || normalized.contains(id)) continue;
      normalized.add(id);
    }
    return normalized;
  }

  CleaningAssignmentMode _effectiveAssignmentMode(List<int> workerIds) {
    return workerIds.isEmpty
        ? assignmentMode
        : CleaningAssignmentMode.preferredWorker;
  }

  List<String> _sanitizeCleaningServices() {
    final source = cleaningServices ?? const <String>[];
    final normalized = <String>[];
    for (final service in source) {
      final name = service.trim();
      if (name.isEmpty || name.length > 255) continue;
      if (normalized.contains(name)) continue;
      normalized.add(name);
    }
    return normalized;
  }

  int? get _resolvedBedrooms => roomSizeBreakdown?.legacyBedroomsCount ?? bedrooms;
  int? get _resolvedRooms => roomSizeBreakdown?.legacyRoomsCount ?? rooms;
  int? get _resolvedBathrooms => roomSizeBreakdown?.legacyBathroomsCount ?? bathrooms;
  int? get _resolvedBalconies => roomSizeBreakdown?.legacyBalconiesCount ?? balconies;
  String get _resolvedLivingRoomSize =>
      roomSizeBreakdown?.legacyLivingRoomSize ?? livingRoomSize ?? CleaningRoomSize.small.apiValue;

  Map<String, dynamic> _buildPropertyDetails() {
    if (_isEventAssistance) {
      return {
        if (address != null && address!.trim().isNotEmpty) 'address': address!.trim(),
        if (locationName != null && locationName!.trim().isNotEmpty) 'location_name': locationName!.trim(),
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
      'address': address,
      'location_name': locationName,
      'bedrooms': _resolvedBedrooms,
      'rooms': _resolvedRooms,
      'bathrooms': _resolvedBathrooms,
      if (_resolvedBalconies != null) 'balconies': _resolvedBalconies,
      'living_room_size': _resolvedLivingRoomSize,
      if (roomSizeBreakdown != null) 'room_size_breakdown': roomSizeBreakdown!.toBackendJson(),
      if (cleaningType != null) 'cleaning_mode': cleaningType!.cleaningModeValue,
    };
  }

  @override
  BodyMap getBody() {
    final workerIds = _sanitizePreferredWorkerIds();
    final effectiveAssignmentMode = _effectiveAssignmentMode(workerIds);
    final body = <String, dynamic>{
      'propertyType': propertyType,
      'addressId': addressId,
      'propertyDetails': _buildPropertyDetails(),
      'scheduledDate': scheduledDate,
      'scheduledTime': scheduledTime,
      if (addressId <= 0 && addressLatitude != null) 'addressLatitude': addressLatitude,
      if (addressId <= 0 && addressLongitude != null) 'addressLongitude': addressLongitude,
      'genderPreference': genderPreference.apiValue,
      if (genderPreference == CleaningGenderPreference.female && workEnvironmentConfirmation != null)
        'workEnvironmentConfirmation': workEnvironmentConfirmation!.toJson(),
      'assignmentMode': effectiveAssignmentMode.apiValue,
      if (workerIds.isNotEmpty) 'preferredWorkerIds': workerIds,
      'termsAccepted': termsAccepted,
    };
    if (!_isEventAssistance) {
      final cleanServices = _sanitizeCleaningServices();
      if (cleanServices.isNotEmpty) body['cleaning_services'] = cleanServices;
    }
    // final resolvedWorkers = _resolvedNumberOfWorkers(
    //   workerIds,
    //   effectiveAssignmentMode,
    // );
    // if (resolvedWorkers != null && resolvedWorkers > 0)
      body['numberOfWorkers'] = numberOfWorkers;
    final assignments = workerRoomAssignments == null
        ? null
        : filterNonEmptyWorkerRoomAssignmentMaps(workerRoomAssignments!);
    if (assignments != null && assignments.isNotEmpty) body['workerRoomAssignments'] = assignments;
    return body;
  }

  // int? _resolvedNumberOfWorkers(
  //   List<int> workerIds,
  //   CleaningAssignmentMode effectiveAssignmentMode,
  // ) {
  //   if (_isEventAssistance) return numberOfWorkers;
  //   if (effectiveAssignmentMode == CleaningAssignmentMode.openCount) {
  //     final requested = numberOfWorkers ?? 1;
  //     return requested < 1 ? 1 : requested;
  //   }
  //   return 1;
  // }
}
