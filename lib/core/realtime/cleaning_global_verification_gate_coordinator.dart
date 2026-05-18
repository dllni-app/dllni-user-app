import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';

import '../../features/orders/data/models/cleaning_booking_status.dart';
import '../../features/orders/data/models/cleaning_orders_api_models.dart';
import '../../features/orders/domain/usecases/confirm_cleaning_completion_use_case.dart';
import '../../features/orders/domain/usecases/confirm_cleaning_start_verification_use_case.dart';
import '../../features/orders/domain/usecases/extend_cleaning_completion_time_use_case.dart';
import '../../features/orders/domain/usecases/fetch_cleaning_order_details_use_case.dart';
import '../../features/orders/domain/usecases/fetch_cleaning_orders_use_case.dart';
import '../../features/orders/domain/usecases/fetch_cleaning_worker_profile_use_case.dart';
import '../../features/orders/domain/usecases/reject_cleaning_completion_use_case.dart';
import '../../features/orders/view/helpers/cleaning_lifecycle_error_mapper.dart';
import '../../features/orders/view/helpers/cleaning_worker_rating_gate.dart';
import '../../features/orders/view/screens/cleaning_order_details_screen.dart';
import '../../features/orders/view/screens/cleaning_worker_rating_screen.dart';
import '../../features/orders/view/widgets/cleaning_completion_decision_sheet.dart';
import '../../features/orders/view/widgets/cleaning_start_verification_dialog.dart';
import '../di/injection.dart';
import 'cleaning_booking_pusher_service.dart';
import 'cleaning_gate_session_store.dart';
import 'cleaning_realtime_contract.dart';
import 'pusher_manager.dart';

class CleaningGlobalVerificationGateCoordinator {
  CleaningGlobalVerificationGateCoordinator({
    required GlobalKey<NavigatorState> navigatorKey,
  }) : _navigatorKey = navigatorKey;

  final GlobalKey<NavigatorState> _navigatorKey;
  final CleaningBookingPusherService _pusher =
      getIt<CleaningBookingPusherService>();
  final CleaningGateSessionStore _gateSession =
      CleaningGateSessionStore.instance;

  Timer? _pollTimer;
  bool _started = false;
  bool _gatePromptOpen = false;
  bool _refreshing = false;
  int? _listeningCustomerId;
  bool _customerChannelAuthWarningShown = false;

  static const int _pollPageSize = 25;
  static const int _pollMaxPagesPerStatus = 6;

  /// Orders that need the customer verification dialog.
  static List<int> findAwaitingVerificationOrderIds(
    List<CleaningOrderModel> orders,
  ) {
    return orders
        .where(
          (order) =>
              (order.status ?? '').toLowerCase() ==
              CleaningBookingStatus.awaitingStartVerification,
        )
        .map((order) => order.id)
        .whereType<int>()
        .toList(growable: false);
  }

  /// Orders that need the customer completion decision sheet.
  static List<int> findAwaitingCompletionOrderIds(
    List<CleaningOrderModel> orders,
  ) {
    return orders
        .where(
          (order) =>
              (order.status ?? '').toLowerCase() ==
              CleaningBookingStatus.awaitingCustomerCompletion,
        )
        .map((order) => order.id)
        .whereType<int>()
        .toList(growable: false);
  }

