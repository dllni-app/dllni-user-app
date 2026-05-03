import 'dart:async';

import 'package:common_package/helpers/error_handler.dart';
import 'package:common_package/helpers/typedef.dart';
import 'package:dartz/dartz.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/features/cl_main/data/models/create_cleaning_order_response_model.dart';
import 'package:dllni_user_app/features/cl_main/data/models/estimate_price_response_model.dart';
import 'package:dllni_user_app/features/cl_main/data/models/previous_workers_response_model.dart';
import 'package:dllni_user_app/features/cl_main/domain/repository/cl_main_repo.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/create_cleaning_order_use_case.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/estimate_cleaning_price_use_case.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/get_previous_cleaning_workers_use_case.dart';
import 'package:dllni_user_app/features/cl_main/view/manager/bloc/cl_main_bloc.dart';
import 'package:dllni_user_app/features/orders/data/models/cleaning_orders_api_models.dart';
import 'package:dllni_user_app/features/orders/view/screens/cleaning_order_reschedule_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

class _FakeClMainRepo implements ClMainRepo {
  _FakeClMainRepo(this._estimateHandler);

  final DataResponse<EstimatePriceResponseModel> Function(
    EstimateCleaningPriceParams params,
  ) _estimateHandler;

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
    throw UnimplementedError();
  }

  @override
  DataResponse<PreviousWorkersResponseModel> getPreviousCleaningWorkers(
    GetPreviousCleaningWorkersParams params,
  ) {
    throw UnimplementedError();
  }
}

Future<void> _pumpScreen(
  WidgetTester tester,
  EstimateCleaningPriceUseCase useCase,
) async {
  if (getIt.isRegistered<ClMainBloc>()) {
    await getIt.unregister<ClMainBloc>();
  }
  final createUseCase = CreateCleaningOrderUseCase(clMainRepo: useCase.clMainRepo);
  final workersUseCase = GetPreviousCleaningWorkersUseCase(clMainRepo: useCase.clMainRepo);
  getIt.registerFactory<ClMainBloc>(
    () => ClMainBloc(
      estimateCleaningPriceUseCase: useCase,
      getPreviousCleaningWorkersUseCase: workersUseCase,
      createCleaningOrderUseCase: createUseCase,
    ),
  );

  final order = CleaningOrderModel(
    id: 7,
    propertyType: 'villa',
    scheduledDate: '2026-04-11',
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
        args: CleaningOrderRescheduleArgs(order: order),
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
  });

  testWidgets('shows loading indicator while estimate is pending', (
    WidgetTester tester,
  ) async {
    final completer = Completer<Either<Failure, EstimatePriceResponseModel>>();
    final useCase = EstimateCleaningPriceUseCase(
      clMainRepo: _FakeClMainRepo((_) => completer.future),
    );

    await _pumpScreen(tester, useCase);

    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('shows summary card on estimate success', (
    WidgetTester tester,
  ) async {
    final useCase = EstimateCleaningPriceUseCase(
      clMainRepo: _FakeClMainRepo(
        (_) async => const Right(
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

    expect(find.text('ملخص الطلب'), findsOneWidget);
    expect(find.textContaining('1,200'), findsWidgets);
  });

  testWidgets('hides loading and summary on estimate failure', (
    WidgetTester tester,
  ) async {
    final useCase = EstimateCleaningPriceUseCase(
      clMainRepo: _FakeClMainRepo(
        (_) async => const Left(
          ServerFailure(message: 'estimate failed'),
        ),
      ),
    );

    await _pumpScreen(tester, useCase);
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.textContaining('1,200'), findsNothing);
  });
}
