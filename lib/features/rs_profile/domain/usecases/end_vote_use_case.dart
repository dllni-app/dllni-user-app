import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/rs_profile_api_models.dart';
import '../repository/rs_profile_repo.dart';

@lazySingleton
class EndVoteUseCase implements UseCase<ActionResultModel, EndVoteParams> {
  final RsProfileRepo rsProfileRepo;

  EndVoteUseCase({required this.rsProfileRepo});

  @override
  DataResponse<ActionResultModel> call(EndVoteParams params) {
    return rsProfileRepo.endVote(params);
  }
}

class EndVoteParams with Params {
  final int voteId;

  EndVoteParams({required this.voteId});

  @override
  BodyMap getBody() => {};
}
