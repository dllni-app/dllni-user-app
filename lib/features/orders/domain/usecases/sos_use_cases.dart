import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/sos_api_models.dart';
import '../repository/orders_repo.dart';

@lazySingleton
class CreateUserSosUseCase
    implements UseCase<CreateUserSosResponseModel, CreateUserSosParams> {
  final OrdersRepo ordersRepo;

  CreateUserSosUseCase({required this.ordersRepo});

  @override
  DataResponse<CreateUserSosResponseModel> call(CreateUserSosParams params) {
    return ordersRepo.createUserSos(params);
  }
}

class CreateUserSosParams with Params {
  final int orderId;
  final List<String> reasons;
  final String? notes;

  CreateUserSosParams({
    required this.orderId,
    required this.reasons,
    this.notes,
  });

  @override
  BodyMap getBody() {
    return <String, dynamic>{
      'order_id': orderId,
      'reasons': reasons,
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
    };
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
  DataResponse<CleaningSosAlertModel> call(
    CreateCleaningUserSosParams params,
  ) {
    return ordersRepo.createCleaningUserSos(params);
  }
}

class CreateCleaningUserSosParams with Params {
  final int orderId;
  final String emergencyType;
  final String? message;
  final double? latitude;
  final double? longitude;
  final String clientRequestId;

  CreateCleaningUserSosParams({
    required this.orderId,
    required this.emergencyType,
    this.message,
    this.latitude,
    this.longitude,
    required this.clientRequestId,
  });

  @override
  BodyMap getBody() {
    final body = <String, dynamic>{
      'emergencyType': emergencyType,
      'clientRequestId': clientRequestId,
    };
    final trimmedMessage = message?.trim();
    if (trimmedMessage != null && trimmedMessage.isNotEmpty) {
      body['message'] = trimmedMessage;
    }
    if (latitude != null && longitude != null) {
      body['latitude'] = latitude;
      body['longitude'] = longitude;
    }
    return body;
  }
}
