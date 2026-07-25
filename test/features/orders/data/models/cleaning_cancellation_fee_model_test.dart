import 'package:dllni_user_app/features/orders/data/models/cleaning_cancellation_fee_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses cleaning cancellation fee payload', () {
    final model = CleaningCancellationFeeModel.fromJson({
      'amount': 15000.5,
      'currency': 'SYP',
    });

    expect(model.amount, 15000.5);
    expect(model.currency, 'SYP');
  });

  test('defaults missing amount and currency', () {
    final model = CleaningCancellationFeeModel.fromJson({});

    expect(model.amount, 0);
    expect(model.currency, 'SYP');
  });
}
