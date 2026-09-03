import 'package:dllni_user_app/features/orders/domain/usecases/submit_cleaning_review_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('event review body omits workerId for one parent-level rating', () {
    final body = SubmitCleaningReviewParams(
      orderId: 99,
      rating: 5,
      comment: 'ممتاز',
    ).getBody();

    expect(body['rating'], 5);
    expect(body['comment'], 'ممتاز');
    expect(body.containsKey('workerId'), isFalse);
  });

  test('regular worker review body keeps workerId', () {
    final body = SubmitCleaningReviewParams(
      orderId: 99,
      workerId: 7,
      rating: 4,
    ).getBody();

    expect(body['workerId'], 7);
  });
}
