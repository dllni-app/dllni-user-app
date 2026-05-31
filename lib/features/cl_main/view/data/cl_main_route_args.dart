import '../../data/models/estimate_price_response_model.dart';
import '../../domain/models/cleaning_room_size_breakdown.dart';
import '../manager/bloc/cl_main_bloc.dart';

class ClMainHomeDescriptionArgs {
  final String propertyType;
  final ClMainBloc bloc;

  const ClMainHomeDescriptionArgs({
    required this.propertyType,
    required this.bloc,
  });
}

class ClMainOccasionOption {
  final String id;
  final String title;
  final String imagePath;

  const ClMainOccasionOption({
    required this.id,
    required this.title,
    required this.imagePath,
  });
}

class ClMainOccasionDescriptionArgs {
  final ClMainOccasionOption option;
  final ClMainBloc bloc;

  const ClMainOccasionDescriptionArgs({
    required this.option,
    required this.bloc,
  });
}

class ClMainOccasionScheduleArgs {
  final ClMainOccasionOption option;
  final ClMainBloc bloc;
  final EstimatePriceResponseModel estimate;
  final int guestsCount;
  final String eventType;
  final String venueType;
  final List<int> serviceIds;
  final int? suggestedTeamSize;
  final String helpTypeId;
  final String helpTypeLabel;
  final String specialRequirementId;
  final String specialRequirementLabel;
  final String? notes;

  const ClMainOccasionScheduleArgs({
    required this.option,
    required this.bloc,
    required this.estimate,
    required this.guestsCount,
    required this.eventType,
    required this.venueType,
    required this.serviceIds,
    required this.suggestedTeamSize,
    required this.helpTypeId,
    required this.helpTypeLabel,
    required this.specialRequirementId,
    required this.specialRequirementLabel,
    this.notes,
  });
}

class ClMainScheduleArgs {
  final String propertyType;
  final int bedrooms;
  final int rooms;
  final int bathrooms;
  final String livingRoomSize;
  final CleaningRoomSizeBreakdown roomSizeBreakdown;
  final double addressLatitude;
  final double addressLongitude;
  final EstimatePriceResponseModel estimate;
  final ClMainBloc bloc;

  const ClMainScheduleArgs({
    required this.propertyType,
    required this.bedrooms,
    required this.rooms,
    required this.bathrooms,
    required this.livingRoomSize,
    required this.roomSizeBreakdown,
    required this.addressLatitude,
    required this.addressLongitude,
    required this.estimate,
    required this.bloc,
  });
}
