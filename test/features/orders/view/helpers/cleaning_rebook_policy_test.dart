import 'package:common_package/helpers/error_handler.dart';
import 'package:dartz/dartz.dart';
import 'package:dllni_user_app/core/models/cleaning_gender_preference.dart';
import 'package:dllni_user_app/features/cl_main/data/models/create_cleaning_order_response_model.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/create_cleaning_order_use_case.dart';
import 'package:dllni_user_app/features/orders/data/models/cleaning_order_cancel_api_models.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/cancel_cleaning_order_use_case.dart';
import 'package:dllni_user_app/features/orders/view/helpers/cleaning_rebook_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CleaningRebookPolicy lead-time', () {
    test('blocks when remaining time is less than 24 hours', () {
      final check = CleaningRebookPolicy.evaluateLeadTime(
        scheduledDate: '2026-05-20',
        scheduledTime: '09:00',
        now: DateTime(2026, 5, 19, 12, 30),
      );

      expect(check.allowed, isFalse);
      expect(check.remaining, isNotNull);
      expect(check.remaining!.inHours, lessThan(24));
    });

    test('allows when remaining time is at least 24 hours', () {
      final check = CleaningRebookPolicy.evaluateLeadTime(
        scheduledDate: '2026-05-20',
        scheduledTime: '12:00',
        now: DateTime(2026, 5, 19, 12, 0),
      );

      expect(check.allowed, isTrue);
    });
  });

  group('CleaningRebookPolicy execute', () {
    test('runs cancel then create and returns new order id', () async {
      bool createCalled = false;
      CancelCleaningOrderParams? cancelParams;
      CreateCleaningOrderParams? createParams;

      final policy = CleaningRebookPolicy(
        cancelOrder: (params) async {
          cancelParams = params;
          return Right(CleaningCancelResultModel(message: 'cancelled'));
        },
        createOrder: (params) async {
          createCalled = true;
          createParams = params;
          return const Right(
            CreateCleaningOrderResponseModel(success: true, orderId: 88),
          );
        },
      );

      final result = await policy.execute(
        request: const CleaningRebookRequest(
          existingOrderId: 12,
          propertyType: 'apartment',
          bedrooms: 2,
          rooms: 3,
          bathrooms: 1,
          livingRoomSize: 'medium',
          address: 'Address',
          locationName: 'Home',
          scheduledDate: '2026-05-25',
          scheduledTime: '10:00',
          addressLatitude: 33.5,
          addressLongitude: 36.3,
          genderPreference: CleaningGenderPreference.female,
          preferredWorkerId: 7,
        ),
      );

      expect(createCalled, isTrue);
      expect(cancelParams, isNotNull);
      expect(createParams, isNotNull);
      expect(cancelParams!.reason, CleaningRebookPolicy.cancelReason);
      expect(createParams!.genderPreference, CleaningGenderPreference.female);
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected success'),
        (value) => expect(value.newOrderId, 88),
      );
    });

    test('stops when cancel fails', () async {
      bool createCalled = false;

      final policy = CleaningRebookPolicy(
        cancelOrder: (_) async =>
            const Left(ServerFailure(message: 'cancel failed')),
        createOrder: (_) async {
          createCalled = true;
          return const Right(
            CreateCleaningOrderResponseModel(success: true, orderId: 100),
          );
        },
      );

      final result = await policy.execute(
        request: const CleaningRebookRequest(
          existingOrderId: 12,
          propertyType: 'apartment',
          bedrooms: 2,
          rooms: 3,
          bathrooms: 1,
          livingRoomSize: 'medium',
          address: 'Address',
          locationName: 'Home',
          scheduledDate: '2026-05-25',
          scheduledTime: '10:00',
          addressLatitude: 33.5,
          addressLongitude: 36.3,
        ),
      );

      expect(result.isLeft(), isTrue);
      expect(createCalled, isFalse);
    });
  });
}
