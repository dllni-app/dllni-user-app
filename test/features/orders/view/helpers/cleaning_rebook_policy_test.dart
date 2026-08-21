import 'package:common_package/helpers/error_handler.dart';
import 'package:dartz/dartz.dart';
import 'package:dllni_user_app/core/models/cleaning_gender_preference.dart';
import 'package:dllni_user_app/features/cl_main/data/models/create_cleaning_order_response_model.dart';
import 'package:dllni_user_app/features/orders/data/models/cleaning_order_cancel_api_models.dart';
import 'package:dllni_user_app/features/orders/data/models/cleaning_orders_api_models.dart';
import 'package:dllni_user_app/features/orders/data/models/orders_api_models.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/patch_cleaning_order_use_case.dart';
import 'package:dllni_user_app/features/orders/view/helpers/cleaning_rebook_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CleaningRebookPolicy lead-time', () {
    test('locks when remaining time is less than 24 hours', () {
      final check = CleaningRebookPolicy.evaluateLeadTime(
        scheduledDate: '2026-05-20',
        scheduledTime: '09:00',
        now: DateTime(2026, 5, 19, 10),
      );

      expect(check.allowed, isFalse);
      expect(check.visibility, CleaningRebookEditVisibility.locked);
    });

    test('hides when current time is after scheduled service time', () {
      final check = CleaningRebookPolicy.evaluateLeadTime(
        scheduledDate: '2026-05-20',
        scheduledTime: '09:00',
        now: DateTime(2026, 5, 20, 9, 1),
      );

      expect(check.allowed, isFalse);
      expect(check.visibility, CleaningRebookEditVisibility.hidden);
    });

    test('allows when remaining time is at least 24 hours', () {
      final check = CleaningRebookPolicy.evaluateLeadTime(
        scheduledDate: '2026-05-21',
        scheduledTime: '09:00',
        now: DateTime(2026, 5, 20, 9),
      );

      expect(check.allowed, isTrue);
      expect(check.visibility, CleaningRebookEditVisibility.editable);
    });
  });

  group('CleaningRebookPolicy in-place PATCH', () {
    CleaningOrderDetailModel currentOrder({int acceptedWorkers = 0}) {
      return CleaningOrderDetailModel.fromJson({
        'id': 12,
        'status': 'pending',
        'propertyType': 'apartment',
        'propertyDetails': {
          'address': 'Old address',
          'bedrooms': 2,
          'rooms': 3,
          'bathrooms': 1,
          'living_room_size': 'medium',
        },
        'locationName': 'Home',
        'scheduledDate': '2026-05-25',
        'scheduledTime': '10:00:00',
        'addressLatitude': 33.5,
        'addressLongitude': 36.3,
        'genderPreference': 'any',
        'workerAcceptance': {
          'required': 1,
          'accepted': acceptedWorkers,
          'remaining': acceptedWorkers > 0 ? 0 : 1,
          'isFulfilled': acceptedWorkers > 0,
        },
      });
    }

    CleaningRebookRequest request({
      String scheduledDate = '2026-05-25',
      String scheduledTime = '10:00',
      String address = 'Old address',
      String locationName = 'Home',
      double latitude = 33.5,
      double longitude = 36.3,
      CleaningGenderPreference genderPreference = CleaningGenderPreference.any,
    }) {
      return CleaningRebookRequest(
        existingOrderId: 12,
        propertyType: 'apartment',
        bedrooms: 2,
        rooms: 3,
        bathrooms: 1,
        livingRoomSize: 'medium',
        address: address,
        locationName: locationName,
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
        addressLatitude: latitude,
        addressLongitude: longitude,
        genderPreference: genderPreference,
      );
    }

    CleaningRebookPolicy policy({
      required CleaningOrderDetailModel current,
      required Future<Either<Failure, OrdersActionResultModel>> Function(
        PatchCleaningOrderParams params,
      )
      patch,
    }) {
      return CleaningRebookPolicy(
        cancelOrder: (_) async =>
            const Right(CleaningCancelResultModel(message: 'unused')),
        createOrder: (_) async => const Right(
          CreateCleaningOrderResponseModel(success: true, orderId: 999),
        ),
        fetchOrderDetails: (_) async =>
            Right(FetchCleaningOrderDetailsModel(data: current)),
        patchOrder: patch,
      );
    }

    test('schedule edit PATCHes only changed schedule fields', () async {
      PatchCleaningOrderParams? sent;
      final result = await policy(
        current: currentOrder(),
        patch: (params) async {
          sent = params;
          return Right(OrdersActionResultModel(message: 'updated'));
        },
      ).execute(
        request: request(
          scheduledDate: '2026-05-26',
          scheduledTime: '11:30',
        ),
      );

      expect(result.isRight(), isTrue);
      expect(sent!.cleaningOrderId, 12);
      expect(sent!.getBody(), {
        'scheduledDate': '2026-05-26',
        'scheduledTime': '11:30',
      });
      result.fold(
        (_) => fail('expected success'),
        (value) => expect(value.newOrderId, 12),
      );
    });

    test('address edit sends only address and coordinates', () async {
      PatchCleaningOrderParams? sent;
      await policy(
        current: currentOrder(),
        patch: (params) async {
          sent = params;
          return Right(OrdersActionResultModel(message: 'updated'));
        },
      ).execute(
        request: request(
          address: 'New address',
          locationName: 'Office',
          latitude: 36.2,
          longitude: 37.1,
        ),
      );

      expect(sent!.getBody(), {
        'propertyDetails': {
          'address': 'New address',
          'location_name': 'Office',
        },
        'addressLatitude': 36.2,
        'addressLongitude': 37.1,
      });
    });

    test('schedule edit remains allowed after a worker accepts', () async {
      PatchCleaningOrderParams? sent;
      final result = await policy(
        current: currentOrder(acceptedWorkers: 1),
        patch: (params) async {
          sent = params;
          return Right(OrdersActionResultModel(message: 'updated'));
        },
      ).execute(request: request(scheduledTime: '12:00'));

      expect(result.isRight(), isTrue);
      expect(sent!.getBody(), {'scheduledTime': '12:00'});
    });

    test('rejects protected configuration edit after worker acceptance', () async {
      bool patchCalled = false;
      final result = await policy(
        current: currentOrder(acceptedWorkers: 1),
        patch: (_) async {
          patchCalled = true;
          return Right(OrdersActionResultModel(message: 'updated'));
        },
      ).execute(request: request(address: 'New address'));

      expect(result.isLeft(), isTrue);
      expect(patchCalled, isFalse);
    });

    test('does not call PATCH when nothing changed', () async {
      bool patchCalled = false;
      final result = await policy(
        current: currentOrder(),
        patch: (_) async {
          patchCalled = true;
          return Right(OrdersActionResultModel(message: 'updated'));
        },
      ).execute(request: request());

      expect(result.isRight(), isTrue);
      expect(patchCalled, isFalse);
    });
  });
}
