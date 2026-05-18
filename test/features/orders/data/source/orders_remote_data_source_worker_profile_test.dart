import 'package:common_package/helpers/dio_network.dart';
import 'package:dio/dio.dart';
import 'package:dllni_user_app/features/orders/data/source/orders_remote_data_source.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/fetch_cleaning_worker_profile_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fetchCleaningWorkerProfile uses /api/v1/worker/{worker}', () async {
    final dio = _FakeDioNetwork();
    final dataSource = OrdersRemoteDataSource(dioNetwork: dio);

    final result = await dataSource.fetchCleaningWorkerProfile(
      FetchCleaningWorkerProfileParams(workerId: 77),
    );

    expect(dio.lastGetEndpoint, '/api/v1/worker/77');
    expect(result.data?.id, 77);
    expect(result.data?.user?.name, 'Worker Name');
  });
}

class _FakeDioNetwork extends DioNetwork {
  _FakeDioNetwork() : super(baseUrl: 'https://example.com');

  String? lastGetEndpoint;

  @override
  Future<Response> getData({
    required String endPoint,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? params,
    Map<String, dynamic>? data,
  }) async {
    lastGetEndpoint = endPoint;
    return Response<dynamic>(
      requestOptions: RequestOptions(path: endPoint),
      data: <String, dynamic>{
        'data': <String, dynamic>{
          'id': 77,
          'firstName': 'Worker',
          'user': <String, dynamic>{'name': 'Worker Name'},
        },
      },
      statusCode: 200,
    );
  }
}
