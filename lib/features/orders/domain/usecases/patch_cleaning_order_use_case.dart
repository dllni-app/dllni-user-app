import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';
import 'package:dllni_user_app/core/models/cleaning_gender_preference.dart';

import '../../data/models/orders_api_models.dart';
import '../repository/orders_repo.dart';

@lazySingleton
class PatchCleaningOrderUseCase
    implements UseCase<OrdersActionResultModel, PatchCleaningOrderParams> {
  final OrdersRepo ordersRepo;

  PatchCleaningOrderUseCase({required this.ordersRepo});

  @override
  DataResponse<OrdersActionResultModel> call(PatchCleaningOrderParams params) {
    return ordersRepo.patchCleaningOrder(params);
  }
}

class PatchCleaningOrderParams with Params {
  final int cleaningOrderId;
  final String propertyType;
  final String scheduledDate;
  final String scheduledTime;
  final String address;
  final int bedrooms;
  final int rooms;
  final int bathrooms;
  final String livingRoomSize;
  final double addressLatitude;
  final double addressLongitude;
  final CleaningGenderPreference genderPreference;

  PatchCleaningOrderParams({
    required this.cleaningOrderId,
    required this.propertyType,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.address,
    required this.bedrooms,
    required this.rooms,
    required this.bathrooms,
    required this.livingRoomSize,
    required this.addressLatitude,
    required this.addressLongitude,
    this.genderPreference = CleaningGenderPreference.any,
  });

  @override
  BodyMap getBody() => {
    'propertyType': propertyType,
    'scheduledDate': scheduledDate,
    'scheduledTime': scheduledTime,
    'propertyDetails': {
      'address': address,
      'bedrooms': bedrooms,
      'rooms': rooms,
      'bathrooms': bathrooms,
      'living_room_size': livingRoomSize,
    },
    'addressLatitude': addressLatitude,
    'addressLongitude': addressLongitude,
    'genderPreference': genderPreference.apiValue,
  };
}
