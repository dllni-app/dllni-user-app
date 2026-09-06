import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/models/cleaning_gender_preference.dart';
import '../../../../core/models/cleaning_service_extras.dart';
import '../../data/models/create_cleaning_order_response_model.dart';
import '../models/cleaning_assignment_mode.dart';
import '../models/cleaning_event_session.dart';
import '../models/cleaning_recurring_session.dart';
import '../models/cleaning_room_size_breakdown.dart';
import '../models/cleaning_type.dart';
import '../models/cl_worker_room_assignment_result.dart';
import '../models/work_environment_confirmation.dart';
import '../repository/cl_main_repo.dart';

@lazySingleton
class CreateCleaningOrderUseCase
    implements
        UseCase<CreateCleaningOrderResponseModel, CreateCleaningOrderParams> {
  final ClMainRepo clMainRepo;

  CreateCleaningOrderUseCase({required this.clMainRepo});

  @override
  DataResponse<CreateCleaningOrderResponseModel> call(
    CreateCleaningOrderParams params,
  ) {
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
  final List<CleaningEventSessionInput> eventSessions;
  final List<CleaningRecurringSessionInput> recurringSessions;
  final CleaningRecurringCalculationMode recurringCalculationMode;
  final double? recurringHoursPerVisit;
  final CleaningRecurringWorkerScope recurringWorkerScope;
  final String? specialRequirement;
  final String? notes;
  final int? numberOfWorkers;
  final CleaningAssignmentMode assignmentMode;
  final bool termsAccepted;
  final List<Map<String, dynamic>>? workerRoomAssignments;
  final int addressId;
  final String? couponCode;
  final CleaningServiceExtrasRequest serviceExtras;

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
    this.recurringSessions = const <CleaningRecurringSessionInput>[],
    this.recurringCalculationMode = CleaningRecurringCalculationMode.task,
    this.recurringHoursPerVisit,
    this.recurringWorkerScope = CleaningRecurringWorkerScope.any,
    this.assignmentMode = CleaningAssignmentMode.preferredWorker,
    this.numberOfWorkers,
    this.termsAccepted = true,
    this.workerRoomAssignments,
    this.couponCode,
    this.serviceExtras = const CleaningServiceExtrasRequest(),
  }) : eventType = null,
       guestCount = null,
       venueType = null,
       customService = null,
       hours = null,
       eventSessions = const <CleaningEventSessionInput>[],
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
    this.eventSessions = const <CleaningEventSessionInput>[],
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
    this.couponCode,
    this.serviceExtras = const CleaningServiceExtrasRequest(),
  }) : bedrooms = null,
       workerRoomAssignments = null,
       rooms = null,
       bathrooms = null,
       balconies = null,
       livingRoomSize = null,
       roomSizeBreakdown = null,
       cleaningType = null,
       cleaningServices = null,
       recurringSessions = const <CleaningRecurringSessionInput>[],
       recurringCalculationMode = CleaningRecurringCalculationMode.task,
       recurringHoursPerVisit = null,
       recurringWorkerScope = CleaningRecurringWorkerScope.any;

  bool get _isEventAssistance => propertyType == 'event_assistance';

  List<CleaningEventSessionInput> get _normalizedEventSessions =>
      eventSessions.normalized;

  List<CleaningRecurringSessionInput> get _normalizedRecurringSessions =>
      recurringSessions.normalized;

  double? get _resolvedLegacyEventHours {
    final sessions = _normalizedEventSessions;
    if (sessions.isNotEmpty) return sessions.first.hours;
    return hours;
  }

  String get _resolvedScheduledDate {
    if (_isEventAssistance) {
      final sessions = _normalizedEventSessions;
      return sessions.isEmpty ? scheduledDate : sessions.first.dateApi;
    }
    final sessions = _normalizedRecurringSessions;
    return sessions.isEmpty ? scheduledDate : sessions.first.dateApi;
  }

  String get _resolvedScheduledTime {
    if (_isEventAssistance) {
      final sessions = _normalizedEventSessions;
      return sessions.isEmpty ? scheduledTime : sessions.first.time;
    }
    final sessions = _normalizedRecurringSessions;
    return sessions.isEmpty ? scheduledTime : sessions.first.time;
  }

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

  int? get _resolvedBedrooms =>
      roomSizeBreakdown?.legacyBedroomsCount ?? bedrooms;
  int? get _resolvedRooms => roomSizeBreakdown?.legacyRoomsCount ?? rooms;
  int? get _resolvedBathrooms =>
      roomSizeBreakdown?.legacyBathroomsCount ?? bathrooms;
  int? get _resolvedBalconies =>
      roomSizeBreakdown?.legacyBalconiesCount ?? balconies;
  String get _resolvedLivingRoomSize =>
      roomSizeBreakdown?.legacyLivingRoomSize ??
      livingRoomSize ??
      CleaningRoomSize.small.apiValue;

  Map<String, dynamic> _buildPropertyDetails() {
    if (_isEventAssistance) {
      return {
        if (address != null && address!.trim().isNotEmpty)
          'address': address!.trim(),
        if (locationName != null && locationName!.trim().isNotEmpty)
          'location_name': locationName!.trim(),
        'eventType': eventType,
        'guestCount': guestCount,
        'venueType': venueType,
        'customService': customService?.trim(),
        'hours': _resolvedLegacyEventHours,
        if (specialRequirement != null && specialRequirement!.trim().isNotEmpty)
          'specialRequirement': specialRequirement!.trim(),
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
      if (roomSizeBreakdown != null)
        'room_size_breakdown': roomSizeBreakdown!.toBackendJson(),
      if (cleaningType != null)
        'cleaning_mode': cleaningType!.cleaningModeValue,
    };
  }

  @override
  BodyMap getBody() {
    final sanitizedWorkerIds = _sanitizePreferredWorkerIds();
    final isRecurring =
        !_isEventAssistance && _normalizedRecurringSessions.isNotEmpty;
    final workerSelection = CleaningRecurringWorkerSelection.resolve(
      isRecurring: isRecurring,
      recurringScope: recurringWorkerScope,
      selectedWorkerIds: sanitizedWorkerIds,
      legacyAssignmentMode: assignmentMode,
      requestedWorkers: numberOfWorkers,
    );
    final workerIds = workerSelection.workerIds;
    final normalizedCouponCode = couponCode?.trim();
    final schedule = _isEventAssistance
        ? _normalizedEventSessions.scheduleJson
        : _normalizedRecurringSessions.scheduleJsonFor(
            calculationMode: recurringCalculationMode,
            hoursPerVisit: recurringHoursPerVisit,
          );
    final body = <String, dynamic>{
      'propertyType': propertyType,
      'addressId': addressId,
      'propertyDetails': _buildPropertyDetails(),
      'scheduledDate': _resolvedScheduledDate,
      'scheduledTime': _resolvedScheduledTime,
      if (addressId <= 0 && addressLatitude != null)
        'addressLatitude': addressLatitude,
      if (addressId <= 0 && addressLongitude != null)
        'addressLongitude': addressLongitude,
      'genderPreference': genderPreference.apiValue,
      if (genderPreference == CleaningGenderPreference.female &&
          workEnvironmentConfirmation != null)
        'workEnvironmentConfirmation': workEnvironmentConfirmation!.toJson(),
      'assignmentMode': workerSelection.assignmentMode.apiValue,
      if (isRecurring) 'workerScope': workerSelection.scope.apiValue,
      if (workerIds.isNotEmpty) 'preferredWorkerIds': workerIds,
      'termsAccepted': termsAccepted,
      if (normalizedCouponCode != null && normalizedCouponCode.isNotEmpty)
        'couponCode': normalizedCouponCode,
      'numberOfWorkers': workerSelection.numberOfWorkers,
      ...serviceExtras.toJson(),
    };
    if (schedule != null) {
      body['schedule'] = schedule;
    }
    if (!_isEventAssistance) {
      final cleanServices = _sanitizeCleaningServices();
      if (cleanServices.isNotEmpty) {
        body['cleaning_services'] = cleanServices;
      }
    }
    final assignments = workerRoomAssignments == null
        ? null
        : filterNonEmptyWorkerRoomAssignmentMaps(workerRoomAssignments!);
    if (assignments != null && assignments.isNotEmpty) {
      body['workerRoomAssignments'] = assignments;
    }
    return body;
  }
}
