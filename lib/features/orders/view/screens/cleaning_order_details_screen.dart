import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/extensions/num_extensions.dart';
import 'package:dllni_user_app/core/realtime/cleaning_booking_pusher_service.dart';
import 'package:dllni_user_app/core/realtime/cleaning_gate_session_store.dart';
import 'package:dllni_user_app/core/realtime/cleaning_realtime_contract.dart';
import 'package:dllni_user_app/core/realtime/pusher_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/app_date_time_locale.dart';
import '../../../cl_main/view/widgets/cl_service_address_section_widget.dart';
import '../../../cl_main/view/widgets/cl_service_day_preview_card_widget.dart';
import '../../../cl_main/view/widgets/cl_service_section_card_widget.dart';
import '../../../cl_main/view/widgets/cl_service_time_picker_field_widget.dart';
import '../../../profile/domain/models/address_list_item.dart';
import '../../data/models/cleaning_booking_status.dart';
import '../helpers/cleaning_cancel_policy.dart';
import '../../data/models/cleaning_orders_api_models.dart';
import '../../domain/usecases/cancel_cleaning_order_use_case.dart';
import '../../domain/usecases/confirm_cleaning_completion_use_case.dart';
import '../../domain/usecases/confirm_cleaning_start_verification_use_case.dart';
import '../../../cl_main/domain/usecases/create_cleaning_order_use_case.dart';
import '../../domain/usecases/extend_cleaning_completion_time_use_case.dart';
import '../../domain/usecases/fetch_cleaning_order_details_use_case.dart';
import '../../domain/usecases/fetch_cleaning_worker_profile_use_case.dart';
import '../../domain/usecases/patch_cleaning_room_assignments_use_case.dart';
import '../../domain/usecases/reject_cleaning_completion_use_case.dart';
import '../helpers/cleaning_event_assistance_helper.dart';
import '../helpers/cleaning_lifecycle_error_mapper.dart';
import '../helpers/cleaning_order_polling_equality.dart';
import '../helpers/cleaning_order_realtime_policy.dart';
import '../helpers/cleaning_rebook_policy.dart';
import '../helpers/cleaning_worker_rating_gate.dart';
import '../../../profile/view/widgets/personal_details_app_bar.dart';
import '../manager/bloc/orders_bloc.dart';
import '../widgets/cleaning_cancel_reason_dialog.dart';
import 'cleaning_order_reschedule_screen.dart';
import 'cleaning_order_sos_screen.dart';
import 'cleaning_worker_rating_screen.dart';
import '../widgets/cleaning_accepted_workers_section_widget.dart';
import '../widgets/cleaning_preferred_worker_card_widget.dart';
import '../widgets/cleaning_room_assignments_section_widget.dart';
import '../widgets/cleaning_team_search_banner_widget.dart';
import '../widgets/cleaning_worker_tracking_map.dart';
import '../widgets/cleaning_completion_decision_sheet.dart';
import '../widgets/cleaning_start_verification_dialog.dart';

class CleaningOrderDetailsArgs {
  const CleaningOrderDetailsArgs({required this.orderId});

  final int orderId;
}

@AutoRoutePage(path: '/cleaning-order-details')
class CleaningOrderDetailsScreen extends StatefulWidget {
  const CleaningOrderDetailsScreen({super.key, required this.args});

  final CleaningOrderDetailsArgs args;

  @override
  State<CleaningOrderDetailsScreen> createState() =>
      _CleaningOrderDetailsScreenState();
}

