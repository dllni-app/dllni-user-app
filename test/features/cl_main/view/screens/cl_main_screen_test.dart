import 'package:common_package/helpers/typedef.dart';
import 'package:dartz/dartz.dart';
import 'package:dllni_user_app/features/cl_main/data/models/cleaning_banners_response_model.dart';
import 'package:dllni_user_app/features/cl_main/data/models/cleaning_services_response_model.dart';
import 'package:dllni_user_app/features/cl_main/data/models/create_cleaning_order_response_model.dart';
import 'package:dllni_user_app/features/cl_main/data/models/estimate_price_response_model.dart';
import 'package:dllni_user_app/features/cl_main/data/models/female_worker_safety_policy_model.dart';
import 'package:dllni_user_app/features/cl_main/data/models/previous_workers_response_model.dart';
import 'package:dllni_user_app/features/cl_main/domain/repository/cl_main_repo.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/create_cleaning_order_use_case.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/estimate_cleaning_price_use_case.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/get_cleaning_banners_use_case.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/get_cleaning_services_use_case.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/get_previous_cleaning_workers_use_case.dart';
import 'package:dllni_user_app/features/cl_main/view/manager/bloc/cl_main_bloc.dart';
import 'package:dllni_user_app/features/cl_main/view/screens/cl_main_screen.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_occasion_type_card_widget.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_property_type_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeClMainRepo implements ClMainRepo {
  @override
  DataResponse<EstimatePriceResponseModel> estimateCleaningPrice(
    EstimateCleaningPriceParams params,
  ) async {
    return const Right(EstimatePriceResponseModel());
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
    return const Right(CleaningServicesResponseModel());
  }

  @override
  DataResponse<CleaningBannersResponseModel> getCleaningBanners(
    GetCleaningBannersParams params,
  ) async {
    return const Right(CleaningBannersResponseModel());
  }

  @override
  DataResponse<FemaleWorkerSafetyPolicyModel> getFemaleWorkerSafetyPolicy() {
    // TODO: implement getFemaleWorkerSafetyPolicy
    throw UnimplementedError();
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
  testWidgets('shows cleaning banner and switches to occasions list', (
    WidgetTester tester,
  ) async {
    final bloc = _buildBloc();
    addTearDown(bloc.close);

    await tester.pumpWidget(MaterialApp(home: ClMainScreen(bloc: bloc)));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.byKey(const Key('cl_main_featured_banner_section')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('cl_main_featured_banner_page_view')),
      findsOneWidget,
    );

    expect(find.byKey(const Key('cl_main_cleaning_tab')), findsOneWidget);
    expect(find.byKey(const Key('cl_main_occasions_tab')), findsOneWidget);
    expect(find.byKey(const Key('cl_main_cleaning_list')), findsOneWidget);
    expect(find.byType(ClPropertyTypeCardWidget), findsWidgets);

    await tester.tap(find.byKey(const Key('cl_main_occasions_tab')));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byKey(const Key('cl_main_occasions_list')), findsOneWidget);
    expect(find.byType(ClOccasionTypeCardWidget), findsWidgets);
    expect(find.byType(ClPropertyTypeCardWidget), findsNothing);
  }, skip: true);
}
