import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/profile_api_models.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class EndVoteUseCase implements UseCase<ActionResultModel, EndVoteParams> {
  final ProfileRepo profileRepo;

  EndVoteUseCase({required this.profileRepo});

  @override
  DataResponse<ActionResultModel> call(EndVoteParams params) {
    return profileRepo.endVote(params);
  }
}

class EndVoteParams with Params {
  final int voteId;

  EndVoteParams({required this.voteId});

  @override
  BodyMap getBody() => {};
}
