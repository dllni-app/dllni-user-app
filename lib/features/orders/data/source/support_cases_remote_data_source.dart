import 'package:common_package/helpers/api_handler.dart';
import 'package:common_package/helpers/dio_network.dart';
import 'package:dio/dio.dart';

import '../../domain/usecases/sos_use_cases.dart';
import '../models/sos_api_models.dart';

class SupportCasesRemoteDataSource with HandlingApiManager {
  SupportCasesRemoteDataSource({required this.dioNetwork});

  final DioNetwork dioNetwork;

  Future<CleaningSosAlertModel> createEmergency(
    CreateCleaningUserSosParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/support-cases',
        data: params.getBody(),
      ),
      jsonConvert: cleaningSosAlertModelFromJson,
    );
  }

  Future<CleaningSosAlertModel> createComplaint(
    CreateCleaningComplaintParams params,
  ) async {
    final data = FormData.fromMap(params.getBody());
    for (final path in params.attachmentPaths) {
      final normalized = path.trim();
      if (normalized.isEmpty) continue;
      data.files.add(
        MapEntry(
          'attachments[]',
          await MultipartFile.fromFile(normalized),
        ),
      );
    }

    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/support-cases',
        data: data,
      ),
      jsonConvert: cleaningSosAlertModelFromJson,
    );
  }
}
