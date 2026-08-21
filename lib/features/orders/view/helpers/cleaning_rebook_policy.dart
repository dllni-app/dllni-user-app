import 'package:common_package/helpers/error_handler.dart';
import 'package:common_package/helpers/typedef.dart';
import 'package:dartz/dartz.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/models/cleaning_gender_preference.dart';
import 'package:dllni_user_app/features/cl_main/data/models/create_cleaning_order_response_model.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/create_cleaning_order_use_case.dart';
import 'package:dllni_user_app/features/orders/data/models/cleaning_order_cancel_api_models.dart';
import 'package:dllni_user_app/features/orders/data/models/cleaning_orders_api_models.dart';
import 'package:dllni_user_app/features/orders/data/models/orders_api_models.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/cancel_cleaning_order_use_case.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/fetch_cleaning_order_details_use_case.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/patch_cleaning_order_use_case.dart';

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

  /// Kept for backward compatibility with the existing navigation flow.
  /// Editing now patches the same booking, so this is the existing order id.
  final int? newOrderId;
  final String? cancelMessage;
  final String? createMessage;
}

enum CleaningRebookEditVisibility {
  /// More than [CleaningRebookPolicy.minimumLeadTime] remaining — edits allowed.
  editable,

  /// Less than 24 hours remaining, but scheduled time has not passed — show
  /// controls disabled.
  locked,

  /// Current time is at or after the scheduled service time — hide edit
  /// controls.
  hidden,
}

class CleaningRebookGuardResult {
  const CleaningRebookGuardResult({
    required this.allowed,
    required this.visibility,
    this.scheduledAt,
    this.remaining,
  });

  final bool allowed;
  final CleaningRebookEditVisibility visibility;
  final DateTime? scheduledAt;
  final Duration? remaining;

  bool get isPastScheduledTime =>
      visibility == CleaningRebookEditVisibility.hidden;

  bool get isLeadTimeLocked =>
      visibility == CleaningRebookEditVisibility.locked;
}

class CleaningRebookPolicy {
  CleaningRebookPolicy({
    required this.cancelOrder,
    required this.createOrder,
    DataResponse<FetchCleaningOrderDetailsModel> Function(
      FetchCleaningOrderDetailsParams params,
    )?
    fetchOrderDetails,
    DataResponse<OrdersActionResultModel> Function(PatchCleaningOrderParams params)?
    patchOrder,
  }) : fetchOrderDetails =
           fetchOrderDetails ??
           ((params) => getIt<FetchCleaningOrderDetailsUseCase>()(params)),
       patchOrder =
           patchOrder ?? ((params) => getIt<PatchCleaningOrderUseCase>()(params));

  /// Legacy callbacks are kept in the constructor so existing call sites stay
  /// source-compatible. They are intentionally no longer used for editing.
  /// Cleaning booking edits are now in-place PATCH requests.
  final DataResponse<CleaningCancelResultModel> Function(
    CancelCleaningOrderParams params,
  )
  cancelOrder;
  final DataResponse<CreateCleaningOrderResponseModel> Function(
    CreateCleaningOrderParams params,
  )
  createOrder;

  final DataResponse<FetchCleaningOrderDetailsModel> Function(
    FetchCleaningOrderDetailsParams params,
  )
  fetchOrderDetails;
  final DataResponse<OrdersActionResultModel> Function(
    PatchCleaningOrderParams params,
  )
  patchOrder;

