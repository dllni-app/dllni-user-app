import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/submit_cleaning_review_model.dart';
import '../repository/orders_repo.dart';

@lazySingleton
class SubmitCleaningReviewUseCase
    implements UseCase<SubmitCleaningReviewModel, SubmitCleaningReviewParams> {
  SubmitCleaningReviewUseCase({required this.ordersRepo});

  final OrdersRepo ordersRepo;

  @override
  DataResponse<SubmitCleaningReviewModel> call(
    SubmitCleaningReviewParams params,
  ) {
    return ordersRepo.submitCleaningReview(params);
  }
}

class SubmitCleaningReviewParams with Params {
  SubmitCleaningReviewParams({
    required this.orderId,
    required this.rating,
    this.comment,
    this.tags,
  });

  final int orderId;
  final int rating;
  final String? comment;
  final List<String>? tags;

  @override
  BodyMap getBody() {
    return <String, dynamic>{
      'rating': rating,
      if (comment != null && comment!.trim().isNotEmpty)
        'comment': comment!.trim(),
      if (tags != null && tags!.isNotEmpty) 'tags': tags,
    };
  }
}
