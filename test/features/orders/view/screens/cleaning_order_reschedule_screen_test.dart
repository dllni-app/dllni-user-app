import 'dart:async';

import 'package:common_package/helpers/error_handler.dart';
import 'package:common_package/helpers/typedef.dart';
import 'package:dartz/dartz.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/models/cleaning_gender_preference.dart';
import 'package:dllni_user_app/features/cl_main/data/models/create_cleaning_order_response_model.dart';
import 'package:dllni_user_app/features/cl_main/data/models/estimate_price_response_model.dart';
import 'package:dllni_user_app/features/cl_main/data/models/previous_workers_response_model.dart';
import 'package:dllni_user_app/features/cl_main/domain/repository/cl_main_repo.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/create_cleaning_order_use_case.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/estimate_cleaning_price_use_case.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/get_previous_cleaning_workers_use_case.dart';
import 'package:dllni_user_app/features/cl_main/view/manager/bloc/cl_main_bloc.dart';
import 'package:dllni_user_app/features/orders/data/models/cleaning_order_cancel_api_models.dart';
import 'package:dllni_user_app/features/orders/data/models/cleaning_orders_api_models.dart';
import 'package:dllni_user_app/features/orders/domain/repository/orders_repo.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/cancel_cleaning_order_use_case.dart';
import 'package:dllni_user_app/features/orders/view/screens/cleaning_order_reschedule_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

class _FakeClMainRepo implements ClMainRepo {
  _FakeClMainRepo({
    required DataResponse<EstimatePriceResponseModel> Function(
      EstimateCleaningPriceParams params,
    )
    estimateHandler,
    this.createOrderHandler,
  }) : _estimateHandler = estimateHandler;

  final DataResponse<EstimatePriceResponseModel> Function(
    EstimateCleaningPriceParams params,
  )
  _estimateHandler;

  final DataResponse<CreateCleaningOrderResponseModel> Function(
    CreateCleaningOrderParams params,
  )?
  createOrderHandler;

  @override
  DataResponse<EstimatePriceResponseModel> estimateCleaningPrice(
    EstimateCleaningPriceParams params,
  ) {
    return _estimateHandler(params);
  }

  @override
  DataResponse<CreateCleaningOrderResponseModel> createCleaningOrder(
    CreateCleaningOrderParams params,
  ) {
    final handler = createOrderHandler;
    if (handler == null) {
      throw UnimplementedError();
    }
    return handler(params);
  }

  @override
  DataResponse<PreviousWorkersResponseModel> getPreviousCleaningWorkers(
    GetPreviousCleaningWorkersParams params,
  ) async {
    return const Right(
      PreviousWorkersResponseModel(data: <PreviousWorkerModel>[]),
    );
  }
}

class _FakeOrdersRepo implements OrdersRepo {
  _FakeOrdersRepo(this._cancelHandler);

  final DataResponse<CleaningCancelResultModel> Function(
    CancelCleaningOrderParams params,
  )
  _cancelHandler;

