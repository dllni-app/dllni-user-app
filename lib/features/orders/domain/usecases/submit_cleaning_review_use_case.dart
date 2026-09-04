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

class CleaningWorkerReviewInput {
  const CleaningWorkerReviewInput({
    required this.workerId,
    required this.rating,
    this.comment,
  });

  final int workerId;
  final int rating;
  final String? comment;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'workerId': workerId,
      'rating': rating,
      if (comment != null && comment!.trim().isNotEmpty)
        'comment': comment!.trim(),
    };
  }
}

class SubmitCleaningReviewParams with Params {
  SubmitCleaningReviewParams({
    required this.orderId,
    this.workerId,
    this.rating,
    this.comment,
    this.tags,
    this.reviews,
  });

  final int orderId;
  final int? workerId;
  final int? rating;
  final String? comment;
  final List<String>? tags;
  final List<CleaningWorkerReviewInput>? reviews;

  @override
  BodyMap getBody() {
    return <String, dynamic>{
      if (rating != null) 'rating': rating,
      if (workerId != null) 'workerId': workerId,
      if (comment != null && comment!.trim().isNotEmpty)
        'comment': comment!.trim(),
      if (tags != null && tags!.isNotEmpty) 'tags': tags,
      if (reviews != null && reviews!.isNotEmpty)
        'reviews': reviews!.map((review) => review.toJson()).toList(),
    };
  }
}
