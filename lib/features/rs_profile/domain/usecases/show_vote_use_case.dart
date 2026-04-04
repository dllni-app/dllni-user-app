import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/rs_profile_api_models.dart';
import '../repository/rs_profile_repo.dart';

@lazySingleton
class ShowVoteUseCase implements UseCase<ShowVoteModel, ShowVoteParams> {
  final RsProfileRepo rsProfileRepo;

  ShowVoteUseCase({required this.rsProfileRepo});

  @override
  DataResponse<ShowVoteModel> call(ShowVoteParams params) {
    return rsProfileRepo.showVote(params);
  }
}

class ShowVoteParams with Params {
  final int voteId;

  ShowVoteParams({required this.voteId});
}