  @override
  DataResponse<CleaningCancelResultModel> cancelCleaningOrder(
    CancelCleaningOrderParams params,
  ) {
    return _cancelHandler(params);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

String _dateOnly(DateTime dateTime) =>
    '${dateTime.year.toString().padLeft(4, '0')}-'
    '${dateTime.month.toString().padLeft(2, '0')}-'
    '${dateTime.day.toString().padLeft(2, '0')}';

Future<void> _pumpScreen(
  WidgetTester tester,
  EstimateCleaningPriceUseCase useCase, {
  CleaningOrderModel? order,
}) async {
  if (getIt.isRegistered<ClMainBloc>()) {
    await getIt.unregister<ClMainBloc>();
  }
  if (getIt.isRegistered<CreateCleaningOrderUseCase>()) {
    await getIt.unregister<CreateCleaningOrderUseCase>();
  }
  if (getIt.isRegistered<CancelCleaningOrderUseCase>()) {
    await getIt.unregister<CancelCleaningOrderUseCase>();
  }

  final createUseCase = CreateCleaningOrderUseCase(
    clMainRepo: useCase.clMainRepo,
  );
  final workersUseCase = GetPreviousCleaningWorkersUseCase(
    clMainRepo: useCase.clMainRepo,
  );
  final cancelUseCase = CancelCleaningOrderUseCase(
    ordersRepo: _FakeOrdersRepo(
      (_) async => Right(CleaningCancelResultModel(message: 'cancelled')),
    ),
  );

  getIt.registerLazySingleton<CreateCleaningOrderUseCase>(() => createUseCase);
  getIt.registerLazySingleton<CancelCleaningOrderUseCase>(() => cancelUseCase);
  getIt.registerFactory<ClMainBloc>(
    () => ClMainBloc(
      estimateCleaningPriceUseCase: useCase,
      getPreviousCleaningWorkersUseCase: workersUseCase,
      createCleaningOrderUseCase: createUseCase,
    ),
  );

  final fallbackOrder = CleaningOrderModel(
    id: 7,
    propertyType: 'villa',
    scheduledDate: _dateOnly(DateTime.now().add(const Duration(days: 3))),
    scheduledTime: '11:00',
    addressLatitude: 33.6,
    addressLongitude: 36.4,
    propertyDetails: CleaningPropertyDetailsModel(
      address: 'Test Address',
      bedrooms: 2,
      rooms: 3,
      bathrooms: 1,
      livingRoomSize: 'large',
    ),
  );

  await tester.pumpWidget(
    MaterialApp(
      home: CleaningOrderRescheduleScreen(
        args: CleaningOrderRescheduleArgs(order: order ?? fallbackOrder),
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ar');
    await initializeDateFormatting('en');
  });

  tearDown(() async {
    if (getIt.isRegistered<ClMainBloc>()) {
      await getIt.unregister<ClMainBloc>();
    }
    if (getIt.isRegistered<CreateCleaningOrderUseCase>()) {
      await getIt.unregister<CreateCleaningOrderUseCase>();
    }
    if (getIt.isRegistered<CancelCleaningOrderUseCase>()) {
      await getIt.unregister<CancelCleaningOrderUseCase>();
    }
  });

  testWidgets('shows loading indicator while estimate is pending', (
    WidgetTester tester,
  ) async {
    final completer = Completer<Either<Failure, EstimatePriceResponseModel>>();
    final useCase = EstimateCleaningPriceUseCase(
      clMainRepo: _FakeClMainRepo(estimateHandler: (_) => completer.future),
    );

    await _pumpScreen(tester, useCase);

    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('shows summary card on estimate success', (
    WidgetTester tester,
  ) async {
    final useCase = EstimateCleaningPriceUseCase(
      clMainRepo: _FakeClMainRepo(
        estimateHandler: (_) async => const Right(
          EstimatePriceResponseModel(
            pricing: EstimatePricingModel(
              basePrice: 1000,
              travelFee: 200,
              addonsTotal: 0,
              totalPrice: 1200,
              currency: 'SYP',
            ),
          ),
        ),
      ),
    );

    await _pumpScreen(tester, useCase);
    await tester.pumpAndSettle();

    expect(find.textContaining('1,200'), findsWidgets);
  });

  testWidgets('hides loading and summary on estimate failure', (
    WidgetTester tester,
  ) async {
    final useCase = EstimateCleaningPriceUseCase(
      clMainRepo: _FakeClMainRepo(
        estimateHandler: (_) async =>
            const Left(ServerFailure(message: 'estimate failed')),
      ),
    );

    await _pumpScreen(tester, useCase);
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.textContaining('1,200'), findsNothing);
  });

  testWidgets('uses order gender preference as initial selection', (
    WidgetTester tester,
  ) async {
    final useCase = EstimateCleaningPriceUseCase(
      clMainRepo: _FakeClMainRepo(
        estimateHandler: (_) async => const Right(EstimatePriceResponseModel()),
      ),
    );

    final order = CleaningOrderModel(
      id: 9,
      propertyType: 'villa',
      scheduledDate: _dateOnly(DateTime.now().add(const Duration(days: 3))),
      scheduledTime: '11:00',
      genderPreference: CleaningGenderPreference.male,
      addressLatitude: 33.6,
      addressLongitude: 36.4,
      propertyDetails: CleaningPropertyDetailsModel(
        address: 'Test Address',
        bedrooms: 2,
        rooms: 3,
        bathrooms: 1,
        livingRoomSize: 'large',
      ),
    );

    await _pumpScreen(tester, useCase, order: order);
    await tester.pumpAndSettle();

    final maleChip = tester.widget<ChoiceChip>(
      find.byKey(const Key('cleaning_gender_pref_male')),
    );
    final anyChip = tester.widget<ChoiceChip>(
      find.byKey(const Key('cleaning_gender_pref_any')),
    );
    expect(maleChip.selected, isTrue);
    expect(anyChip.selected, isFalse);
  });

  testWidgets('falls back to any as initial gender selection', (
    WidgetTester tester,
  ) async {
    final useCase = EstimateCleaningPriceUseCase(
      clMainRepo: _FakeClMainRepo(
        estimateHandler: (_) async => const Right(EstimatePriceResponseModel()),
      ),
    );

    await _pumpScreen(tester, useCase);
    await tester.pumpAndSettle();

    final anyChip = tester.widget<ChoiceChip>(
      find.byKey(const Key('cleaning_gender_pref_any')),
    );
    expect(anyChip.selected, isTrue);
  });

  testWidgets('save flow sends selected gender preference in create request', (
    WidgetTester tester,
  ) async {
    CreateCleaningOrderParams? sentCreateParams;
    final useCase = EstimateCleaningPriceUseCase(
      clMainRepo: _FakeClMainRepo(
        estimateHandler: (_) async => const Right(
          EstimatePriceResponseModel(
            pricing: EstimatePricingModel(
              basePrice: 1000,
              travelFee: 200,
              addonsTotal: 0,
              totalPrice: 1200,
            ),
          ),
        ),
        createOrderHandler: (params) async {
          sentCreateParams = params;
          return const Right(
            CreateCleaningOrderResponseModel(success: true, orderId: 90),
          );
        },
      ),
    );

    await _pumpScreen(tester, useCase);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('cleaning_gender_pref_female')));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pumpAndSettle();

    expect(sentCreateParams, isNotNull);
    expect(sentCreateParams!.genderPreference, CleaningGenderPreference.female);
  });
}
