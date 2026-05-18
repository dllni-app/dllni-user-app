import 'package:common_package/common_package.dart';
import 'package:dartz/dartz.dart';

import '../../data/models/cleaning_worker_profile_model.dart';
import '../../domain/usecases/fetch_cleaning_worker_profile_use_case.dart';

typedef CleaningWorkerProfileFetcher =
    Future<Either<Failure, FetchCleaningWorkerProfileModel>> Function(
      FetchCleaningWorkerProfileParams params,
    );

const String _defaultWorkerProfileErrorMessage =
    'تعذر تحميل بيانات مقدم الخدمة.';

Future<CleaningWorkerProfileModel?> resolveCleaningWorkerProfileForRating({
  required int? workerId,
  required CleaningWorkerProfileFetcher fetchWorkerProfile,
  required void Function(String message) onError,
}) async {
  if (workerId == null || workerId <= 0) {
    onError(_defaultWorkerProfileErrorMessage);
    return null;
  }

  final response = await fetchWorkerProfile(
    FetchCleaningWorkerProfileParams(workerId: workerId),
  );

  return response.fold<CleaningWorkerProfileModel?>(
    (failure) {
      final text = failure.message.trim();
      onError(text.isEmpty ? _defaultWorkerProfileErrorMessage : text);
      return null;
    },
    (result) {
      final profile = result.data;
      if (profile == null || profile.id == null) {
        onError(_defaultWorkerProfileErrorMessage);
        return null;
      }
      return profile;
    },
  );
}
