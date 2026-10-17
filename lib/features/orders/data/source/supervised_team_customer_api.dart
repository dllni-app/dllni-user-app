import 'package:common_package/helpers/dio_network.dart';

typedef TeamJson = Map<String, dynamic>;

class SupervisedTeamCustomerApi {
  SupervisedTeamCustomerApi(this.network);

  final DioNetwork network;

  String _path(int bookingId) =>
      '/api/v1/supervised-team/customer/bookings/$bookingId';

  Future<TeamJson> fetch(int bookingId) async {
    final response = await network.getData(endPoint: _path(bookingId));
    return Map<String, dynamic>.from(response.data['data'] as Map);
  }

  Future<TeamJson> verificationCode(int bookingId) async {
    final response = await network.getData(
      endPoint: '${_path(bookingId)}/verification-code',
    );
    return Map<String, dynamic>.from(response.data['data'] as Map);
  }

  Future<void> decideExtension(
    int bookingId,
    int extensionId,
    bool approve,
  ) async {
    await network.postData(
      endPoint: '${_path(bookingId)}/extensions/$extensionId/decision',
      data: {'decision': approve ? 'approved' : 'rejected'},
    );
  }

  Future<void> decideHandover(int bookingId, {String? objection}) async {
    await network.postData(
      endPoint: '${_path(bookingId)}/handover-decision',
      data: {
        'decision': objection == null ? 'confirmed' : 'objected',
        if (objection != null) 'note': objection.trim(),
      },
    );
  }
}
