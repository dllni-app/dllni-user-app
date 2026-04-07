import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../repository/rs_home_repo.dart';

@lazySingleton
class ReorderLatestOrderedProductUseCase
    implements UseCase<bool, ReorderLatestOrderedProductParams> {
  final RsHomeRepo rsHomeRepo;

  ReorderLatestOrderedProductUseCase({required this.rsHomeRepo});

  @override
  DataResponse<bool> call(ReorderLatestOrderedProductParams params) {
    return rsHomeRepo.reorderLatestOrderedProduct();
  }
}

class ReorderLatestOrderedProductParams with Params {
  const ReorderLatestOrderedProductParams();
}
