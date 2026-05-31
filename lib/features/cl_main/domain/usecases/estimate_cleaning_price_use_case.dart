import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/estimate_price_response_model.dart';
import '../models/cleaning_room_size_breakdown.dart';
import '../repository/cl_main_repo.dart';

@lazySingleton
class EstimateCleaningPriceUseCase
    implements
        UseCase<EstimatePriceResponseModel, EstimateCleaningPriceParams> {
  final ClMainRepo clMainRepo;

  EstimateCleaningPriceUseCase({required this.clMainRepo});

  @override
  DataResponse<EstimatePriceResponseModel> call(
    EstimateCleaningPriceParams params,
  ) {
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
  final double? addressLatitude;
  final double? addressLongitude;
  final int? preferredWorkerId;
  final List<int>? serviceIds;
  final String? eventType;
  final int? guestCount;
  final String? venueType;
  final String? specialRequirement;
  final String? notes;
  final int? numberOfWorkers;

  EstimateCleaningPriceParams({
    required this.propertyType,
    required this.bedrooms,
    required this.rooms,
    required this.bathrooms,
    this.balconies,
    required this.livingRoomSize,
    this.roomSizeBreakdown,
    required this.addressLatitude,
    required this.addressLongitude,
    this.preferredWorkerId,
    this.serviceIds,
  }) : eventType = null,
       guestCount = null,
       venueType = null,
       specialRequirement = null,
       notes = null,
       numberOfWorkers = null;

  EstimateCleaningPriceParams.eventAssistance({
    this.propertyType = 'event_assistance',
    required this.eventType,
    required this.guestCount,
    required this.venueType,
    required this.serviceIds,
    this.addressLatitude,
    this.addressLongitude,
    this.preferredWorkerId,
    this.specialRequirement,
    this.notes,
    this.numberOfWorkers,
  }) : bedrooms = null,
       rooms = null,
       bathrooms = null,
       balconies = null,
       livingRoomSize = null,
       roomSizeBreakdown = null;

  bool get _isEventAssistance => propertyType == 'event_assistance';

  List<int> _sanitizeServiceIds() {
    final source = serviceIds ?? const <int>[];
    return source.where((id) => id > 0).toSet().toList(growable: false);
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
        'eventType': eventType,
        'guestCount': guestCount,
        'venueType': venueType,
        if (specialRequirement != null && specialRequirement!.trim().isNotEmpty)
          'specialRequirement': specialRequirement!.trim(),
        if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
      };
    }
    return {
      'bedrooms': _resolvedBedrooms,
      'rooms': _resolvedRooms,
      'bathrooms': _resolvedBathrooms,
      if (_resolvedBalconies != null) 'balconies': _resolvedBalconies,
      'living_room_size': _resolvedLivingRoomSize,
      if (roomSizeBreakdown != null)
        'room_size_breakdown': roomSizeBreakdown!.toJson(),
    };
  }

  Map<String, dynamic> _buildBody() {
    final body = <String, dynamic>{
      'propertyType': propertyType,
      'propertyDetails': _buildPropertyDetails(),
      if (addressLatitude != null) 'addressLatitude': addressLatitude,
      if (addressLongitude != null) 'addressLongitude': addressLongitude,
      if (preferredWorkerId != null) 'preferredWorkerId': preferredWorkerId,
    };
    final cleanServiceIds = _sanitizeServiceIds();
    if (cleanServiceIds.isNotEmpty) {
      body['serviceIds'] = cleanServiceIds;
    }
    if (_isEventAssistance && numberOfWorkers != null && numberOfWorkers! > 0) {
      body['numberOfWorkers'] = numberOfWorkers;
    }
    return body;
  }

  @override
  BodyMap getBody() {
    return _buildBody();
  }
}
