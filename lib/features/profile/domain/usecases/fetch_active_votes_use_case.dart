import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/profile_api_models.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class FetchActiveVotesUseCase
    implements UseCase<FetchActiveVotesModel, FetchActiveVotesParams> {
  final ProfileRepo profileRepo;

  FetchActiveVotesUseCase({required this.profileRepo});

  @override
  DataResponse<FetchActiveVotesModel> call(FetchActiveVotesParams params) {
    return profileRepo.fetchActiveVotes(params);
  }
}

class FetchActiveVotesParams with Params {}
