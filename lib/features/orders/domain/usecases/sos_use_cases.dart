import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/sos_api_models.dart';
import '../repository/orders_repo.dart';

@lazySingleton
class CreateUserSosUseCase
    implements UseCase<UserSosResponseModel, CreateUserSosParams> {
  final OrdersRepo ordersRepo;

  CreateUserSosUseCase({required this.ordersRepo});

  @override
  DataResponse<UserSosResponseModel> call(CreateUserSosParams params) {
    return ordersRepo.createUserSos(params);
  }
}

class CreateUserSosParams with Params {
  final int orderId;
  final String message;
  final String? emergencyType;
  final double? latitude;
  final double? longitude;

  CreateUserSosParams({
    required this.orderId,
    required this.message,
    this.emergencyType,
    this.latitude,
    this.longitude,
  });

  @override
  BodyMap getBody() {
    final body = <String, dynamic>{
      'order_id': orderId,
      'message': message.trim(),
    };
    final trimmedEmergencyType = emergencyType?.trim();
    if (trimmedEmergencyType != null && trimmedEmergencyType.isNotEmpty) {
      body['emergency_type'] = trimmedEmergencyType;
    }
    if (latitude != null && longitude != null) {
      body['lat'] = latitude;
      body['lng'] = longitude;
    }
    return body;
  }
}

@lazySingleton
class FetchSosAlertsUseCase
    implements UseCase<FetchSosAlertsModel, FetchSosAlertsParams> {
  final OrdersRepo ordersRepo;

  FetchSosAlertsUseCase({required this.ordersRepo});

  @override
  DataResponse<FetchSosAlertsModel> call(FetchSosAlertsParams params) {
    return ordersRepo.fetchSosAlerts(params);
  }
}

class FetchSosAlertsParams with Params {
  final int page;

  FetchSosAlertsParams({this.page = 1});

  @override
  QueryParams getParams() => <String, dynamic>{'page': page};
}

@lazySingleton
class FetchSosAlertDetailsUseCase
    implements UseCase<SosAlertModel, FetchSosAlertDetailsParams> {
  final OrdersRepo ordersRepo;

  FetchSosAlertDetailsUseCase({required this.ordersRepo});

  @override
  DataResponse<SosAlertModel> call(FetchSosAlertDetailsParams params) {
    return ordersRepo.fetchSosAlertDetails(params);
  }
}

class FetchSosAlertDetailsParams with Params {
  final int alertId;

  FetchSosAlertDetailsParams({required this.alertId});
}

@lazySingleton
class CreateCleaningUserSosUseCase
    implements UseCase<CleaningSosAlertModel, CreateCleaningUserSosParams> {
  final OrdersRepo ordersRepo;

  CreateCleaningUserSosUseCase({required this.ordersRepo});

  @override
  DataResponse<CleaningSosAlertModel> call(CreateCleaningUserSosParams params) {
    return ordersRepo.createCleaningUserSos(params);
  }
}

class CreateCleaningUserSosParams with Params {
  final int orderId;
  final String emergencyType;
  final String message;
  final double? latitude;
  final double? longitude;

  CreateCleaningUserSosParams({
    required this.orderId,
    required this.emergencyType,
    required this.message,
    this.latitude,
    this.longitude,
  });

  @override
  BodyMap getBody() {
    final body = <String, dynamic>{
      'emergency_type': emergencyType,
      'message': message.trim(),
    };
    if (latitude != null && longitude != null) {
      body['latitude'] = latitude;
      body['longitude'] = longitude;
    }
    return body;
  }
}
