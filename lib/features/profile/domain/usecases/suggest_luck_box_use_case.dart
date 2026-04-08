import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/luck_box_api_models.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class SuggestLuckBoxUseCase implements UseCase<LuckBoxSuggestResponseModel, SuggestLuckBoxParams> {
  final ProfileRepo profileRepo;

  SuggestLuckBoxUseCase({required this.profileRepo});

  @override
  DataResponse<LuckBoxSuggestResponseModel> call(SuggestLuckBoxParams params) {
    return profileRepo.suggestLuckBox(params);
  }
}
