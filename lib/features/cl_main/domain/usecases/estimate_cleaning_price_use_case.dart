import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/estimate_price_response_model.dart';
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
  final int bedrooms;
  final int rooms;
  final int bathrooms;
  final String livingRoomSize;
  final double addressLatitude;
  final double addressLongitude;
  final int? preferredWorkerId;

  EstimateCleaningPriceParams({
    required this.propertyType,
    required this.bedrooms,
    required this.rooms,
    required this.bathrooms,
    required this.livingRoomSize,
    required this.addressLatitude,
    required this.addressLongitude,
    this.preferredWorkerId,
  });

  @override
  BodyMap getBody() {
    return {
      'propertyType': 'apartment',
      'propertyDetails': {
        'bedrooms': bedrooms,
        'rooms': rooms,
        'bathrooms': bathrooms,
        'living_room_size': 'medium',
      },
      'addressLatitude': addressLatitude,
      'addressLongitude': addressLongitude,
      'preferredWorkerId': preferredWorkerId,
    };
  }
}
