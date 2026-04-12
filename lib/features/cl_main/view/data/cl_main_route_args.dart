import '../../data/models/estimate_price_response_model.dart';
import '../manager/bloc/cl_main_bloc.dart';

class ClMainHomeDescriptionArgs {
  final String propertyType;
  final ClMainBloc bloc;

  const ClMainHomeDescriptionArgs({
    required this.propertyType,
    required this.bloc,
  });
}

class ClMainScheduleArgs {
  final String propertyType;
  final int bedrooms;
  final int rooms;
  final int bathrooms;
  final String livingRoomSize;
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
    required this.addressLatitude,
    required this.addressLongitude,
    required this.estimate,
    required this.bloc,
  });
}
