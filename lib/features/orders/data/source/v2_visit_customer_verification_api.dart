import 'package:common_package/helpers/dio_network.dart';

/// Customer-only V2 visit secret. Never use the legacy worker 4-digit code.
class V2VisitCustomerVerificationApi {
  const V2VisitCustomerVerificationApi(this.network);

  final DioNetwork network;

  Future<Map<String, dynamic>> code(int bookingId, int sequence) async {
    final response = await network.getData(
      endPoint:
          '/api/v1/user/cleaning/v2/bookings/$bookingId/visits/$sequence/verification-code',
    );
    return Map<String, dynamic>.from(response.data['data'] as Map);
  }
}
