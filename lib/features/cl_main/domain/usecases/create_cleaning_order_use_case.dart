import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/create_cleaning_order_response_model.dart';
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
  final int bedrooms;
  final int rooms;
  final int bathrooms;
  final String livingRoomSize;
  final String address;
  final String locationName;
  final String scheduledDate;
  final String scheduledTime;
  final double addressLatitude;
  final double addressLongitude;
  final int? preferredWorkerId;
  final String quoteId;
  final bool termsAccepted;

  CreateCleaningOrderParams({
    required this.propertyType,
    required this.bedrooms,
    required this.rooms,
    required this.bathrooms,
    required this.livingRoomSize,
    required this.address,
    required this.locationName,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.addressLatitude,
    required this.addressLongitude,
    required this.quoteId,
    this.preferredWorkerId,
    this.termsAccepted = true,
  });

  @override
  BodyMap getBody() {
    return {
      'propertyType': propertyType,
      'propertyDetails': {
        'address': address,
        'location_name': locationName,
        'bedrooms': bedrooms,
        'rooms': rooms,
        'bathrooms': bathrooms,
        'living_room_size': livingRoomSize,
      },
      'scheduledDate': scheduledDate,
      'scheduledTime': scheduledTime,
      'addressLatitude': addressLatitude,
      'addressLongitude': addressLongitude,
      'preferredWorkerId': preferredWorkerId,
      'quoteId': quoteId,
      'termsAccepted': termsAccepted,
    };
  }
}
