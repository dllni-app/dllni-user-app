import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/cleaning_cancellation_fee_model.dart';
import '../repository/orders_repo.dart';

@lazySingleton
class FetchCleaningCancellationFeeUseCase
    implements UseCase<CleaningCancellationFeeModel, NoParams> {
  final OrdersRepo ordersRepo;

  FetchCleaningCancellationFeeUseCase({required this.ordersRepo});

  @override
  DataResponse<CleaningCancellationFeeModel> call(NoParams params) {
    return ordersRepo.fetchCleaningCancellationFee();
  }
}
