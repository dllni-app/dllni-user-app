import 'package:common_package/common_package.dart';
import 'package:dllni_user/features/cl_main/data/models/create_cleaning_order_response_model.dart';
import 'package:dllni_user/features/cl_main/view/manager/bloc/cl_main_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('clearing create-order state removes the previous booking result', () {
    final previous = ClMainState(
      createOrderStatus: BlocStatus.success,
      createOrderResult: const CreateCleaningOrderResponseModel(
        success: true,
        orderId: 26,
      ),
      errorMessage: 'old error',
    );

    final reset = previous.copyWith(
      createOrderStatus: BlocStatus.init,
      clearCreateOrderResult: true,
      clearErrorMessage: true,
    );

    expect(reset.createOrderStatus, BlocStatus.init);
    expect(reset.createOrderResult, isNull);
    expect(reset.errorMessage, isNull);
  });
}
