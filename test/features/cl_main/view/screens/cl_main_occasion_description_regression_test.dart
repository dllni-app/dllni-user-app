import 'dart:async';

import 'package:common_package/helpers/typedef.dart';
import 'package:dartz/dartz.dart';
import 'package:dllni_user_app/features/cl_main/data/models/cleaning_banners_response_model.dart';
import 'package:dllni_user_app/features/cl_main/data/models/cleaning_services_response_model.dart';
import 'package:dllni_user_app/features/cl_main/data/models/create_cleaning_order_response_model.dart';
import 'package:dllni_user_app/features/cl_main/data/models/female_worker_safety_policy_model.dart';
import 'package:dllni_user_app/features/cl_main/data/models/previous_workers_response_model.dart';
import 'package:dllni_user_app/features/cl_main/domain/repository/cl_main_repo.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/create_cleaning_order_use_case.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/estimate_cleaning_price_use_case.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/get_cleaning_banners_use_case.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/get_cleaning_services_use_case.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/get_previous_cleaning_workers_use_case.dart';
import 'package:dllni_user_app/features/cl_main/view/data/cl_main_route_args.dart';
import 'package:dllni_user_app/features/cl_main/view/manager/bloc/cl_main_bloc.dart';
import 'package:dllni_user_app/features/cl_main/view/screens/cl_main_occasion_description_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repo implements ClMainRepo {
  @override
  DataResponse<EstimatePriceResponseModel> estimateCleaningPrice(
    EstimateCleaningPriceParams params,
  ) async => const Right(EstimatePriceResponseModel());

  @override
  DataResponse<CreateCleaningOrderResponseModel> createCleaningOrder(
    CreateCleaningOrderParams params,
  ) async => const Right(CreateCleaningOrderResponseModel(success: true));

  @override
  DataResponse<PreviousWorkersResponseModel> getPreviousCleaningWorkers(
    GetPreviousCleaningWorkersParams params,
  ) async => const Right(PreviousWorkersResponseModel(data: []));

  @override
  DataResponse<CleaningServicesResponseModel> getCleaningServices(
    GetCleaningServicesParams params,
  ) async => const Right(CleaningServicesResponseModel());

  @override
  DataResponse<CleaningBannersResponseModel> getCleaningBanners(
    GetCleaningBannersParams params,
  ) async => const Right(CleaningBannersResponseModel());

  @override
  DataResponse<FemaleWorkerSafetyPolicyModel> getFemaleWorkerSafetyPolicy() {
    throw UnimplementedError();
  }
}

ClMainBloc _bloc() {
  final repo = _Repo();
  return ClMainBloc(
    estimateCleaningPriceUseCase: EstimateCleaningPriceUseCase(
      clMainRepo: repo,
    ),
    getCleaningServicesUseCase: GetCleaningServicesUseCase(clMainRepo: repo),
    getPreviousCleaningWorkersUseCase: GetPreviousCleaningWorkersUseCase(
      clMainRepo: repo,
    ),
    createCleaningOrderUseCase: CreateCleaningOrderUseCase(clMainRepo: repo),
  );
}

void main() {
  for (final value in ['large_gathering', 'birthday', 'funeral']) {
    testWidgets('$value opens its occasion form without late initialization', (
      tester,
    ) async {
      final bloc = _bloc();
      await tester.pumpWidget(
        MaterialApp(
          home: ClMainOccasionDescriptionScreen(
            args: ClMainOccasionDescriptionArgs(
              option: ClMainOccasionOption(
                id: 'admin_card_$value',
                bookingValue: value,
                title: 'مناسبة اختبار',
                imagePath: '',
              ),
              bloc: bloc,
              navigateToScheduleOnEstimate: false,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('مناسبة اختبار'), findsWidgets);
      expect(find.text('مدة الخدمة بالساعات'), findsNothing);
      expect(find.text('الحد الأدنى اللازم للمدة: 1 عامل'), findsNothing);
      // Dispose the widget first so BlocConsumer releases its subscription.
      await tester.pumpWidget(const SizedBox.shrink());
      // Do not block the widget test on unrelated queued Bloc cleanup events.
      unawaited(bloc.close());
    });
  }
}
