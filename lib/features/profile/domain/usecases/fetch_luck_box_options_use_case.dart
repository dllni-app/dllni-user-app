import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/luck_box_api_models.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class FetchLuckBoxOptionsUseCase implements UseCase<LuckBoxOptionsModel, NoParams> {
  final ProfileRepo profileRepo;

  FetchLuckBoxOptionsUseCase({required this.profileRepo});

  @override
  DataResponse<LuckBoxOptionsModel> call(NoParams params) {
    return profileRepo.fetchLuckBoxOptions();
  }
}
