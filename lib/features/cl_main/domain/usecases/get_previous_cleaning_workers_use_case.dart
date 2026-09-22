import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/previous_workers_response_model.dart';
import '../models/cleaning_event_session.dart';
import '../repository/cl_main_repo.dart';

@lazySingleton
class GetPreviousCleaningWorkersUseCase
    implements
        UseCase<
          PreviousWorkersResponseModel,
          GetPreviousCleaningWorkersParams
        > {
  final ClMainRepo clMainRepo;

  GetPreviousCleaningWorkersUseCase({required this.clMainRepo});

  @override
  DataResponse<PreviousWorkersResponseModel> call(
    GetPreviousCleaningWorkersParams params,
  ) {
    return clMainRepo.getPreviousCleaningWorkers(params);
  }
}

class GetPreviousCleaningWorkersParams with Params {
  final int page;
  final int perPage;
  final String? propertyType;
  final String? scheduledDate;
  final String? scheduledTime;
  final double? durationHours;
  final List<CleaningEventSessionInput> eventSessions;

  GetPreviousCleaningWorkersParams({
    this.page = 1,
    this.perPage = 10,
    this.propertyType,
    this.scheduledDate,
    this.scheduledTime,
    this.durationHours,
    this.eventSessions = const <CleaningEventSessionInput>[],
  });

  @override
  QueryParams getParams() {
    final sessions = eventSessions.normalized;
    final params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (propertyType != null && propertyType!.isNotEmpty)
        'propertyType': propertyType,
    };

    if (sessions.length > 1) {
      params['schedule[mode]'] = 'multi_day';
      for (var index = 0; index < sessions.length; index++) {
        final session = sessions[index];
        params['schedule[sessions][$index][date]'] = session.dateApi;
        params['schedule[sessions][$index][time]'] = session.time;
        params['schedule[sessions][$index][hours]'] = session.hours;
      }
      return params;
    }

    params.addAll(<String, dynamic>{
      if (scheduledDate != null && scheduledDate!.isNotEmpty)
        'scheduledDate': scheduledDate,
      if (scheduledTime != null && scheduledTime!.isNotEmpty)
        'scheduledTime': scheduledTime,
      if (durationHours != null && durationHours! > 0)
        'durationHours': durationHours,
    });
    return params;
  }
}
