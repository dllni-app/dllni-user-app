import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:dartz/dartz.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/features/cl_main/data/models/cleaning_banners_response_model.dart';
import 'package:dllni_user_app/features/cl_main/data/models/cleaning_services_response_model.dart';
import 'package:dllni_user_app/features/cl_main/data/models/cleaning_suite_config_model.dart';
import 'package:dllni_user_app/features/cl_main/data/models/create_cleaning_order_response_model.dart';
import 'package:dllni_user_app/features/cl_main/data/models/female_worker_safety_policy_model.dart';
import 'package:dllni_user_app/features/cl_main/data/models/previous_workers_response_model.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_room_size_breakdown.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_recurring_session.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_type.dart';
import 'package:dllni_user_app/features/cl_main/domain/repository/cl_main_repo.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/create_cleaning_order_use_case.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/estimate_cleaning_price_use_case.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/get_cleaning_banners_use_case.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/get_cleaning_services_use_case.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/get_previous_cleaning_workers_use_case.dart';
import 'package:dllni_user_app/features/cl_main/view/data/cl_main_route_args.dart';
import 'package:dllni_user_app/features/cl_main/view/manager/bloc/cl_main_bloc.dart';
import 'package:dllni_user_app/features/cl_main/view/screens/cl_main_service_schedule_screen.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_scheduled_previous_workers_section_widget.dart';
import 'package:dllni_user_app/features/profile/domain/models/address_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

class _QuoteRepo implements ClMainRepo {
  _QuoteRepo({this.failFirstEstimate = false, this.holdEstimates = false});

  final bool failFirstEstimate;
  final bool holdEstimates;
  int estimateCalls = 0;
  final List<EstimateCleaningPriceParams> estimateParams = [];
  final List<Completer<Either<Failure, EstimatePriceResponseModel>>>
  pendingEstimates = [];
  final List<double?> previousWorkerDurations = [];

  @override
  DataResponse<EstimatePriceResponseModel> estimateCleaningPrice(
    EstimateCleaningPriceParams params,
  ) async {
    estimateCalls++;
    estimateParams.add(params);
    if (holdEstimates) {
      final pending = Completer<Either<Failure, EstimatePriceResponseModel>>();
      pendingEstimates.add(pending);
      return pending.future;
    }
    if (failFirstEstimate && estimateCalls == 1) {
      return const Left(ServerFailure(message: 'Temporary estimate failure'));
    }
    return const Right(
      EstimatePriceResponseModel(
        size: EstimateSizeModel(estimatedHours: 4),
        pricing: EstimatePricingModel(totalPrice: 250, travelFee: 25),
      ),
    );
  }

  @override
  DataResponse<PreviousWorkersResponseModel> getPreviousCleaningWorkers(
    GetPreviousCleaningWorkersParams params,
  ) async {
    previousWorkerDurations.add(params.durationHours);
    return const Right(PreviousWorkersResponseModel(data: []));
  }

  @override
  DataResponse<CleaningServicesResponseModel> getCleaningServices(
    GetCleaningServicesParams params,
  ) async => const Right(CleaningServicesResponseModel());

  @override
  DataResponse<CreateCleaningOrderResponseModel> createCleaningOrder(
    CreateCleaningOrderParams params,
  ) async => const Right(CreateCleaningOrderResponseModel(success: true));

  @override
  DataResponse<CleaningBannersResponseModel> getCleaningBanners(
    GetCleaningBannersParams params,
  ) async => const Right(CleaningBannersResponseModel());

  @override
  DataResponse<FemaleWorkerSafetyPolicyModel> getFemaleWorkerSafetyPolicy() {
    throw UnimplementedError();
  }
}

ClMainBloc _buildBloc(_QuoteRepo repo) => ClMainBloc(
  estimateCleaningPriceUseCase: EstimateCleaningPriceUseCase(clMainRepo: repo),
  getCleaningServicesUseCase: GetCleaningServicesUseCase(clMainRepo: repo),
  getPreviousCleaningWorkersUseCase: GetPreviousCleaningWorkersUseCase(
    clMainRepo: repo,
  ),
  createCleaningOrderUseCase: CreateCleaningOrderUseCase(clMainRepo: repo),
);

