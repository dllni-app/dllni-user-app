import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/orders_api_models.dart';
import '../repository/orders_repo.dart';

@lazySingleton
class PatchCleaningOrderUseCase
    implements UseCase<OrdersActionResultModel, PatchCleaningOrderParams> {
  final OrdersRepo ordersRepo;

  PatchCleaningOrderUseCase({required this.ordersRepo});

  @override
  DataResponse<OrdersActionResultModel> call(PatchCleaningOrderParams params) {
    return ordersRepo.patchCleaningOrder(params);
  }
}

/// Partial PATCH payload for an existing cleaning booking.
///
/// The backend owns pricing and lifecycle validation, so callers must include
/// only fields that actually changed. In particular, do not rebuild and send
/// the original create-order payload because some configuration fields become
/// immutable after a worker accepts the booking.
class PatchCleaningOrderParams with Params {
  final int cleaningOrderId;
  final BodyMap changes;

  PatchCleaningOrderParams({
    required this.cleaningOrderId,
    required this.changes,
  });

  @override
  BodyMap getBody() => Map<String, dynamic>.from(changes);
}
