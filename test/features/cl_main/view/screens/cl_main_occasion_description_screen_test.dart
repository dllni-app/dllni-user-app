import 'package:common_package/helpers/typedef.dart';
import 'package:dartz/dartz.dart';
import 'package:dllni_user_app/features/cl_main/data/models/cleaning_services_response_model.dart';
import 'package:dllni_user_app/features/cl_main/data/models/create_cleaning_order_response_model.dart';
import 'package:dllni_user_app/features/cl_main/data/models/estimate_price_response_model.dart';
import 'package:dllni_user_app/features/cl_main/data/models/previous_workers_response_model.dart';
import 'package:dllni_user_app/features/cl_main/domain/repository/cl_main_repo.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/create_cleaning_order_use_case.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/estimate_cleaning_price_use_case.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/get_cleaning_services_use_case.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/get_previous_cleaning_workers_use_case.dart';
import 'package:dllni_user_app/features/cl_main/view/data/cl_main_route_args.dart';
import 'package:dllni_user_app/features/cl_main/view/manager/bloc/cl_main_bloc.dart';
import 'package:dllni_user_app/features/cl_main/view/screens/cl_main_occasion_description_screen.dart';
import 'package:dllni_user_app/features/cl_main/view/screens/cl_main_occasion_schedule_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

class _FakeClMainRepo implements ClMainRepo {
  @override
  DataResponse<EstimatePriceResponseModel> estimateCleaningPrice(
    EstimateCleaningPriceParams params,
  ) async {
    return const Right(
      EstimatePriceResponseModel(
        size: EstimateSizeModel(estimatedSqm: 120, estimatedHours: 4),
        pricing: EstimatePricingModel(
          basePrice: 500,
          travelFee: 0,
          addonsTotal: 100,
          totalPrice: 600,
          currency: 'SYP',
        ),
        recommendation: EstimateRecommendationModel(suggestedTeamSize: 4),
      ),
    );
  }

  @override
  DataResponse<CreateCleaningOrderResponseModel> createCleaningOrder(
    CreateCleaningOrderParams params,
  ) async {
    return const Right(CreateCleaningOrderResponseModel(success: true));
  }

  @override
  DataResponse<PreviousWorkersResponseModel> getPreviousCleaningWorkers(
    GetPreviousCleaningWorkersParams params,
  ) async {
    return const Right(
      PreviousWorkersResponseModel(data: <PreviousWorkerModel>[]),
    );
  }

  @override
  DataResponse<CleaningServicesResponseModel> getCleaningServices(
    GetCleaningServicesParams params,
  ) async {
    return const Right(
      CleaningServicesResponseModel(
        data: <CleaningServiceModel>[
          CleaningServiceModel(id: 12, name: 'Event service A'),
        ],
      ),
    );
  }
}

ClMainBloc _buildBloc() {
  final repo = _FakeClMainRepo();
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
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('ar');
  });

  testWidgets('selects service and continues to occasion schedule screen', (
    WidgetTester tester,
  ) async {
    final bloc = _buildBloc();
    addTearDown(bloc.close);

    const option = ClMainOccasionOption(
      id: 'family_dinner',
      title: 'Family Dinner',
      imagePath: 'assets/images/villa_image.png',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ClMainOccasionDescriptionScreen(
          args: ClMainOccasionDescriptionArgs(option: option, bloc: bloc),
        ),
        onGenerateRoute: (settings) {
          if (settings.name == '/clmainoccasionschedule' &&
              settings.arguments is ClMainOccasionScheduleArgs) {
            final args = settings.arguments! as ClMainOccasionScheduleArgs;
            return MaterialPageRoute(
              builder: (_) => ClMainOccasionScheduleScreen(args: args),
            );
          }
          return null;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('occasion_help_type_field')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('menu_option_service_12')));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('occasion_special_requirements_field')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('menu_option_none')));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('occasion_description_continue_button')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(
      find.byKey(const Key('occasion_description_continue_button')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ClMainOccasionScheduleScreen), findsOneWidget);
    expect(
      find.byKey(const Key('occasion_schedule_details_card')),
      findsOneWidget,
    );
  });
}
