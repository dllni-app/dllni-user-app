import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/profile_api_models.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class UpdateAddressUseCase
    implements UseCase<ActionResultModel, UpdateAddressParams> {
  final ProfileRepo profileRepo;

  UpdateAddressUseCase({required this.profileRepo});

  @override
  DataResponse<ActionResultModel> call(UpdateAddressParams params) {
    return profileRepo.updateAddress(params);
  }
}

class UpdateAddressParams with Params {
  final int addressId;
  final String label;
  final String mobile;
  final String city;
  final String neighborhood;
  final String street;
  final String building;
  final String floor;
  final String directions;
  final bool isDefault;
  final double? latitude;
  final double? longitude;

  UpdateAddressParams({
    required this.addressId,
    required this.label,
    required this.mobile,
    required this.city,
    required this.neighborhood,
    required this.street,
    required this.building,
    required this.floor,
    required this.directions,
    required this.isDefault,
    this.latitude,
    this.longitude,
  });

  @override
  BodyMap getBody() => {
    'label': label,
    'mobile': mobile,
    'city': city,
    'neighborhood': neighborhood,
    'street': street,
    'building': building,
    'floor': floor,
    'directions': directions,
    'isDefault': isDefault,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
  };
}
