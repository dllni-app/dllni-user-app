import 'dart:io';

import 'package:common_package/helpers/api_handler.dart';
import 'package:common_package/helpers/dio_network.dart';

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
  ) {
    final data = <String, dynamic>{...params.getBody()};
    final files = params.attachmentPaths
        .map((path) => path.trim())
        .where((path) => path.isNotEmpty)
        .map(File.new)
        .toList(growable: false);

    if (files.isNotEmpty) {
      data['attachments[]'] = files;
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