  Future<void> start() async {
    if (_started) return;
    _started = true;
    await _pusher.ensureInitialized();
    await _ensureCustomerRealtimeChannel();
    unawaited(_refreshPendingGates());
    _pollTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      unawaited(_ensureCustomerRealtimeChannel());
      unawaited(_refreshPendingGates());
    });
  }

  Future<void> stop() async {
    _pollTimer?.cancel();
    _pollTimer = null;
    _gatePromptOpen = false;
    if (_listeningCustomerId != null) {
      _pusher.setCustomerHandler(_listeningCustomerId!, null);
      _pusher.setCustomerErrorHandler(_listeningCustomerId!, null);
      await _pusher.unsubscribeCustomerChannel(_listeningCustomerId!);
      _listeningCustomerId = null;
    }
    _started = false;
  }

  Future<void> _ensureCustomerRealtimeChannel() async {
    if (!_hasToken()) {
      if (_listeningCustomerId != null) {
        final oldId = _listeningCustomerId!;
        _pusher.setCustomerHandler(oldId, null);
        _pusher.setCustomerErrorHandler(oldId, null);
        await _pusher.unsubscribeCustomerChannel(oldId);
        _listeningCustomerId = null;
      }
      _gateSession.reset();
      return;
    }

    final customerId = _readCustomerId();
    if (customerId == null || customerId <= 0) return;
    if (_listeningCustomerId == customerId) return;

    if (_listeningCustomerId != null) {
      final oldId = _listeningCustomerId!;
      _pusher.setCustomerHandler(oldId, null);
      _pusher.setCustomerErrorHandler(oldId, null);
      await _pusher.unsubscribeCustomerChannel(oldId);
    }

    _listeningCustomerId = customerId;
    _pusher.setCustomerHandler(customerId, _onRealtimeEvent);
    _pusher.setCustomerErrorHandler(customerId, _onRealtimeChannelError);
    await _pusher.subscribeCustomerChannel(customerId);
    _customerChannelAuthWarningShown = false;
  }

  void _onRealtimeEvent(String eventName, Map<String, dynamic> payload) {
    final normalizedEvent = CleaningRealtimeContract.normalizeEventName(
      eventName,
    );
    final bookingId = CleaningRealtimeContract.extractBookingId(payload);

    if (normalizedEvent == CleaningRealtimeContract.awaitingStartVerification) {
      if (bookingId != null) {
        // Treat explicit awaiting-start realtime events as a fresh
        // verification request for this booking, so refetched codes can
        // re-open even after temporary user dismissal.
        _gateSession.clearStartDismissed(bookingId);
        unawaited(
          _promptForStartVerificationGateIfNeeded(
            orderId: bookingId,
            force: true,
          ),
        );
      } else {
        unawaited(_refreshPendingGates());
      }
      return;
    }

    if (normalizedEvent ==
        CleaningRealtimeContract.awaitingCustomerCompletion) {
      if (bookingId != null) {
        // Re-request events should be able to reopen the completion sheet
        // even if an older cycle was temporarily dismissed.
        _gateSession.clearCompletionAwaitingCycle(bookingId);
        unawaited(
          _promptForCompletionGateIfNeeded(orderId: bookingId, force: true),
        );
      } else {
        unawaited(_refreshPendingGates());
      }
      return;
    }

    if (normalizedEvent == CleaningRealtimeContract.arrivalVerified &&
        bookingId != null) {
      _gateSession.clearStartDismissed(bookingId);
      unawaited(_refreshPendingGates());
      return;
    }

    if (normalizedEvent == CleaningRealtimeContract.trackingUpdated ||
        normalizedEvent == CleaningRealtimeContract.workerArrived ||
        normalizedEvent == CleaningRealtimeContract.completionDecisionMade ||
        normalizedEvent == CleaningRealtimeContract.serviceExtensionRequested) {
      unawaited(_refreshPendingGates());
    }
  }

  void _onRealtimeChannelError(RealtimeChannelError error) {
    if (error.statusCode != 403) return;
    if (_customerChannelAuthWarningShown) return;
    _customerChannelAuthWarningShown = true;
    final context = _navigatorKey.currentContext;
    if (context == null || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تعذر تفعيل التحديث المباشر حالياً. سنستمر بالمزامنة التلقائية في الخلفية.',
        ),
      ),
    );
  }

  Future<void> _refreshPendingGates() async {
    if (!_hasToken() || _refreshing) return;
    _refreshing = true;
    try {
      await _refreshPendingGatesForStatus(
        CleaningBookingStatus.awaitingStartVerification,
      );
      await _refreshPendingGatesForStatus(
        CleaningBookingStatus.awaitingCustomerCompletion,
      );
    } finally {
      _refreshing = false;
    }
  }

  Future<void> _refreshPendingGatesForStatus(String statusFilter) async {
    for (var page = 1; page <= _pollMaxPagesPerStatus; page++) {
      final Either<Failure, FetchCleaningOrdersModel> response =
          await getIt<FetchCleaningOrdersUseCase>()(
            FetchCleaningOrdersParams(
              status: statusFilter,
              page: page,
              perPage: _pollPageSize,
            ),
          );

      if (!_started) return;

      final orders = response.fold<List<CleaningOrderModel>>(
        (_) => const <CleaningOrderModel>[],
        (result) => result.data,
      );
      if (orders.isEmpty) break;

      for (final order in orders) {
        final orderId = order.id;
        if (orderId == null) continue;
        final status = (order.status ?? '').toLowerCase();
        _gateSession.syncWithStatus(
          bookingId: orderId,
          normalizedStatus: status,
        );
        if (status == CleaningBookingStatus.awaitingStartVerification) {
          unawaited(
            _promptForStartVerificationGateIfNeeded(
              orderId: orderId,
              previewOrder: order,
            ),
          );
        } else if (status == CleaningBookingStatus.awaitingCustomerCompletion) {
          unawaited(_promptForCompletionGateIfNeeded(orderId: orderId));
        }
      }

      if (orders.length < _pollPageSize) break;
    }
  }

  bool _isOrderDetailsScreenOpenFor(int orderId) {
    final navContext = _navigatorKey.currentContext;
    if (navContext == null) return false;
    final route = ModalRoute.of(navContext);
    final settings = route?.settings;
    if (settings?.name != '/cleaning-order-details') return false;
    final args = settings?.arguments;
    if (args is CleaningOrderDetailsArgs) {
      return args.orderId == orderId;
    }
    return false;
  }

  Future<void> _promptForStartVerificationGateIfNeeded({
    required int orderId,
    CleaningOrderModel? previewOrder,
    bool force = false,
  }) async {
    if (!_started || _gatePromptOpen) return;
    if (_isOrderDetailsScreenOpenFor(orderId)) return;
    if (_gateSession.isStartVerificationSuppressed(orderId, force: force)) {
      return;
    }
    if (previewOrder != null &&
        _isStartVerificationExpired(
          scheduledDate: previewOrder.scheduledDate,
          scheduledTime: previewOrder.scheduledTime,
          totalHours: previewOrder.totalHours,
          estimatedHours: previewOrder.estimatedHours,
        )) {
      _gateSession.suppressStartVerification(
        orderId,
        CleaningGateSuppressionReason.bookingTimeExpired,
      );
      return;
    }

    final details = await _fetchOrderDetails(orderId);
    if (!_started || _gatePromptOpen) return;
    if (_isOrderDetailsScreenOpenFor(orderId)) return;

    if (details == null) return;
    _syncGateSessionWithDetails(details);
    final status = (details.status ?? '').toLowerCase();
    if (status != CleaningBookingStatus.awaitingStartVerification) {
      return;
    }
    if (_isStartVerificationExpired(
      scheduledDate: details.scheduledDate,
      scheduledTime: details.scheduledTime,
      totalHours: details.totalHours,
      estimatedHours: details.estimatedHours,
    )) {
      _gateSession.suppressStartVerification(
        orderId,
        CleaningGateSuppressionReason.bookingTimeExpired,
      );
      return;
    }
    if (_gateSession.isStartVerificationSuppressed(orderId, force: force)) {
      return;
    }

    final navContext = _navigatorKey.currentContext;
    if (navContext == null || !navContext.mounted) return;
    if (_isOrderDetailsScreenOpenFor(orderId)) return;

    _gatePromptOpen = true;
    var confirmed = false;
    try {
      final scheduledAt = resolveCleaningBookingStartDateTime(
        scheduledDate: details.scheduledDate,
        scheduledTime: details.scheduledTime,
      );
      confirmed = await CleaningStartVerificationDialog.show(
        navContext,
        bookingId: details.id ?? orderId,
        bookingNumber: details.bookingNumber,
        dateTime: scheduledAt?.toIso8601String(),
        onSubmit: (code) =>
            _confirmStartVerificationCode(orderId: orderId, code: code),
      );
    } finally {
      _gatePromptOpen = false;
    }

    if (confirmed) {
      _gateSession.clearStartDismissed(orderId);
      unawaited(_refreshPendingGates());
      return;
    }
    _gateSession.suppressStartVerification(
      orderId,
      CleaningGateSuppressionReason.userDismissed,
    );
    // Keep scanning immediately so other awaiting bookings can prompt
    // without waiting for the periodic poll.
    unawaited(_refreshPendingGates());
  }

  Future<void> _promptForCompletionGateIfNeeded({
    required int orderId,
    bool force = false,
  }) async {
    if (!_started || _gatePromptOpen) return;
    if (_isOrderDetailsScreenOpenFor(orderId)) return;
    if (_gateSession.isCompletionSuppressed(orderId, force: force)) {
      return;
    }

    final details = await _fetchOrderDetails(orderId);
    if (!_started || _gatePromptOpen) return;
    if (_isOrderDetailsScreenOpenFor(orderId)) return;
    if (details == null) return;

    _syncGateSessionWithDetails(details);
    final status = (details.status ?? '').toLowerCase();
    if (status != CleaningBookingStatus.awaitingCustomerCompletion) {
      return;
    }
    if (_gateSession.isCompletionSuppressed(orderId, force: force)) {
      return;
    }

    final navContext = _navigatorKey.currentContext;
    if (navContext == null || !navContext.mounted) return;
    if (_isOrderDetailsScreenOpenFor(orderId)) return;

    _gatePromptOpen = true;
    CleaningCompletionDecision? decision;
    try {
      decision = await CleaningCompletionDecisionSheet.show(
        navContext,
        useRootNavigator: true,
        onConfirm: () => _submitCompletionConfirm(orderId: orderId),
        onReject: (reason) =>
            _submitCompletionReject(orderId: orderId, reason: reason),
        onExtend: (minutes) => _submitExtendCompletionTime(
          orderId: orderId,
          additionalMinutes: minutes,
        ),
      );
    } finally {
      _gatePromptOpen = false;
    }

    if (decision == null) {
      _gateSession.suppressCompletion(
        orderId,
        CleaningGateSuppressionReason.userDismissed,
        currentAwaitingCycleOnly: true,
      );
      // Keep scanning immediately so other awaiting bookings can prompt
      // without waiting for the periodic poll.
      unawaited(_refreshPendingGates());
      return;
    }
    _gateSession.clearCompletionAwaitingCycle(orderId);

    if (decision == CleaningCompletionDecision.confirmed &&
        navContext.mounted &&
        details.id != null) {
      final workerProfile = await resolveCleaningWorkerProfileForRating(
        workerId: details.worker?.id,
        fetchWorkerProfile: (params) =>
            getIt<FetchCleaningWorkerProfileUseCase>()(params),
        onError: (message) {
          if (!navContext.mounted) return;
          ScaffoldMessenger.of(
            navContext,
          ).showSnackBar(SnackBar(content: Text(message)));
        },
      );
      if (workerProfile != null && navContext.mounted) {
        final ratingArgs = CleaningWorkerRatingArgs(
          orderId: details.id!,
          workerProfile: workerProfile,
        );
        Navigator.of(
          navContext,
          rootNavigator: true,
        ).pushNamed('/cleaning-worker-rating', arguments: ratingArgs);
      }
    }
    unawaited(_refreshPendingGates());
  }

  Future<CleaningOrderDetailModel?> _fetchOrderDetails(int orderId) async {
    final Either<Failure, FetchCleaningOrderDetailsModel> detailsResponse =
        await getIt<FetchCleaningOrderDetailsUseCase>()(
          FetchCleaningOrderDetailsParams(orderId: orderId),
        );
    return detailsResponse.fold<CleaningOrderDetailModel?>(
      (_) => null,
      (result) => result.data,
    );
  }

  void _syncGateSessionWithDetails(CleaningOrderDetailModel details) {
    final orderId = details.id;
    if (orderId == null) return;
    _gateSession.syncWithStatus(
      bookingId: orderId,
      normalizedStatus: (details.status ?? '').toLowerCase(),
    );
    if (_isStartVerificationExpired(
      scheduledDate: details.scheduledDate,
      scheduledTime: details.scheduledTime,
      totalHours: details.totalHours,
      estimatedHours: details.estimatedHours,
    )) {
      _gateSession.suppressStartVerification(
        orderId,
        CleaningGateSuppressionReason.bookingTimeExpired,
      );
    }
  }

  bool _isStartVerificationExpired({
    required String? scheduledDate,
    required String? scheduledTime,
    required double? totalHours,
    required String? estimatedHours,
  }) {
    return isCleaningBookingPastEndTime(
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      totalHours: totalHours,
      estimatedHours: estimatedHours,
    );
  }

  Future<String?> _confirmStartVerificationCode({
    required int orderId,
    required String code,
  }) async {
    final Either<Failure, FetchCleaningOrderDetailsModel> response =
        await getIt<ConfirmCleaningStartVerificationUseCase>()(
          ConfirmCleaningStartVerificationParams(orderId: orderId, code: code),
        );

    return response.fold<String?>(
      (failure) {
        switch (failure.statusCode) {
          case 429:
            return 'محاولات كثيرة، انتظر دقيقة ثم حاول مجددا.';
          case 403:
            return 'غير مصرح لك بالتحقق من هذا الطلب حاليا.';
          case 422:
            return 'الرمز غير صحيح أو منتهي الصلاحية.';
          default:
            return failure.message;
        }
      },
      (result) {
        final details = result.data;
        if (details != null) {
          _syncGateSessionWithDetails(details);
        } else {
          _gateSession.clearStartDismissed(orderId);
        }
        return null;
      },
    );
  }

  Future<String?> _submitCompletionConfirm({required int orderId}) async {
    final response = await getIt<ConfirmCleaningCompletionUseCase>()(
      ConfirmCleaningCompletionParams(orderId: orderId),
    );
    return response.fold(
      (failure) => CleaningLifecycleErrorMapper.mapLifecycleActionFailure(
        failure,
        invalidStateMessage: 'لا يمكن تأكيد الإكمال في حالة الطلب الحالية.',
      ),
      (result) {
        final details = result.data;
        if (details != null) {
          _syncGateSessionWithDetails(details);
        } else {
          _gateSession.clearCompletionAwaitingCycle(orderId);
        }
        return null;
      },
    );
  }

  Future<String?> _submitCompletionReject({
    required int orderId,
    String? reason,
  }) async {
    final response = await getIt<RejectCleaningCompletionUseCase>()(
      RejectCleaningCompletionParams(orderId: orderId, reason: reason),
    );
    return response.fold(
      (failure) => CleaningLifecycleErrorMapper.mapLifecycleActionFailure(
        failure,
        invalidStateMessage: 'لا يمكن رفض الإكمال في حالة الطلب الحالية.',
      ),
      (result) {
        final details = result.data;
        if (details != null) {
          _syncGateSessionWithDetails(details);
        } else {
          _gateSession.clearCompletionAwaitingCycle(orderId);
        }
        return null;
      },
    );
  }

  Future<String?> _submitExtendCompletionTime({
    required int orderId,
    required int additionalMinutes,
  }) async {
    final response = await getIt<ExtendCleaningCompletionTimeUseCase>()(
      ExtendCleaningCompletionTimeParams(
        orderId: orderId,
        additionalMinutes: additionalMinutes,
      ),
    );
    return response.fold(
      (failure) => CleaningLifecycleErrorMapper.mapLifecycleActionFailure(
        failure,
        invalidStateMessage: 'لا يمكن طلب تمديد الوقت في حالة الطلب الحالية.',
      ),
      (result) {
        final details = result.data;
        if (details != null) {
          _syncGateSessionWithDetails(details);
        }
        return null;
      },
    );
  }

  int? _readCustomerId() {
    final raw = SharedPreferencesHelper.getData(key: 'customer_id');
    if (raw is int) return raw;
    return int.tryParse('${raw ?? ''}');
  }

  bool _hasToken() {
    final token = (SharedPreferencesHelper.getData(key: 'token') ?? '')
        .toString();
    return token.trim().isNotEmpty;
  }
}
