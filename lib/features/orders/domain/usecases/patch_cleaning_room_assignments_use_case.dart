import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/cleaning_orders_api_models.dart';
import '../repository/orders_repo.dart';

@lazySingleton
class PatchCleaningRoomAssignmentsUseCase
    implements
        UseCase<
          FetchCleaningOrderDetailsModel,
          PatchCleaningRoomAssignmentsParams
        > {
  final OrdersRepo ordersRepo;

  PatchCleaningRoomAssignmentsUseCase({required this.ordersRepo});

  @override
  DataResponse<FetchCleaningOrderDetailsModel> call(
    PatchCleaningRoomAssignmentsParams params,
  ) {
    return ordersRepo.patchCleaningRoomAssignments(params);
  }
}

class CleaningRoomAssignmentUpdate {
  const CleaningRoomAssignmentUpdate({
    required this.roomId,
    this.workerId,
  });

  final int roomId;
  final int? workerId;

  Map<String, dynamic> toJson() => {
    'roomId': roomId,
    'workerId': workerId,
  };
}

class PatchCleaningRoomAssignmentsParams with Params {
  final int orderId;
  final List<CleaningRoomAssignmentUpdate> assignments;

  PatchCleaningRoomAssignmentsParams({
    required this.orderId,
    required this.assignments,
  });

  @override
  BodyMap getBody() => {
    'assignments': assignments.map((item) => item.toJson()).toList(),
  };
}
