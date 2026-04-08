import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/profile_api_models.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class CreateAddressUseCase
    implements UseCase<ActionResultModel, CreateAddressParams> {
  final ProfileRepo profileRepo;

  CreateAddressUseCase({required this.profileRepo});

  @override
  DataResponse<ActionResultModel> call(CreateAddressParams params) {
    return profileRepo.createAddress(params);
  }
}

class CreateAddressParams with Params {
  final String label;
  final String mobile;
  final String city;
  final String neighborhood;
  final String street;
  final String? building;
  final String floor;
  final String? directions;
  final bool isDefault;
  final double latitude;
  final double longitude;

  CreateAddressParams({
    required this.label,
    required this.mobile,
    required this.city,
    required this.neighborhood,
    required this.street,
    this.building,
    required this.floor,
    this.directions,
    required this.isDefault,
    required this.latitude,
    required this.longitude,
  });

  @override
  BodyMap getBody() => {
        'label': label,
        'mobile': mobile,
        'city': city,
        'neighborhood': neighborhood,
        'street': street,
        if (building != null && building!.trim().isNotEmpty) 'building': building,
        'floor': floor,
        if (directions != null && directions!.trim().isNotEmpty) 'directions': directions,
        'isDefault': isDefault,
        'latitude': latitude,
        'longitude': longitude,
      };
}
