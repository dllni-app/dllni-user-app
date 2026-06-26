import 'package:common_package/helpers/error_handler.dart';
import 'package:common_package/helpers/typedef.dart';
import 'package:dartz/dartz.dart';
import 'package:dllni_user_app/core/models/cleaning_gender_preference.dart';
import 'package:dllni_user_app/features/cl_main/data/models/create_cleaning_order_response_model.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/create_cleaning_order_use_case.dart';
import 'package:dllni_user_app/features/orders/data/models/cleaning_order_cancel_api_models.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/cancel_cleaning_order_use_case.dart';

class CleaningRebookRequest {
  const CleaningRebookRequest({
    required this.existingOrderId,
    required this.propertyType,
    required this.bedrooms,
    required this.rooms,
    required this.bathrooms,
    required this.livingRoomSize,
    required this.address,
    required this.locationName,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.addressLatitude,
    required this.addressLongitude,
    this.genderPreference = CleaningGenderPreference.any,
    this.preferredWorkerId,
    this.termsAccepted = true,
  });

  final int existingOrderId;
  final String propertyType;
  final int bedrooms;
  final int rooms;
  final int bathrooms;
  final String livingRoomSize;
  final String address;
  final String locationName;
  final String scheduledDate;
  final String scheduledTime;
  final double addressLatitude;
  final double addressLongitude;
  final CleaningGenderPreference genderPreference;
  final int? preferredWorkerId;
  final bool termsAccepted;
}

class CleaningRebookOutcome {
  const CleaningRebookOutcome({
    required this.newOrderId,
    this.cancelMessage,
    this.createMessage,
  });

  final int? newOrderId;
  final String? cancelMessage;
  final String? createMessage;
}

class CleaningRebookGuardResult {
  const CleaningRebookGuardResult({
    required this.allowed,
    this.scheduledAt,
    this.remaining,
  });

  final bool allowed;
  final DateTime? scheduledAt;
  final Duration? remaining;
}

class CleaningRebookPolicy {
  CleaningRebookPolicy({required this.cancelOrder, required this.createOrder});

  static const String cancelReason = 'قام المستخدم بتعديل بيانات الطلب';
  static const Duration minimumLeadTime = Duration(hours: 24);

  final DataResponse<CleaningCancelResultModel> Function(
    CancelCleaningOrderParams params,
  )
  cancelOrder;
  final DataResponse<CreateCleaningOrderResponseModel> Function(
    CreateCleaningOrderParams params,
  )
  createOrder;

  static DateTime? parseScheduledAt({
    required String? scheduledDate,
    required String? scheduledTime,
  }) {
    if (scheduledDate == null || scheduledDate.trim().isEmpty) return null;
    if (scheduledTime == null || scheduledTime.trim().isEmpty) return null;
    final raw =
        '${scheduledDate.trim()} ${scheduledTime.trim().split('.').first}';
    return DateTime.tryParse(raw);
  }

  static CleaningRebookGuardResult evaluateLeadTime({
    required String? scheduledDate,
    required String? scheduledTime,
    DateTime? now,
  }) {
    final scheduledAt = parseScheduledAt(
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
    );
    if (scheduledAt == null) {
      return const CleaningRebookGuardResult(allowed: false);
    }
    final current = now ?? DateTime.now();
    final remaining = scheduledAt.difference(current);
    if (remaining < minimumLeadTime) {
      return CleaningRebookGuardResult(
        allowed: false,
        scheduledAt: scheduledAt,
        remaining: remaining,
      );
    }
    return CleaningRebookGuardResult(
      allowed: true,
      scheduledAt: scheduledAt,
      remaining: remaining,
    );
  }

  Future<Either<Failure, CleaningRebookOutcome>> execute({
    required CleaningRebookRequest request,
    String cancelReasonMessage = cancelReason,
  }) async {
    final cancelResult = await cancelOrder(
      CancelCleaningOrderParams(
        cleaningOrderId: request.existingOrderId,
        reason: cancelReasonMessage,
      ),
    );
    return cancelResult.fold((failure) async => Left(failure), (
      cancelResponse,
    ) async {
      final createResult = await createOrder(
        CreateCleaningOrderParams(
          addressId: int.tryParse(request.address) ?? 0,
          propertyType: request.propertyType,
          bedrooms: request.bedrooms,
          rooms: request.rooms,
          bathrooms: request.bathrooms,
          livingRoomSize: request.livingRoomSize,
          address: request.address,
          locationName: request.locationName,
          scheduledDate: request.scheduledDate,
          scheduledTime: request.scheduledTime,
          addressLatitude: request.addressLatitude,
          addressLongitude: request.addressLongitude,
          genderPreference: request.genderPreference,
          preferredWorkerId: request.preferredWorkerId,
          termsAccepted: request.termsAccepted,
        ),
      );
      return createResult.fold(
        (failure) => Left(failure),
        (createResponse) => Right(
          CleaningRebookOutcome(
            newOrderId: createResponse.orderId,
            cancelMessage: cancelResponse.message,
            createMessage: createResponse.message,
          ),
        ),
      );
    });
  }
}