const _address = AddressListItem(
  id: '10',
  label: 'المنزل',
  line1: 'حلب، الفرقان',
  type: AddressType.home,
  latitude: 36.21,
  longitude: 37.15,
);

ClMainScheduleArgs _args(
  ClMainBloc bloc, {
  required int step,
  EstimatePriceResponseModel? estimate,
  Map<String, dynamic> draftOverrides = const {},
}) => ClMainScheduleArgs(
  propertyType: 'apartment',
  bedrooms: 1,
  rooms: 1,
  bathrooms: 0,
  livingRoomSize: 'small',
  roomSizeBreakdown: const CleaningRoomSizeBreakdown(
    bedroom: CleaningRoomSizeBucket(medium: 1),
  ),
  addressLatitude: _address.latitude!,
  addressLongitude: _address.longitude!,
  estimate: estimate,
  cleaningType: CleaningType.regularCleaning,
  bloc: bloc,
  defaultAddress: _address,
  draft: <String, dynamic>{
    'step': step,
    'date': DateTime(2026, 10, 20),
    'dateChosen': true,
    'timeChosen': true,
    'time': '09:00',
    'specialServicesCatalog': const <CleaningServiceModel>[],
    'suiteConfig': const CleaningSuiteConfigModel(),
    ...draftOverrides,
  },
);

const _staleEstimate = EstimatePriceResponseModel(
  size: EstimateSizeModel(estimatedHours: 3),
  pricing: EstimatePricingModel(totalPrice: 999, travelFee: 25),
);

const _freshEstimate = EstimatePriceResponseModel(
  size: EstimateSizeModel(estimatedHours: 4),
  pricing: EstimatePricingModel(totalPrice: 250, travelFee: 25),
);