  // Kept for compatibility with older tests/callers that reference the value.
  static const String cancelReason = 'قام المستخدم بتعديل بيانات الطلب';
  static const Duration minimumLeadTime = Duration(hours: 24);

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
      return const CleaningRebookGuardResult(
        allowed: false,
        visibility: CleaningRebookEditVisibility.hidden,
      );
    }
    final current = now ?? DateTime.now();
    final remaining = scheduledAt.difference(current);
    if (remaining <= Duration.zero) {
      return CleaningRebookGuardResult(
        allowed: false,
        visibility: CleaningRebookEditVisibility.hidden,
        scheduledAt: scheduledAt,
        remaining: remaining,
      );
    }
    if (remaining < minimumLeadTime) {
      return CleaningRebookGuardResult(
        allowed: false,
        visibility: CleaningRebookEditVisibility.locked,
        scheduledAt: scheduledAt,
        remaining: remaining,
      );
    }
    return CleaningRebookGuardResult(
      allowed: true,
      visibility: CleaningRebookEditVisibility.editable,
      scheduledAt: scheduledAt,
      remaining: remaining,
    );
  }

  /// Updates the existing cleaning booking in place.
  ///
  /// The current booking is fetched immediately before save so the request can
  /// contain only changed fields and react correctly if a worker accepted while
  /// the edit screen was open.
  Future<Either<Failure, CleaningRebookOutcome>> execute({
    required CleaningRebookRequest request,
    String cancelReasonMessage = cancelReason,
  }) async {
    final detailsResult = await fetchOrderDetails(
      FetchCleaningOrderDetailsParams(orderId: request.existingOrderId),
    );

    return detailsResult.fold((failure) async => Left(failure), (details) async {
      final current = details.data;
      if (current == null) {
        return const Left(
          ServerFailure(message: 'تعذر تحميل بيانات الطلب الحالية.'),
        );
      }

      if (!current.canEdit) {
        return const Left(
          ServerFailure(message: 'لا يمكن تعديل الطلب في حالته الحالية.'),
        );
      }

      final changes = <String, dynamic>{};
      final propertyChanges = <String, dynamic>{};

      if ((current.scheduledDate ?? '') != request.scheduledDate) {
        changes['scheduledDate'] = request.scheduledDate;
      }
      if (_normalizeTime(current.scheduledTime) !=
          _normalizeTime(request.scheduledTime)) {
        changes['scheduledTime'] = request.scheduledTime;
      }

      final currentAddress = current.propertyDetails?.address ?? '';
      if (currentAddress != request.address) {
        propertyChanges['address'] = request.address;
      }
      if ((current.locationName ?? '') != request.locationName) {
        propertyChanges['location_name'] = request.locationName;
      }

      if (!_sameCoordinate(current.addressLatitude, request.addressLatitude)) {
        changes['addressLatitude'] = request.addressLatitude;
      }
      if (!_sameCoordinate(current.addressLongitude, request.addressLongitude)) {
        changes['addressLongitude'] = request.addressLongitude;
      }

      final genderChanged = current.genderPreference != request.genderPreference;
      final addressChanged =
          propertyChanges.isNotEmpty ||
          changes.containsKey('addressLatitude') ||
          changes.containsKey('addressLongitude');
      final hasAcceptedWorkers =
          current.acceptedWorkersCount > 0 ||
          (current.workerAcceptance?.accepted ?? 0) > 0 ||
          current.acceptedWorkerAssignments.isNotEmpty;

      if (hasAcceptedWorkers && addressChanged) {
        return const Left(
          ServerFailure(
            message: 'لا يمكن تغيير عنوان الخدمة بعد قبول مقدم الخدمة.',
          ),
        );
      }
      if (hasAcceptedWorkers && genderChanged) {
        return const Left(
          ServerFailure(
            message: 'لا يمكن تغيير تفضيل مقدم الخدمة بعد قبول مقدم الخدمة.',
          ),
        );
      }

      if (propertyChanges.isNotEmpty) {
        changes['propertyDetails'] = propertyChanges;
      }
      if (genderChanged) {
        changes['genderPreference'] = request.genderPreference.apiValue;
      }

      if (changes.isEmpty) {
        return Right(
          CleaningRebookOutcome(
            newOrderId: request.existingOrderId,
            createMessage: 'لا توجد تغييرات للحفظ.',
          ),
        );
      }

      final patchResult = await patchOrder(
        PatchCleaningOrderParams(
          cleaningOrderId: request.existingOrderId,
          changes: changes,
        ),
      );

      return patchResult.fold(
        (failure) => Left(failure),
        (response) => Right(
          CleaningRebookOutcome(
            newOrderId: request.existingOrderId,
            createMessage: response.message ?? 'تم تحديث الطلب بنجاح.',
          ),
        ),
      );
    });
  }

  static String _normalizeTime(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return '';
    final parts = text.split(':');
    if (parts.length < 2) return text;
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  static bool _sameCoordinate(double? current, double next) {
    if (current == null) return false;
    return (current - next).abs() < 0.0000001;
  }
}
