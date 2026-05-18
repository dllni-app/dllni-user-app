import 'package:common_package/helpers/error_handler.dart';
import 'package:common_package/helpers/typedef.dart';
import 'package:dartz/dartz.dart';
import 'package:dllni_user_app/features/orders/data/models/cleaning_worker_profile_model.dart';
import 'package:dllni_user_app/features/orders/domain/repository/orders_repo.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/fetch_cleaning_worker_profile_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'FetchCleaningWorkerProfileUseCase returns success response from repo',
    () async {
      final repo = _OrdersRepoFake((params) async {
        return const Right(
          FetchCleaningWorkerProfileModel(
            data: CleaningWorkerProfileModel(id: 44, firstName: 'Worker'),
          ),
        );
      });
      final useCase = FetchCleaningWorkerProfileUseCase(ordersRepo: repo);

      final result = await useCase(
        FetchCleaningWorkerProfileParams(workerId: 44),
      );

      expect(result.isRight(), isTrue);
      expect(
        result
            .getOrElse(() => const FetchCleaningWorkerProfileModel())
            .data
            ?.id,
        44,
      );
    },
  );

  test(
    'FetchCleaningWorkerProfileUseCase returns failure response from repo',
    () async {
      final repo = _OrdersRepoFake((params) async {
        return const Left(ServerFailure(message: 'failed'));
      });
      final useCase = FetchCleaningWorkerProfileUseCase(ordersRepo: repo);

      final result = await useCase(
        FetchCleaningWorkerProfileParams(workerId: 44),
      );

      expect(result.isLeft(), isTrue);
      expect(result.fold((failure) => failure.message, (_) => ''), 'failed');
    },
  );
}

class _OrdersRepoFake implements OrdersRepo {
  _OrdersRepoFake(this._fetchWorkerProfile);

  final DataResponse<FetchCleaningWorkerProfileModel> Function(
    FetchCleaningWorkerProfileParams params,
  )
  _fetchWorkerProfile;

  @override
  DataResponse<FetchCleaningWorkerProfileModel> fetchCleaningWorkerProfile(
    FetchCleaningWorkerProfileParams params,
  ) {
    return _fetchWorkerProfile(params);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