void main() {
  setUpAll(() async => initializeDateFormatting('ar'));

  tearDown(() async => getIt.reset());

  testWidgets('materials retry sends another estimate after initial failure', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = _QuoteRepo(failFirstEstimate: true);
    final bloc = _buildBloc(repo);
    addTearDown(() => unawaited(bloc.close()));

    await tester.pumpWidget(
      MaterialApp(
        home: ClMainServiceScheduleScreen(args: _args(bloc, step: 0)),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(repo.estimateCalls, 1);
    final retry = find.text('إعادة تحميل المواد');
    expect(retry, findsOneWidget);

    await tester.ensureVisible(retry);
    await tester.tap(retry);
    await tester.pump();
    await tester.pump();
    expect(repo.estimateCalls, 2);
    expect(tester.takeException(), isNull);
    // The error toast owns a three-second timer, independent of this screen.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'restored worker step fetches estimate before checking availability',
    (tester) async {
      tester.view.physicalSize = const Size(430, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = _QuoteRepo();
      final bloc = _buildBloc(repo);
      addTearDown(() => unawaited(bloc.close()));
      getIt.registerSingleton<GetPreviousCleaningWorkersUseCase>(
        GetPreviousCleaningWorkersUseCase(clMainRepo: repo),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ClMainServiceScheduleScreen(args: _args(bloc, step: 3)),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(repo.estimateCalls, greaterThanOrEqualTo(1));
      expect(repo.previousWorkerDurations, isNotEmpty);
      expect(repo.previousWorkerDurations, everyElement(greaterThan(0)));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('recurring specific without worker IDs bootstraps picker', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = _QuoteRepo();
    final bloc = _buildBloc(repo);
    addTearDown(() => unawaited(bloc.close()));
    getIt.registerSingleton<GetPreviousCleaningWorkersUseCase>(
      GetPreviousCleaningWorkersUseCase(clMainRepo: repo),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ClMainServiceScheduleScreen(
          args: _args(
            bloc,
            step: 3,
            draftOverrides: {
              'recurringEnabled': true,
              'recurringWorkerScope': CleaningRecurringWorkerScope.specific,
              'recurringCalculationMode':
                  CleaningRecurringCalculationMode.hours,
              'recurringHoursPerVisit': 2.0,
              'recurringSessions': [
                CleaningRecurringSessionInput(
                  date: DateTime(2026, 10, 20),
                  time: '09:00',
                ),
                CleaningRecurringSessionInput(
                  date: DateTime(2026, 10, 27),
                  time: '09:00',
                ),
              ],
            },
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(repo.estimateCalls, 1);
    expect(repo.estimateParams.single.preferredWorkerIds, isEmpty);
    expect(
      repo.estimateParams.single.recurringWorkerScope,
      CleaningRecurringWorkerScope.any,
    );
    expect(repo.previousWorkerDurations, everyElement(greaterThan(0)));
    expect(
      find.byType(ClScheduledPreviousWorkersSectionWidget),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('stale route quote is dropped on failure and retry recovers', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = _QuoteRepo(failFirstEstimate: true);
    final bloc = _buildBloc(repo);
    addTearDown(() => unawaited(bloc.close()));
    getIt.registerSingleton<GetPreviousCleaningWorkersUseCase>(
      GetPreviousCleaningWorkersUseCase(clMainRepo: repo),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: ClMainServiceScheduleScreen(
          args: _args(bloc, step: 3, estimate: _staleEstimate),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(repo.estimateCalls, 1);
    expect(repo.previousWorkerDurations, isEmpty);
    expect(bloc.state.estimatePrice, isNull);
    final retry = find.text('إعادة المحاولة');
    expect(retry, findsOneWidget);
    await tester.ensureVisible(retry);
    await tester.tap(retry);
    await tester.pump();
    await tester.pump();
    expect(repo.estimateCalls, 2);
    expect(bloc.state.estimatePrice?.pricing?.totalPrice, 250);
    expect(repo.previousWorkerDurations, isNotEmpty);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('normal cleaning shows editable global notes with no extras', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = _QuoteRepo();
    final bloc = _buildBloc(repo);
    addTearDown(() => unawaited(bloc.close()));
    final args = _args(bloc, step: 1);
    await tester.pumpWidget(
      MaterialApp(home: ClMainServiceScheduleScreen(args: args)),
    );
    await tester.pump();
    final notes = find.byKey(const Key('booking_global_notes'));
    expect(notes, findsOneWidget);
    await tester.ensureVisible(notes);
    await tester.enterText(notes, 'يرجى الانتباه للأثاث');
    await tester.pumpWidget(const SizedBox.shrink());
    expect(args.draft!['notes'], 'يرجى الانتباه للأثاث');
  });

  test(
    'latest concurrent quote wins even when older success arrives last',
    () async {
      final repo = _QuoteRepo(holdEstimates: true);
      final bloc = _buildBloc(repo);
      addTearDown(() => unawaited(bloc.close()));
      final params = EstimateCleaningPriceParams.hourlyWorker(
        addressId: 10,
        workerCount: 1,
        expectedMaxMinutes: 120,
      );
      bloc.add(EstimateCleaningPriceEvent(params: params));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      bloc.add(EstimateCleaningPriceEvent(params: params));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(repo.pendingEstimates, hasLength(2));
      repo.pendingEstimates[1].complete(const Right(_freshEstimate));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.estimatePrice?.pricing?.totalPrice, 250);
      repo.pendingEstimates[0].complete(const Right(_staleEstimate));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.estimatePrice?.pricing?.totalPrice, 250);
      expect(bloc.state.estimatePriceStatus, BlocStatus.success);
    },
  );

  test('stale failure cannot overwrite later successful quote', () async {
    final repo = _QuoteRepo(holdEstimates: true);
    final bloc = _buildBloc(repo);
    addTearDown(() => unawaited(bloc.close()));
    final params = EstimateCleaningPriceParams.hourlyWorker(
      addressId: 10,
      workerCount: 1,
      expectedMaxMinutes: 120,
    );
    bloc.add(EstimateCleaningPriceEvent(params: params));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    bloc.add(EstimateCleaningPriceEvent(params: params));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(repo.pendingEstimates, hasLength(2));
    repo.pendingEstimates[1].complete(const Right(_freshEstimate));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    repo.pendingEstimates[0].complete(
      const Left(ServerFailure(message: 'Old connection error')),
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(bloc.state.estimatePrice?.pricing?.totalPrice, 250);
    expect(bloc.state.estimatePriceStatus, BlocStatus.success);
  });
}
