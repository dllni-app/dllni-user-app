import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/profile_api_models.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class CreateVoteUseCase implements UseCase<CreateVoteModel, CreateVoteParams> {
  final ProfileRepo profileRepo;

  CreateVoteUseCase({required this.profileRepo});

  @override
  DataResponse<CreateVoteModel> call(CreateVoteParams params) {
    return profileRepo.createVote(params);
  }
}

class CreateVoteParams with Params {
  final int durationMinutes;
  final List<Map<String, dynamic>> options;
  final String? foodCategoryHint;
  final int? cuisineTypeId;

  CreateVoteParams({
    required this.durationMinutes,
    required this.options,
    this.foodCategoryHint,
    this.cuisineTypeId,
  });

  @override
  BodyMap getBody() => {
    'durationMinutes': durationMinutes,
    if (foodCategoryHint != null) 'foodCategoryHint': foodCategoryHint,
    'cuisineTypeId': cuisineTypeId,
    'options': options,
  };
}
