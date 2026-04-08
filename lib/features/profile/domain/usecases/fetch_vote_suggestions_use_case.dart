import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/profile_api_models.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class FetchVoteSuggestionsUseCase
    implements UseCase<VoteSuggestionsModel, FetchVoteSuggestionsParams> {
  final ProfileRepo profileRepo;

  FetchVoteSuggestionsUseCase({required this.profileRepo});

  @override
  DataResponse<VoteSuggestionsModel> call(FetchVoteSuggestionsParams params) {
    return profileRepo.fetchVoteSuggestions(params);
  }
}

class FetchVoteSuggestionsParams with Params {
  final String search;

  FetchVoteSuggestionsParams({required this.search});

  @override
  QueryParams getParams() => {'search': search};
}
