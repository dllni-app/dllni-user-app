import 'package:common_package/helpers/api_handler.dart';
import 'package:common_package/helpers/dio_network.dart';

import '../models/sos_api_models.dart';

class OrderSupportCaseRemoteDataSource with HandlingApiManager {
  OrderSupportCaseRemoteDataSource({required this.dioNetwork});

  final DioNetwork dioNetwork;

  Future<CleaningSosAlertModel> createEmergency({
    required int orderId,
    required String bookingType,
    required String emergencyType,
    required String description,
    double? latitude,
    double? longitude,
    String? clientRequestId,
  }) {
    final data = <String, dynamic>{
      'kind': 'emergency',
      'bookingId': orderId,
      'bookingType': bookingType,
      'emergencyType': emergencyType,
      'description': description.trim(),
      if (latitude != null && longitude != null) 'latitude': latitude,
      if (latitude != null && longitude != null) 'longitude': longitude,
      if (clientRequestId != null && clientRequestId.trim().isNotEmpty)
        'clientRequestId': clientRequestId.trim(),
    };

    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/support-cases',
        data: data,
      ),
      jsonConvert: cleaningSosAlertModelFromJson,
    );
  }
}
