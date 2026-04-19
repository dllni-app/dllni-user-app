import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/profile_api_models.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class SubmitVoteBallotUseCase
    implements UseCase<ActionResultModel, SubmitVoteBallotParams> {
  final ProfileRepo profileRepo;

  SubmitVoteBallotUseCase({required this.profileRepo});

  @override
  DataResponse<ActionResultModel> call(SubmitVoteBallotParams params) {
    return profileRepo.submitVoteBallot(params);
  }
}

class SubmitVoteBallotParams with Params {
  final int voteId;
  final int optionId;

  SubmitVoteBallotParams({required this.voteId, required this.optionId});

  @override
  BodyMap getBody() => <String, dynamic>{'optionId': optionId};
}