class _CleaningOrderDetailsScreenState
    extends State<CleaningOrderDetailsScreen> {
  static const Duration _fallbackDebounce = Duration(milliseconds: 150);
  static const Duration _detailsPollInterval = Duration(seconds: 10);

  late int _activeOrderId;
  CleaningOrderDetailModel? _order;
  bool _isLoading = true;
  String? _loadError;
  late TextEditingController _fromTimeController;
  late TextEditingController _toTimeController;

  late final CleaningBookingPusherService _pusherService;
  final CleaningGateSessionStore _gateSession =
      CleaningGateSessionStore.instance;
  int? _subscribedBookingId;
  double? _workerLiveLatitude;
  double? _workerLiveLongitude;

  String? _gateError;
  bool _gateSubmitting = false;
  bool _verifyDialogDismissed = false;
  bool _verifyDialogOpen = false;
  bool _completionSheetDismissed = false;
  bool _completionSheetOpen = false;
  bool _realtimeAuthWarningShown = false;
  bool _reopenVerificationAfterRefresh = false;
  bool _reopenCompletionAfterRefresh = false;
  bool _isRebooking = false;
  bool _isPatchingRoomAssignments = false;
  Timer? _detailsFallbackRefreshDebounce;
  Timer? _detailsPollTimer;
  bool _isDetailsFetchInFlight = false;
  CleaningWorkerAcceptanceModel? _liveWorkerAcceptance;

  @override
  void initState() {
    super.initState();
    _activeOrderId = widget.args.orderId;
    _fromTimeController = TextEditingController();
    _toTimeController = TextEditingController();
    _pusherService = getIt<CleaningBookingPusherService>();
    _fetchDetails(triggerGatePrompts: true);
    _startDetailsPollTimer();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _connectCleaningPusher(),
    );
  }

  void _startDetailsPollTimer() {
    _detailsPollTimer?.cancel();
    _detailsPollTimer = Timer.periodic(_detailsPollInterval, (_) {
      if (!mounted) return;
      unawaited(
        _fetchDetails(
          showLoading: false,
          triggerGatePrompts: true,
          fallbackReason: 'periodic_cleaning_details_refresh',
        ),
      );
    });
  }

  @override
  void dispose() {
    _detailsFallbackRefreshDebounce?.cancel();
    _detailsPollTimer?.cancel();
    final subscribedBookingId = _subscribedBookingId;
    if (subscribedBookingId != null) {
      _pusherService.setBookingHandler(subscribedBookingId, null);
      _pusherService.setBookingErrorHandler(subscribedBookingId, null);
      unawaited(_pusherService.unsubscribeBookingChannel(subscribedBookingId));
    }
    _fromTimeController.dispose();
    _toTimeController.dispose();
    super.dispose();
  }

  String _normStatus(String? status) => (status ?? '').toLowerCase();

  bool _blocksReschedule(CleaningOrderDetailModel order) {
    final s = _normStatus(order.status);
    return s == CleaningBookingStatus.awaitingStartVerification ||
        s == CleaningBookingStatus.awaitingWorkerStartConfirmation ||
        s == CleaningBookingStatus.awaitingCustomerCompletion ||
        s == CleaningBookingStatus.inProgress ||
        s == CleaningBookingStatus.timeExtensionRequested ||
        order.isAcceptedWaitingState;
  }

  bool _canEditRoomAssignments(CleaningOrderDetailModel order) {
    final s = _normStatus(order.status);
    return s == CleaningBookingStatus.pending ||
        s == CleaningBookingStatus.workerAssigned &&
        !order.isAcceptedWaitingState;
  }

  void _connectCleaningPusher() {
    if (!mounted) return;
    final bookingId = _activeOrderId;
    final previousBookingId = _subscribedBookingId;
    if (previousBookingId != null && previousBookingId != bookingId) {
      _pusherService.setBookingHandler(previousBookingId, null);
      _pusherService.setBookingErrorHandler(previousBookingId, null);
      unawaited(_pusherService.unsubscribeBookingChannel(previousBookingId));
    }
    _pusherService.setBookingHandler(bookingId, _onCleaningPusherEvent);
    _pusherService.setBookingErrorHandler(bookingId, _onCleaningPusherError);
    _subscribedBookingId = bookingId;
    unawaited(_pusherService.subscribeBookingChannel(bookingId));
  }

  void _onCleaningPusherEvent(String eventName, Map<String, dynamic> payload) {
    final normalizedEvent = CleaningRealtimeContract.normalizeEventName(
      eventName,
    );

    if (normalizedEvent == CleaningRealtimeContract.teamUpdated) {
      _applyLiveTeamSummary(payload);
      _scheduleDetailsFallbackRefresh(
        fallbackReason: 'realtime_team_updated_refresh',
      );
      return;
    }

    if (normalizedEvent == CleaningRealtimeContract.awaitingStartVerification) {
      _gateSession.clearStartDismissed(_activeOrderId);
      _reopenVerificationAfterRefresh = true;
      if (_verifyDialogDismissed && mounted) {
        setState(() => _verifyDialogDismissed = false);
      } else {
        _verifyDialogDismissed = false;
      }
    }
    if (normalizedEvent ==
        CleaningRealtimeContract.awaitingCustomerCompletion) {
      _gateSession.clearCompletionAwaitingCycle(_activeOrderId);
      _reopenCompletionAfterRefresh = true;
      if (_completionSheetDismissed && mounted) {
        setState(() => _completionSheetDismissed = false);
      } else {
        _completionSheetDismissed = false;
      }
    }

    final action = CleaningOrderRealtimePolicy.resolve(
      eventName: eventName,
      payload: payload,
      currentStatus: _order?.status,
    );
    if (action.type == CleaningOrderRealtimeActionType.patchWorkerLocation) {
      _applyWorkerLocation(payload);
      return;
    }
    if (action.type != CleaningOrderRealtimeActionType.refreshDetails) {
      return;
    }
    if (action.reopenCompletionAfterRefresh) {
      _reopenCompletionAfterRefresh = true;
    }
    _scheduleDetailsFallbackRefresh(
      fallbackReason: 'realtime_lifecycle_event_refresh',
    );
  }

  void _applyWorkerLocation(Map<String, dynamic> payload) {
    final location = CleaningRealtimeContract.parseLocation(payload);
    if (location == null || !mounted) return;
    setState(() {
      _workerLiveLatitude = location.latitude;
      _workerLiveLongitude = location.longitude;
    });
  }

  void _applyLiveTeamSummary(Map<String, dynamic> payload) {
    final unwrapped = CleaningRealtimeContract.unwrapPayload(payload);
    final team = unwrapped['team'];
    if (team is! Map) return;

    final teamMap = Map<String, dynamic>.from(team);
    final acceptance = CleaningWorkerAcceptanceModel(
      required: _intFromDynamic(
        teamMap['requiredWorkers'] ?? teamMap['required_workers'],
      ),
      accepted: _intFromDynamic(
        teamMap['acceptedWorkers'] ?? teamMap['accepted_workers'],
      ),
      remaining: _intFromDynamic(
        teamMap['remainingWorkers'] ?? teamMap['remaining_workers'],
      ),
      isFulfilled: _boolFromDynamic(
        teamMap['isFulfilled'] ?? teamMap['is_fulfilled'],
      ),
    );

    if (!mounted) return;
    setState(() {
      _liveWorkerAcceptance = acceptance;
    });
  }

  int? _intFromDynamic(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  bool? _boolFromDynamic(dynamic value) {
    if (value is bool) return value;
    if (value is num) {
      if (value == 1) return true;
      if (value == 0) return false;
    }
    final normalized = value?.toString().trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
    return null;
  }

  CleaningWorkerAcceptanceModel? _effectiveWorkerAcceptance(
    CleaningOrderDetailModel order,
  ) {
    return _liveWorkerAcceptance ?? order.workerAcceptance;
  }

  bool _isSearchingForWorkers(
    CleaningOrderDetailModel order,
    CleaningWorkerAcceptanceModel? acceptance,
  ) {
    final statusNorm = _normStatus(order.status);
    if (statusNorm != CleaningBookingStatus.pending) return false;
    if (acceptance == null) return order.isSearchingForWorkers;
    return acceptance.isFulfilled != true;
  }

  void _onCleaningPusherError(RealtimeChannelError error) {
    if (error.statusCode != 403) return;
    _scheduleDetailsFallbackRefresh(
      fallbackReason: 'realtime_channel_auth_403_refresh',
    );
    if (_realtimeAuthWarningShown || !mounted) return;
    _realtimeAuthWarningShown = true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تعذر استقبال التحديث المباشر حالياً. تتم مزامنة الطلب بالخلفية.',
        ),
      ),
    );
  }

  void _scheduleDetailsFallbackRefresh({required String fallbackReason}) {
    _detailsFallbackRefreshDebounce?.cancel();
    _detailsFallbackRefreshDebounce = Timer(_fallbackDebounce, () {
      unawaited(
        _fetchDetails(
          showLoading: false,
          triggerGatePrompts: true,
          fallbackReason: fallbackReason,
        ),
      );
    });
  }

  Future<void> _fetchDetails({
    bool showLoading = true,
    bool triggerGatePrompts = false,
    String? fallbackReason,
  }) async {
    if (!showLoading && _isDetailsFetchInFlight) return;
    if (!showLoading) {
      _isDetailsFetchInFlight = true;
    }
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }
    try {
      final Either<Failure, FetchCleaningOrderDetailsModel> response =
          await getIt<FetchCleaningOrderDetailsUseCase>()(
            FetchCleaningOrderDetailsParams(orderId: _activeOrderId),
          );
      if (!mounted) return;
      response.fold(
        (failure) {
          if (!showLoading) return;
          setState(() {
            _isLoading = false;
            _loadError = failure.message;
          });
        },
        (result) {
          final updatedOrder = result.data;
          final currentOrder = _order;
          if (!showLoading &&
              updatedOrder != null &&
              currentOrder != null &&
              cleaningOrderDetailDisplayEquals(currentOrder, updatedOrder)) {
            return;
          }
          setState(() {
            if (showLoading) {
              _isLoading = false;
            }
            _order = updatedOrder;
            if (updatedOrder != null) {
              _syncGateSessionWithOrder(updatedOrder);
              _liveWorkerAcceptance = updatedOrder.workerAcceptance;
            } else {
              _liveWorkerAcceptance = null;
            }
            if (showLoading) {
              _loadError = updatedOrder == null
                  ? 'تعذر تحميل تفاصيل الطلب'
                  : null;
            }
          });
        },
      );
    } finally {
      if (!showLoading) {
        _isDetailsFetchInFlight = false;
      }
    }
    if (fallbackReason != null) {
      PusherServiceLogger.event(
        'private-cleaning-booking.$_activeOrderId',
        'CleaningBookingTrackingUpdated',
        _order?.toCleaningOrderModel().status,
        eventHandledAtMs: DateTime.now().millisecondsSinceEpoch,
        fallbackReason: fallbackReason,
      );
    }
    if (triggerGatePrompts) {
      unawaited(_maybePromptForVerifyGate());
      unawaited(_maybePromptForCompletionGate());
      final order = _order;
      if (_reopenVerificationAfterRefresh &&
          order != null &&
          _normStatus(order.status) ==
              CleaningBookingStatus.awaitingStartVerification) {
        _reopenVerificationAfterRefresh = false;
        unawaited(_maybePromptForVerifyGate(force: true));
      }
      if (_reopenCompletionAfterRefresh &&
          order != null &&
          _normStatus(order.status) ==
              CleaningBookingStatus.awaitingCustomerCompletion) {
        _reopenCompletionAfterRefresh = false;
        final orderId = order.id;
        if (orderId != null) {
          _gateSession.clearCompletionAwaitingCycle(orderId);
          if (_completionSheetDismissed && mounted) {
            setState(() => _completionSheetDismissed = false);
          }
        }
        unawaited(_openCompletionSheet(force: true));
      }
    }
  }

  Future<String?> _confirmStartVerification(
    String code,
    CleaningOrderDetailModel order,
  ) async {
    final orderId = order.id;
    if (orderId == null) return 'تعذر تحديد الطلب';
    setState(() {
      _gateSubmitting = true;
      _gateError = null;
    });
    final response = await getIt<ConfirmCleaningStartVerificationUseCase>()(
      ConfirmCleaningStartVerificationParams(orderId: orderId, code: code),
    );
    if (!mounted) return null;
    String? errorMessage;
    response.fold(
      (failure) => setState(() {
        _gateSubmitting = false;
        errorMessage = _mapVerificationError(failure);
        _gateError = errorMessage;
      }),
      (result) {
        setState(() {
          _gateSubmitting = false;
          _gateError = null;
          _order = result.data;
          final updatedOrder = result.data;
          if (updatedOrder != null) {
            _syncGateSessionWithOrder(updatedOrder);
            if (updatedOrder.id != null) {
              _gateSession.clearStartDismissed(updatedOrder.id!);
            }
          } else {
            _gateSession.clearStartDismissed(orderId);
          }
          _verifyDialogDismissed = false;
        });
      },
    );
    if (!mounted) return errorMessage;
    return errorMessage;
  }

  String _mapVerificationError(Failure failure) {
    return CleaningLifecycleErrorMapper.mapVerificationFailure(failure);
  }

  Future<void> _maybePromptForVerifyGate({bool force = false}) async {
    final order = _order;
    if (!mounted || order == null) return;
    final orderId = order.id;
    if (orderId == null) return;
    final status = _normStatus(order.status);
    if (status != CleaningBookingStatus.awaitingStartVerification) {
      _gateSession.clearStartDismissed(orderId);
      _verifyDialogDismissed = false;
      _reopenVerificationAfterRefresh = false;
      return;
    }
    if (_isStartVerificationExpired(order)) {
      _gateSession.suppressStartVerification(
        orderId,
        CleaningGateSuppressionReason.bookingTimeExpired,
      );
      setState(() => _verifyDialogDismissed = true);
      return;
    }
    if (_verifyDialogOpen) return;
    if (_gateSession.isStartVerificationSuppressed(orderId, force: force)) {
      if (!_verifyDialogDismissed) {
        setState(() => _verifyDialogDismissed = true);
      }
      return;
    }
    _verifyDialogOpen = true;
    final scheduledAt = resolveCleaningBookingStartDateTime(
      scheduledDate: order.scheduledDate,
      scheduledTime: order.scheduledTime,
    );
    final confirmed = await CleaningStartVerificationDialog.show(
      context,
      bookingId: order.id,
      bookingNumber: order.bookingNumber,
      dateTime: scheduledAt?.toIso8601String(),
      workerAvatarUrl: order.worker?.avatarUrl,
      onSubmit: (code) => _confirmStartVerification(code, order),
    );
    if (!mounted) return;
    _verifyDialogOpen = false;
    if (!confirmed) {
      return;
    }
    _gateSession.clearStartDismissed(orderId);
    setState(() => _verifyDialogDismissed = false);
    unawaited(_fetchDetails(showLoading: false));
  }

  Future<String?> _submitCompletionConfirm(
    CleaningOrderDetailModel order,
  ) async {
    final orderId = order.id;
    if (orderId == null) return 'تعذر تحديد الطلب';
    setState(() {
      _gateSubmitting = true;
      _gateError = null;
    });
    final response = await getIt<ConfirmCleaningCompletionUseCase>()(
      ConfirmCleaningCompletionParams(orderId: orderId),
    );
    if (!mounted) return 'تعذر تحديث الحالة';
    String? errorMessage;
    response.fold(
      (failure) => setState(() {
        _gateSubmitting = false;
        errorMessage = CleaningLifecycleErrorMapper.mapLifecycleActionFailure(
          failure,
          invalidStateMessage: 'لا يمكن تأكيد الإكمال في حالة الطلب الحالية.',
        );
        _gateError = errorMessage;
      }),
      (result) => setState(() {
        _gateSubmitting = false;
        _gateError = null;
        _order = result.data;
        final updatedOrder = result.data;
        if (updatedOrder != null) {
          _syncGateSessionWithOrder(updatedOrder);
        }
      }),
    );
    return errorMessage;
  }

  Future<String?> _submitCompletionReject(
    CleaningOrderDetailModel order,
    String? reason,
  ) async {
    final orderId = order.id;
    if (orderId == null) return 'تعذر تحديد الطلب';
    setState(() {
      _gateSubmitting = true;
      _gateError = null;
    });
    final response = await getIt<RejectCleaningCompletionUseCase>()(
      RejectCleaningCompletionParams(orderId: orderId, reason: reason),
    );
    if (!mounted) return 'تعذر تحديث الحالة';
    String? errorMessage;
    response.fold(
      (failure) => setState(() {
        _gateSubmitting = false;
        errorMessage = CleaningLifecycleErrorMapper.mapLifecycleActionFailure(
          failure,
          invalidStateMessage: 'لا يمكن رفض الإكمال في حالة الطلب الحالية.',
        );
        _gateError = errorMessage;
      }),
      (result) => setState(() {
        _gateSubmitting = false;
        _gateError = null;
        _order = result.data;
        final updatedOrder = result.data;
        if (updatedOrder != null) {
          _syncGateSessionWithOrder(updatedOrder);
        }
      }),
    );
    return errorMessage;
  }

  Future<String?> _submitExtendTime(
    CleaningOrderDetailModel order,
    int? additionalMinutes,
  ) async {
    final orderId = order.id;
    if (orderId == null) return 'تعذر تحديد الطلب';
    setState(() {
      _gateSubmitting = true;
      _gateError = null;
    });
    final response = await getIt<ExtendCleaningCompletionTimeUseCase>()(
      ExtendCleaningCompletionTimeParams(
        orderId: orderId,
        additionalMinutes: additionalMinutes,
      ),
    );
    if (!mounted) return 'تعذر تحديث الحالة';
    String? errorMessage;
    String? successMessage;
    response.fold(
      (failure) => setState(() {
        _gateSubmitting = false;
        errorMessage = CleaningLifecycleErrorMapper.mapLifecycleActionFailure(
          failure,
          invalidStateMessage: 'لا يمكن طلب تمديد الوقت في حالة الطلب الحالية.',
        );
        _gateError = errorMessage;
      }),
      (result) => setState(() {
        _gateSubmitting = false;
        _gateError = null;
        _order = result.data;
        final updatedOrder = result.data;
        if (updatedOrder != null) {
          _syncGateSessionWithOrder(updatedOrder);
        }
        successMessage = _extensionRequestSuccessMessage(
          result.extensionPricing,
        );
      }),
    );
    if (errorMessage == null && mounted) {
      AppToast.showToast(
        context: context,
        message: successMessage ?? 'تم إرسال طلب تمديد الوقت إلى العامل',
        type: ToastificationType.success,
      );
    }
    return errorMessage;
  }

  String? _extensionRequestSuccessMessage(
    CleaningExtensionPricingModel? pricing,
  ) {
    final price = pricing?.calculatedExtensionPrice;
    if (price == null) return null;
    final currency = switch ((pricing?.currency ?? '').toUpperCase()) {
      'SYP' => 'ل.س',
      final value when value.isNotEmpty => value,
      _ => 'ل.س',
    };
    return 'تم إرسال طلب تمديد الوقت إلى العامل. الرسوم المحسوبة: ${price.formatWithComma()} $currency';
  }

  Future<List<CleaningExtensionRangeModel>> _fetchExtensionTimeRanges(
    int orderId,
  ) async {
    final response = await getIt<FetchCleaningOrderDetailsUseCase>()(
      FetchCleaningOrderDetailsParams(orderId: orderId),
    );
    return response.fold((failure) => throw Exception(failure.message), (
      result,
    ) {
      final updatedOrder = result.data;
      if (updatedOrder != null && mounted) {
        setState(() {
          _order = updatedOrder;
          _syncGateSessionWithOrder(updatedOrder);
        });
      }
      return result.extendedTimeRanges;
    });
  }

  Future<void> _openCompletionSheet({bool force = false}) async {
    final order = _order;
    if (order == null || !mounted) return;
    final orderId = order.id;
    if (orderId == null) return;
    final status = _normStatus(order.status);
    if (status != CleaningBookingStatus.awaitingCustomerCompletion) return;
    if (_completionSheetOpen) return;
    if (_gateSession.isCompletionSuppressed(orderId, force: force)) {
      if (!_completionSheetDismissed) {
        setState(() => _completionSheetDismissed = true);
      }
      return;
    }
    _completionSheetOpen = true;
    final decision = await CleaningCompletionDecisionSheet.show(
      context,
      useRootNavigator: true,
      onConfirm: () => _submitCompletionConfirm(order),
      onReject: (reason) => _submitCompletionReject(order, reason),
      onExtend: (minutes) => _submitExtendTime(order, minutes),
      fetchExtensionTimeRanges: () => _fetchExtensionTimeRanges(orderId),
    );
    if (!mounted) return;
    _completionSheetOpen = false;
    if (decision == null) {
      _gateSession.suppressCompletion(
        orderId,
        CleaningGateSuppressionReason.userDismissed,
        currentAwaitingCycleOnly: true,
      );
      setState(() => _completionSheetDismissed = true);
      return;
    }
    _gateSession.clearCompletionAwaitingCycle(orderId);
    setState(() => _completionSheetDismissed = false);
    if (decision == CleaningCompletionDecision.confirmed && mounted) {
      final updatedOrder = _order;
      if (updatedOrder != null) {
        await _navigateToRating(updatedOrder);
      }
    }
    unawaited(_fetchDetails(showLoading: false));
  }

  Future<void> _maybePromptForCompletionGate({bool force = false}) async {
    final order = _order;
    if (!mounted || order == null) return;
    final orderId = order.id;
    if (orderId == null) return;
    final status = _normStatus(order.status);
    if (status != CleaningBookingStatus.awaitingCustomerCompletion) {
      _gateSession.clearCompletionAwaitingCycle(orderId);
      _completionSheetDismissed = false;
      _reopenCompletionAfterRefresh = false;
      return;
    }
    if (_gateSession.isCompletionSuppressed(orderId, force: force)) {
      _completionSheetDismissed = true;
      return;
    }
    await _openCompletionSheet(force: force);
  }

  String _serviceLabel(CleaningOrderDetailModel order) {
    return CleaningEventAssistanceHelper.serviceTitle(
      propertyType: order.propertyType,
      customService: order.propertyDetails?.customService,
    );
  }

  String _bookingLabel(CleaningOrderDetailModel order) {
    final bookingNumber = order.bookingNumber;
    if (bookingNumber == null || bookingNumber.isEmpty) {
      return '#${order.id ?? '-'}';
    }
    return '#$bookingNumber';
  }

  DateTime? _resolveStartDateTime(CleaningOrderDetailModel order) {
    final date = order.scheduledDate;
    final time = order.scheduledTime;
    if (date == null || date.isEmpty || time == null || time.isEmpty) {
      return null;
    }
    final raw = '$date ${time.split('.').first}';
    return DateTime.tryParse(raw);
  }

  double _resolveHours(CleaningOrderDetailModel order) {
    final total = order.totalHours;
    if (total != null && total > 0) return total;
    return double.tryParse(order.estimatedHours ?? '') ?? 0;
  }

  bool _isStartVerificationExpired(CleaningOrderDetailModel order) {
    return isCleaningBookingScheduledDateBeforeToday(
      scheduledDate: order.scheduledDate,
    );
  }

  void _syncGateSessionWithOrder(CleaningOrderDetailModel order) {
    final orderId = order.id;
    if (orderId == null) return;
    final normalizedStatus = _normStatus(order.status);
    _gateSession.syncWithStatus(
      bookingId: orderId,
      normalizedStatus: normalizedStatus,
    );
    if (_isStartVerificationExpired(order)) {
      _gateSession.suppressStartVerification(
        orderId,
        CleaningGateSuppressionReason.bookingTimeExpired,
      );
    }
    _verifyDialogDismissed =
        normalizedStatus == CleaningBookingStatus.awaitingStartVerification &&
        _gateSession.isStartVerificationSuppressed(orderId);
    _completionSheetDismissed =
        normalizedStatus == CleaningBookingStatus.awaitingCustomerCompletion &&
        _gateSession.isCompletionSuppressed(orderId);
  }

  Future<void> _navigateToRating(CleaningOrderDetailModel order) async {
    if (!mounted || order.id == null) return;
    final workerProfile = await resolveCleaningWorkerProfileForRating(
      workerId: order.worker?.id,
      fetchWorkerProfile: (params) =>
          getIt<FetchCleaningWorkerProfileUseCase>()(params),
      onError: (message) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      },
    );
    if (!mounted || workerProfile == null) return;
    final ratingArgs = CleaningWorkerRatingArgs(
      orderId: order.id!,
      workerProfile: workerProfile,
    );
    context.pushRoute('/cleaning-worker-rating', arguments: ratingArgs);
  }

  String _timeLabel(DateTime? value) {
    if (value == null) return '-';
    final hour = value.hour;
    final minute = value.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final normalizedHour = hour % 12 == 0 ? 12 : hour % 12;
    return '${normalizedHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  String _dayLabel(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '-';
    final date = DateTime.tryParse(rawDate);
    if (date == null) return '-';
    const arabicDays = <String>[
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return arabicDays[date.weekday - 1];
  }

  String _dayDateEnLabel(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '-';
    final date = DateTime.tryParse(rawDate);
    if (date == null) return '-';
    return AppDateTimeLocale.dateFormat('d MMM yyyy').format(date);
  }

  Widget _card({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Future<void> _assignRoom(int roomId, int? workerId) async {
    if (_isPatchingRoomAssignments) return;
    setState(() => _isPatchingRoomAssignments = true);

    final response = await getIt<PatchCleaningRoomAssignmentsUseCase>()(
      PatchCleaningRoomAssignmentsParams(
        orderId: _activeOrderId,
        assignments: [
          CleaningRoomAssignmentUpdate(roomId: roomId, workerId: workerId),
        ],
      ),
    );

    if (!mounted) return;
    response.fold(
      (failure) {
        setState(() => _isPatchingRoomAssignments = false);
        AppToast.showToast(
          context: context,
          message: failure.message,
          type: ToastificationType.error,
        );
      },
      (result) {
        setState(() {
          _isPatchingRoomAssignments = false;
          _order = result.data ?? _order;
        });
        AppToast.showToast(
          context: context,
          message: 'تم تحديث توزيع الغرف',
          type: ToastificationType.success,
        );
      },
    );
  }

  Future<void> _callWorker(String? phone) async {
    final value = phone?.trim();
    if (value == null || value.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('رقم الهاتف غير متوفر')));
      return;
    }
    final uri = Uri(scheme: 'tel', path: value);
    final launched = await launchUrl(uri);
    if (!launched && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذر فتح تطبيق الاتصال')));
    }
  }

  String _leadTimeLockMessage(Duration? remaining) {
    if (remaining == null) {
      return 'لا يمكن تعديل العنوان أو الموعد قبل أقل من 24 ساعة من وقت الخدمة.';
    }
    final hours = remaining.inHours;
    if (hours <= 0) {
      return 'موعد الخدمة قريب جدًا، لا يمكن تعديل العنوان أو الموعد.';
    }
    return 'لا يمكن تعديل العنوان أو الموعد عندما يتبقى أقل من 24 ساعة. المتبقي: $hours ساعة.';
  }

  void _openOrdersListFallback() {
    if (!mounted) return;
    context.pushRoute('/main', arguments: 1);
  }

  CleaningRebookRequest? _buildRebookRequest({
    required CleaningOrderDetailModel order,
    required String scheduledDate,
    required String scheduledTime,
    required String address,
    required String locationName,
    required double addressLatitude,
    required double addressLongitude,
  }) {
    final orderId = order.id;
    final propertyType = order.propertyType;
    final details = order.propertyDetails;
    if (orderId == null ||
        propertyType == null ||
        propertyType.isEmpty ||
        details == null ||
        details.bedrooms == null ||
        details.rooms == null ||
        details.bathrooms == null ||
        (details.livingRoomSize ?? '').isEmpty) {
      return null;
    }

    return CleaningRebookRequest(
      existingOrderId: orderId,
      propertyType: propertyType,
      bedrooms: details.bedrooms!,
      rooms: details.rooms!,
      bathrooms: details.bathrooms!,
      livingRoomSize: details.livingRoomSize!,
      address: address,
      locationName: locationName,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      addressLatitude: addressLatitude,
      addressLongitude: addressLongitude,
      genderPreference: order.genderPreference,
      preferredWorkerId: order.workerId,
    );
  }

  Future<void> _switchToOrder(int newOrderId, {String? successMessage}) async {
    final shouldReconnect = _activeOrderId != newOrderId;
    setState(() {
      _activeOrderId = newOrderId;
      if (shouldReconnect) {
        _workerLiveLatitude = null;
        _workerLiveLongitude = null;
      }
    });
    if (shouldReconnect) {
      _connectCleaningPusher();
    }
    await _fetchDetails(showLoading: true, triggerGatePrompts: true);
    if (!mounted || successMessage == null || successMessage.isEmpty) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(successMessage)));
  }

  Future<void> _rebookWithChanges({
    required CleaningOrderDetailModel order,
    required String scheduledDate,
    required String scheduledTime,
    required String address,
    required String locationName,
    required double addressLatitude,
    required double addressLongitude,
  }) async {
    final leadTimeCheck = CleaningRebookPolicy.evaluateLeadTime(
      scheduledDate: order.scheduledDate,
      scheduledTime: order.scheduledTime,
    );
    if (!leadTimeCheck.allowed) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_leadTimeLockMessage(leadTimeCheck.remaining))),
      );
      return;
    }

    final request = _buildRebookRequest(
      order: order,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      address: address,
      locationName: locationName,
      addressLatitude: addressLatitude,
      addressLongitude: addressLongitude,
    );
    if (request == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('بيانات الطلب غير مكتملة، لا يمكن تنفيذ إعادة الحجز.'),
        ),
      );
      return;
    }

    setState(() {
      _isRebooking = true;
    });

    final policy = CleaningRebookPolicy(
      cancelOrder: (params) => getIt<CancelCleaningOrderUseCase>()(params),
      createOrder: (params) => getIt<CreateCleaningOrderUseCase>()(params),
    );
    final result = await policy.execute(request: request);
    if (!mounted) return;

    setState(() {
      _isRebooking = false;
    });

    await result.fold(
      (failure) async {
        final message = CleaningLifecycleErrorMapper.mapLifecycleActionFailure(
          failure,
          invalidStateMessage:
              'لا يمكن إعادة حجز الطلب في حالته الحالية. تحقق من حالة الطلب وحاول لاحقًا.',
        );
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      },
      (outcome) async {
        final newOrderId = outcome.newOrderId;
        if (newOrderId == null) {
          _openOrdersListFallback();
          return;
        }
        await _switchToOrder(
          newOrderId,
          successMessage: outcome.createMessage ?? 'تم تحديث الطلب بنجاح.',
        );
      },
    );
  }

  Future<void> _changeAddress(CleaningOrderDetailModel order) async {
    if (_isRebooking || _blocksReschedule(order)) return;
    final selectedAddress = await context.pushRoute(
      '/myaddresses',
      arguments: true,
    );
    if (!mounted || selectedAddress is! AddressListItem) return;

    final latitude = selectedAddress.latitude;
    final longitude = selectedAddress.longitude;
    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('العنوان المختار لا يحتوي على إحداثيات موقع صالحة.'),
        ),
      );
      return;
    }

    final scheduledDate = order.scheduledDate;
    final scheduledTime = order.scheduledTime;
    if (scheduledDate == null ||
        scheduledDate.isEmpty ||
        scheduledTime == null ||
        scheduledTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('بيانات موعد الطلب غير مكتملة، لا يمكن تغيير العنوان.'),
        ),
      );
      return;
    }

    await _rebookWithChanges(
      order: order,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      address: selectedAddress.line1,
      locationName: selectedAddress.label,
      addressLatitude: latitude,
      addressLongitude: longitude,
    );
  }

  Future<void> _goToReschedule(CleaningOrderDetailModel order) async {
    if (_blocksReschedule(order) || _isRebooking) {
      return;
    }
    final result = await context.pushRoute(
      '/cleaning-order-reschedule',
      arguments: CleaningOrderRescheduleArgs(
        order: order.toCleaningOrderModel(),
      ),
    );
    if (!mounted) return;
    if (result is CleaningOrderRescheduleResult) {
      if (result.openOrdersListFallback) {
        _openOrdersListFallback();
        return;
      }
      final newOrderId = result.newOrderId;
      if (newOrderId != null) {
        await _switchToOrder(
          newOrderId,
          successMessage: 'تم تحديث الطلب بنجاح.',
        );
      }
      return;
    }
    if (result == true) {
      _fetchDetails();
    }
  }

  Future<void> _cancelOrder(CleaningOrderDetailModel order) async {
    final orderId = order.id;
    final OrdersBloc ordersBloc = getIt<OrdersBloc>();
    if (orderId == null) return;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CleaningCancelReasonDialog(
        orderId: orderId,
        bloc: ordersBloc,
        scheduledDate: order.scheduledDate,
        scheduledTime: order.scheduledTime,
      ),
    );
    if (result == true && mounted) {
      _gateSession.suppressStartVerification(
        orderId,
        CleaningGateSuppressionReason.cancelled,
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xffF3F4F6),
        appBar: AppBar(
          title: const Text('تفاصيل الطلب'),
          centerTitle: true,
          backgroundColor: const Color(0xffF3F4F6),
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadError != null) {
      return Scaffold(
        backgroundColor: const Color(0xffF3F4F6),
        appBar: AppBar(
          title: const Text('تفاصيل الطلب'),
          centerTitle: true,
          backgroundColor: const Color(0xffF3F4F6),
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_loadError!, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _fetchDetails(showLoading: true),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (order == null) {
      return Scaffold(
        backgroundColor: const Color(0xffF3F4F6),
        body: SafeArea(
          child: Column(
            children: [
              PersonalDetailsAppBar(title: 'تفاصيل الطلب'),
              const Expanded(
                child: Center(child: Text('تعذر تحميل تفاصيل الطلب')),
              ),
            ],
          ),
        ),
      );
    }
    final startDateTime = _resolveStartDateTime(order);
    final endDateTime = startDateTime?.add(
      Duration(minutes: (_resolveHours(order) * 60).round()),
    );
    _fromTimeController.text = _timeLabel(startDateTime);
    _toTimeController.text = _timeLabel(endDateTime);
    final statusNorm = _normStatus(order.status);
    final isTerminalStatus =
        statusNorm == CleaningBookingStatus.completed ||
        statusNorm == CleaningBookingStatus.cancelled;
    final canCancel = CleaningCancelPolicy.isCancellable(order.status);
    final leadTimeCheck = CleaningRebookPolicy.evaluateLeadTime(
      scheduledDate: order.scheduledDate,
      scheduledTime: order.scheduledTime,
    );
    final editLocked =
        _blocksReschedule(order) || _isRebooking || !leadTimeCheck.allowed;
    final liveAcceptance = _effectiveWorkerAcceptance(order);
    final searchingForWorkers = _isSearchingForWorkers(order, liveAcceptance);
    final showWorkerLifecycleBanner =
        searchingForWorkers || order.isAcceptedWaitingState;

    Widget? sosTrailing;
    if (!isTerminalStatus) {
      sosTrailing = FilledButton(
        onPressed: () => context.pushRoute(
          '/cleaning-order-sos',
          arguments: CleaningOrderSosArgs(orderId: _activeOrderId),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: context.error,
          foregroundColor: context.onError,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('SOS'),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            PersonalDetailsAppBar(title: 'تفاصيل الطلب', trailing: sosTrailing),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    _fetchDetails(showLoading: false, triggerGatePrompts: true),
                child: ListView(
                  padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 24),
                  children: [
                    if (_isRebooking) ...[
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: const [
                            Text(
                              'يتم تحديث الطلب بالخلفية...',
                              style: TextStyle(
                                color: Color(0xff1F2937),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 8),
                            LinearProgressIndicator(minHeight: 2),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'معلومات الخدمة',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xff1F2937),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _bookingLabel(order),
                                  style: const TextStyle(
                                    color: Color(0xff9CA3AF),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsetsDirectional.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE2F5F4),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  order.displayStatusLabelAr,
                                  style: const TextStyle(
                                    color: Color(0xff0CBBC7),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _serviceLabel(order),
                            style: const TextStyle(
                              color: Color(0xff111827),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (CleaningEventAssistanceHelper.isEventAssistance(
                      order.propertyType,
                    )) ...[
                      const SizedBox(height: 12),
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'تفاصيل المناسبة',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xff1F2937),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _SummaryRow(
                              title: 'نوع المناسبة',
                              value:
                                  CleaningEventAssistanceHelper.eventTypeLabelAr(
                                    order.propertyDetails?.eventType,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            _SummaryRow(
                              title: 'عدد الضيوف',
                              value:
                                  '${order.propertyDetails?.guestCount ?? '-'}',
                            ),
                            const SizedBox(height: 6),
                            _SummaryRow(
                              title: 'نوع المكان',
                              value:
                                  CleaningEventAssistanceHelper.venueTypeLabelAr(
                                    order.propertyDetails?.venueType,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            _SummaryRow(
                              title: 'مدة الحجز',
                              value: CleaningEventAssistanceHelper.formatHours(
                                CleaningEventAssistanceHelper.resolveBookedHours(
                                  propertyHours: order.propertyDetails?.hours,
                                  totalHours: order.totalHours,
                                  estimatedHours: double.tryParse(
                                    order.estimatedHours ?? '',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (showWorkerLifecycleBanner) ...[
                      const SizedBox(height: 12),
                      CleaningTeamSearchBannerWidget(
                        acceptance: liveAcceptance,
                        numberOfWorkers: order.numberOfWorkers,
                        workerOrderStatus: order.workerOrderStatus,
                        workerOrderStatusLabel: order.workerOrderStatusLabel,
                        requiredWorkersCount: order.requiredWorkersCount,
                        acceptedWorkersCount: order.acceptedWorkersCount,
                        pendingWorkersCount: order.pendingWorkersCount,
                      ),
                    ],
                    if (searchingForWorkers &&
                        (order.assignmentMode ?? '').toLowerCase() ==
                            'preferred_worker' &&
                        order.preferredWorker != null) ...[
                      const SizedBox(height: 12),
                      CleaningPreferredWorkerCardWidget(
                        worker: order.preferredWorker!,
                        onCallWorker: _callWorker,
                      ),
                    ],
                    if (order.isMultiWorkerTeam &&
                        order.acceptedWorkerAssignments.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      CleaningAcceptedWorkersSectionWidget(
                        assignments: order.acceptedWorkerAssignments,
                        onCallWorker: _callWorker,
                      ),
                    ],
                    if ((order.roomAssignments ?? const []).isNotEmpty) ...[
                      const SizedBox(height: 12),
                      CleaningRoomAssignmentsSectionWidget(
                        roomAssignments: order.roomAssignments!,
                        acceptedWorkers: order.acceptedWorkerAssignments,
                        isEditable: _canEditRoomAssignments(order),
                        isSaving: _isPatchingRoomAssignments,
                        onAssignRoom: _assignRoom,
                      ),
                    ],
                    if (statusNorm ==
                        CleaningBookingStatus.awaitingStartVerification) ...[
                      const SizedBox(height: 12),
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'التحقق من بدء الخدمة',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xff1F2937),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'أدخل رمز الأمان من النافذة المنبثقة لتأكيد بدء العمل.',
                              style: TextStyle(
                                color: Color(0xff6B7280),
                                fontSize: 13,
                              ),
                            ),
                            if (_gateError != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _gateError!,
                                style: const TextStyle(
                                  color: Color(0xffDC2626),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _gateSubmitting
                                  ? null
                                  : () {
                                      unawaited(
                                        _maybePromptForVerifyGate(force: true),
                                      );
                                    },
                              icon: const Icon(Icons.lock_clock_outlined),
                              label: const Text('إعادة فتح رمز الأمان'),
                            ),
                            if (_verifyDialogDismissed) ...[
                              const SizedBox(height: 8),
                              const Text(
                                'تم إغلاق نافذة الرمز. اضغط لإعادة فتحها.',
                                style: TextStyle(
                                  color: Color(0xff6B7280),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            FilledButton(
                              onPressed: _gateSubmitting
                                  ? null
                                  : () {
                                      unawaited(
                                        _maybePromptForVerifyGate(force: true),
                                      );
                                    },
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF1E2A78),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                'فتح نافذة إدخال الرمز',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (statusNorm ==
                        CleaningBookingStatus
                            .awaitingWorkerStartConfirmation) ...[
                      const SizedBox(height: 12),
                      _card(
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'تم تأكيد رمز الأمان',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xff1F2937),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'بانتظار مقدم الخدمة لتأكيد بدء العمل. لا تحتاج إلى إدخال رمز آخر.',
                              style: TextStyle(
                                color: Color(0xff6B7280),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (statusNorm ==
                        CleaningBookingStatus.awaitingCustomerCompletion) ...[
                      const SizedBox(height: 12),
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'تأكيد إكمال العمل',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xff1F2937),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'أبلغ مقدم الخدمة عن انتهاء العمل. يمكنك تأكيد الإكمال أو الإبلاغ بأن العمل لم يكتمل، أو طلب وقت إضافي.',
                              style: TextStyle(
                                color: Color(0xff6B7280),
                                fontSize: 13,
                              ),
                            ),
                            if (_completionSheetDismissed) ...[
                              const SizedBox(height: 8),
                              const Text(
                                'تم إغلاق نافذة القرار. اضغط لإعادة فتحها.',
                                style: TextStyle(
                                  color: Color(0xff6B7280),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            if (_gateError != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _gateError!,
                                style: const TextStyle(
                                  color: Color(0xffDC2626),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: _gateSubmitting
                                  ? null
                                  : () {
                                      unawaited(
                                        _openCompletionSheet(force: true),
                                      );
                                    },
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF0CBBC7),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text(
                                'فتح نافذة اتخاذ القرار',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (statusNorm ==
                        CleaningBookingStatus.timeExtensionRequested) ...[
                      const SizedBox(height: 12),
                      _card(
                        child: const Row(
                          children: [
                            Icon(Icons.schedule, color: Color(0xff1E2A78)),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'تم إرسال طلب تمديد الوقت. سيتم إشعارك عند تحديث الحالة.',
                                style: TextStyle(
                                  color: Color(0xff374151),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    ClServiceSectionCardWidget(
                      step: 1,
                      showStepBadge: false,
                      title: 'وقت و تاريخ الخدمة',
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ClServiceDayPreviewCardWidget(
                                  dayAr: _dayLabel(order.scheduledDate),
                                  dayDate: _dayDateEnLabel(order.scheduledDate),
                                ),
                              ),
                              const SizedBox(width: 10),
                              FilledButton(
                                onPressed: editLocked
                                    ? null
                                    : () => _goToReschedule(order),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E2A78),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: AppText.bodyMedium(
                                  'تغيير اليوم',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsetsDirectional.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F7F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText.bodyMedium(
                                  'مدة الخدمة',
                                  color: const Color(0xFF656B78),
                                  fontWeight: FontWeight.w700,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClServiceTimePickerFieldWidget(
                                        title: 'من',
                                        controller: _fromTimeController,
                                        onTap: editLocked
                                            ? () {}
                                            : () => _goToReschedule(order),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ClServiceTimePickerFieldWidget(
                                        title: 'إلى',
                                        controller: _toTimeController,
                                        onTap: editLocked
                                            ? () {}
                                            : () => _goToReschedule(order),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: editLocked
                                  ? null
                                  : () => _goToReschedule(order),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: const Color(0xffE5E7EB),
                                foregroundColor: const Color(0xff1E2A78),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                editLocked
                                    ? 'تغيير الموعد غير متاح حالياً'
                                    : 'تغيير موعد الخدمة',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClServiceAddressSectionWidget(
                      locationName: order.locationName ?? 'المنزل',
                      address: order.propertyDetails?.address ?? '-',
                      onChangeTap: editLocked
                          ? null
                          : () => _changeAddress(order),
                    ),
                    const SizedBox(height: 12),
                    if (order.addressLatitude != null &&
                        order.addressLongitude != null) ...[
                      CleaningWorkerTrackingMap(
                        customerLatLng: LatLng(
                          order.addressLatitude!,
                          order.addressLongitude!,
                        ),
                        workerLatLng:
                            (_workerLiveLatitude != null &&
                                _workerLiveLongitude != null)
                            ? LatLng(
                                _workerLiveLatitude!,
                                _workerLiveLongitude!,
                              )
                            : null,
                        bookingStatus: statusNorm,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (!order.isMultiWorkerTeam) ...[
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      order.worker?.avatarUrl == null
                                      ? null
                                      : NetworkImage(order.worker!.avatarUrl!),
                                  child: order.worker?.avatarUrl == null
                                      ? const Icon(Icons.person, size: 20)
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order.worker?.name ?? 'مقدم الخدمة',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xff1F2937),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '⭐ ${order.worker?.averageRating?.toStringAsFixed(1) ?? '-'} • مقدم الخدمة',
                                        style: const TextStyle(
                                          color: Color(0xff6B7280),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () => _callWorker(order.worker?.phone),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: const Color(0xffF3F4F6),
                                      borderRadius: BorderRadius.circular(19),
                                    ),
                                    child: const Icon(
                                      Icons.call,
                                      color: Color(0xff111827),
                                      size: 19,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (order.startedTravelAt != null &&
                                order.arrivedAt == null) ...[
                              const SizedBox(height: 10),
                              const Text(
                                'مقدم الخدمة في الطريق إلى موقعك.',
                                style: TextStyle(
                                  color: Color(0xff0CBBC7),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                            if (_workerLiveLatitude != null &&
                                _workerLiveLongitude != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'تم تحديث الموقع المباشر لمقدم الخدمة',
                                style: const TextStyle(
                                  color: Color(0xff6B7280),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ملخص الطلب',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xff1F2937),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _SummaryRow(
                            title: 'تكلفة الخدمة',
                            value:
                                '${(order.basePrice ?? 0).formatWithComma()} ل.س',
                          ),
                          const SizedBox(height: 6),
                          _SummaryRow(
                            title: 'رسوم التنقل',
                            value:
                                '${(order.travelFee ?? 0).formatWithComma()} ل.س',
                          ),
                          if ((order.addonsTotal ?? 0) > 0) ...[
                            const SizedBox(height: 6),
                            _SummaryRow(
                              title: 'إضافات',
                              value:
                                  '${(order.addonsTotal ?? 0).formatWithComma()} ل.س',
                            ),
                          ],
                          const SizedBox(height: 10),
                          const Divider(color: Color(0xffE5E7EB)),
                          const SizedBox(height: 10),
                          _SummaryRow(
                            title: 'الإجمالي النهائي',
                            value:
                                '${(order.totalPrice ?? 0).formatWithComma()} ل.س',
                            isTotal: true,
                          ),
                          if (order.isPricingFinal == false) ...[
                            const SizedBox(height: 12),
                            const _ProvisionalPricingNotice(),
                          ],
                        ],
                      ),
                    ),
                    if (canCancel) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => _cancelOrder(order),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xffFEE2E2),
                            foregroundColor: const Color(0xffDC2626),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xffEF4444)),
                            ),
                          ),
                          child: const Text(
                            'إلغاء الطلب',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProvisionalPricingNotice extends StatelessWidget {
  const _ProvisionalPricingNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF3D6A1)),
      ),
      child: AppText.bodySmall(
        'السعر المعروض تقديري وغير نهائي، وسيتم تأكيد السعر النهائي بعد قبول مقدم الخدمة للطلب.',
        color: const Color(0xFF8A5A12),
        fontWeight: FontWeight.w600,
        textAlign: TextAlign.right,
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.title,
    required this.value,
    this.isTotal = false,
  });

  final String title;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final color = isTotal ? const Color(0xff1E2A78) : const Color(0xff374151);
    final weight = isTotal ? FontWeight.w900 : FontWeight.w600;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(color: color, fontWeight: weight),
        ),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: weight),
        ),
      ],
    );
  }
}
