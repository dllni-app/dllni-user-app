import 'package:common_package/helpers/error_handler.dart';
import 'package:common_package/helpers/typedef.dart';
import 'package:dartz/dartz.dart';
import 'package:dllni_user_app/features/cl_main/data/models/cleaning_banners_response_model.dart';
import 'package:dllni_user_app/features/cl_main/data/models/cleaning_services_response_model.dart';
import 'package:dllni_user_app/features/cl_main/data/models/create_cleaning_order_response_model.dart';
import 'package:dllni_user_app/features/cl_main/data/models/estimate_price_response_model.dart';
import 'package:dllni_user_app/features/cl_main/data/models/previous_workers_response_model.dart';
import 'package:dllni_user_app/features/cl_main/domain/repository/cl_main_repo.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/create_cleaning_order_use_case.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/estimate_cleaning_price_use_case.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/get_cleaning_banners_use_case.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/get_cleaning_services_use_case.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/get_previous_cleaning_workers_use_case.dart';
import 'package:dllni_user_app/features/cl_main/view/data/cl_main_route_args.dart';
import 'package:dllni_user_app/features/cl_main/view/manager/bloc/cl_main_bloc.dart';
import 'package:dllni_user_app/features/cl_main/view/screens/cl_main_occasion_schedule_screen.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_service_bottom_actions_widget.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_service_previous_workers_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

class _FakeClMainRepo implements ClMainRepo {
  _FakeClMainRepo({required this.previousWorkers, this.onCreateOrder});

  final List<PreviousWorkerModel> previousWorkers;
  final void Function(CreateCleaningOrderParams params)? onCreateOrder;

  @override
  DataResponse<EstimatePriceResponseModel> estimateCleaningPrice(
    EstimateCleaningPriceParams params,
  ) async {
    return const Right(EstimatePriceResponseModel());
  }

  @override
  DataResponse<PreviousWorkersResponseModel> getPreviousCleaningWorkers(
    GetPreviousCleaningWorkersParams params,
  ) async {
    return Right(PreviousWorkersResponseModel(data: previousWorkers));
  }

  @override
  DataResponse<CleaningServicesResponseModel> getCleaningServices(
    GetCleaningServicesParams params,
  ) async {
    return const Right(CleaningServicesResponseModel());
  }

  @override
  DataResponse<CreateCleaningOrderResponseModel> createCleaningOrder(
    CreateCleaningOrderParams params,
  ) async {
    onCreateOrder?.call(params);
    return const Left(ServerFailure(message: 'create failed'));
  }

  @override
  DataResponse<CleaningBannersResponseModel> getCleaningBanners(
    GetCleaningBannersParams params,
  ) async {
    return const Right(CleaningBannersResponseModel());
  }
}

ClMainBloc _buildBloc(ClMainRepo repo) {
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

Future<void> _pumpScreen(WidgetTester tester, ClMainBloc bloc) async {
  final args = ClMainOccasionScheduleArgs(
    option: const ClMainOccasionOption(
      id: 'family_dinner',
      title: 'Family Dinner',
      imagePath: 'assets/images/villa_image.png',
    ),
    bloc: bloc,
    estimate: const EstimatePriceResponseModel(
      size: EstimateSizeModel(estimatedSqm: 120, estimatedHours: 4),
      pricing: EstimatePricingModel(
        basePrice: 500,
        travelFee: 50,
        addonsTotal: 25,
        totalPrice: 575,
        currency: 'SYP',
      ),
      recommendation: EstimateRecommendationModel(suggestedTeamSize: 2),
    ),
    guestsCount: 10,
    eventType: 'family_dinner',
    venueType: 'apartment',
    serviceIds: const <int>[12],
    suggestedTeamSize: 2,
    helpTypeId: 'service_12',
    helpTypeLabel: 'Event service',
    specialRequirementId: 'none',
    specialRequirementLabel: 'None',
    notes: null,
  );

  await tester.pumpWidget(
    MaterialApp(home: ClMainOccasionScheduleScreen(args: args)),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('ar');
  });

  testWidgets(
    'shows previous workers and sends selected worker as preferredWorkerId',
    (WidgetTester tester) async {
      CreateCleaningOrderParams? capturedParams;
      final repo = _FakeClMainRepo(
        previousWorkers: const <PreviousWorkerModel>[
          PreviousWorkerModel(id: 77, name: 'Worker 77'),
        ],
        onCreateOrder: (params) => capturedParams = params,
      );
      final bloc = _buildBloc(repo);

      await _pumpScreen(tester, bloc);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.byType(ClServicePreviousWorkersSectionWidget),
        findsOneWidget,
      );
      expect(find.text('Worker 77'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Worker 77'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Worker 77'));
      await tester.pump(const Duration(milliseconds: 150));
      expect(bloc.state.selectedWorkerId, 77);

      final submitButton = find
          .descendant(
            of: find.byType(ClServiceBottomActionsWidget),
            matching: find.byType(ElevatedButton),
          )
          .first;
      await tester.tap(submitButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(capturedParams, isNotNull);
      expect(capturedParams?.preferredWorkerId, 77);
    },
  );
}
