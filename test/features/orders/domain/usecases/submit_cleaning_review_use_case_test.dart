import 'package:dllni_user_app/features/orders/domain/usecases/submit_cleaning_review_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('event review body sends one independent review per worker', () {
    final body = SubmitCleaningReviewParams(
      orderId: 99,
      reviews: const <CleaningWorkerReviewInput>[
        CleaningWorkerReviewInput(workerId: 7, rating: 5, comment: 'ممتاز'),
        CleaningWorkerReviewInput(workerId: 9, rating: 3),
      ],
    ).getBody();

    expect(body.containsKey('rating'), isFalse);
    expect(body.containsKey('workerId'), isFalse);

    final reviews = body['reviews'] as List<dynamic>;
    expect(reviews, hasLength(2));
    expect(reviews[0], <String, dynamic>{
      'workerId': 7,
      'rating': 5,
      'comment': 'ممتاز',
    });
    expect(reviews[1], <String, dynamic>{'workerId': 9, 'rating': 3});
  });

  test('regular worker review body keeps workerId and rating', () {
    final body = SubmitCleaningReviewParams(
      orderId: 99,
      workerId: 7,
      rating: 4,
    ).getBody();

    expect(body['workerId'], 7);
    expect(body['rating'], 4);
    expect(body.containsKey('reviews'), isFalse);
  });
}
