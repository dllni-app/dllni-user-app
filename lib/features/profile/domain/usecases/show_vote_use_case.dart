import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/profile_api_models.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class ShowVoteUseCase implements UseCase<ShowVoteModel, ShowVoteParams> {
  final ProfileRepo profileRepo;

  ShowVoteUseCase({required this.profileRepo});

  @override
  DataResponse<ShowVoteModel> call(ShowVoteParams params) {
    return profileRepo.showVote(params);
  }
}

class ShowVoteParams with Params {
  final int voteId;

  ShowVoteParams({required this.voteId});
}
