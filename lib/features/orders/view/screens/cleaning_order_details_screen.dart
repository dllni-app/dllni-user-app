import 'package:dllni_user_app/core/themes/shared_platform_colors.dart';
import 'package:dllni_user_app/core/themes/v7_artwork.dart';
import 'package:dllni_user_app/core/widgets/v7_spot_state.dart';
import '../widgets/v7_order_detail_components.dart';
import '../widgets/v7_order_progress_and_tasks.dart';
import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/extensions/extentions.dart';
import 'package:dllni_user_app/core/extensions/num_extensions.dart';
import 'package:dllni_user_app/core/realtime/cleaning_booking_pusher_service.dart';
import 'package:dllni_user_app/core/realtime/cleaning_gate_session_store.dart';
import 'package:dllni_user_app/core/realtime/cleaning_global_verification_gate_coordinator.dart';
import 'package:dllni_user_app/core/realtime/cleaning_realtime_contract.dart';
import 'package:dllni_user_app/core/realtime/cleaning_tracking_session_bus.dart';
import 'package:dllni_user_app/core/realtime/pusher_manager.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/cleaning_date_time_ui_format.dart';
import '../../../../core/utils/cleaning_schedule_date_time_logic.dart';
import '../../../cl_main/domain/usecases/create_cleaning_order_use_case.dart';
import '../../../cl_main/view/widgets/cl_cleaning_extras_section_widget.dart';
import '../../../profile/domain/models/address_list_item.dart';
import '../../data/models/cleaning_booking_schedule_model.dart';
import '../../data/models/cleaning_booking_status.dart';
import '../../data/models/cleaning_orders_api_models.dart';
import '../../data/source/orders_remote_data_source.dart';
import '../../data/source/cleaning_session_remote_data_source.dart';
import '../../domain/usecases/cancel_cleaning_order_use_case.dart';
import '../../domain/usecases/confirm_cleaning_completion_use_case.dart';
import '../../domain/usecases/extend_cleaning_completion_time_use_case.dart';
import '../../domain/usecases/fetch_cleaning_order_details_use_case.dart';
import '../../domain/usecases/fetch_cleaning_worker_profile_use_case.dart';
import '../../domain/usecases/patch_cleaning_room_assignments_use_case.dart';
import '../../domain/usecases/reject_cleaning_completion_use_case.dart';
import '../helpers/cleaning_event_assistance_helper.dart';
import '../helpers/cleaning_extension_decision_presenter.dart';
import '../helpers/cleaning_lifecycle_error_mapper.dart';
import '../helpers/cleaning_order_polling_equality.dart';
import '../helpers/cleaning_order_realtime_policy.dart';
import '../helpers/cleaning_rebook_policy.dart';
import '../helpers/cleaning_worker_rating_gate.dart';
import '../manager/bloc/orders_bloc.dart';
import '../widgets/cleaning_accepted_workers_section_widget.dart';
import '../widgets/cleaning_cancel_reason_dialog.dart';
import '../widgets/cleaning_completion_decision_sheet.dart';
import '../widgets/cleaning_preferred_worker_card_widget.dart';
import '../widgets/cleaning_open_time_live_card.dart';
import '../widgets/cleaning_recurring_schedule_launcher_widget.dart';
import '../widgets/cleaning_room_assignments_section_widget.dart';
import '../widgets/cleaning_schedule_change_resolution_card.dart';
import '../widgets/cleaning_team_search_banner_widget.dart';
import '../widgets/cleaning_last_hour_team_decision_card.dart';
import '../widgets/cleaning_lifecycle_timeline_widget.dart';
import '../widgets/cleaning_worker_tracking_map.dart';
import 'cleaning_order_problem_report_screen.dart';
import 'cleaning_order_reschedule_screen.dart';
import 'cleaning_order_sos_screen.dart';
import 'multi_day_cleaning_order_details_screen.dart';
import 'cleaning_worker_rating_screen.dart';

class CleaningOrderDetailsArgs {
  final int orderId;

  const CleaningOrderDetailsArgs({required this.orderId});
}

@AutoRoutePage(path: '/cleaning-order-details')
class CleaningOrderDetailsScreen extends StatefulWidget {
  final CleaningOrderDetailsArgs args;

  const CleaningOrderDetailsScreen({super.key, required this.args});

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
  bool _liveWorkerTravelling = false;

  String? _gateError;
  bool _gateSubmitting = false;
  bool _completionSheetDismissed = false;
  bool _completionSheetOpen = false;
  bool _realtimeAuthWarningShown = false;
  bool _reopenCompletionAfterRefresh = false;
  bool _isRebooking = false;
  bool _isPatchingRoomAssignments = false;
  bool _isLastHourDecisionSubmitting = false;
  Timer? _detailsFallbackRefreshDebounce;
  Timer? _detailsPollTimer;
  bool _isDetailsFetchInFlight = false;
  CleaningWorkerAcceptanceModel? _liveWorkerAcceptance;
  bool _extensionRejectedDialogOpen = false;

  @override
  Widget build(BuildContext context) {
    final order = _order;
    if (_isLoading) return const V7OrderLoadingView();
    if (_loadError != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F7F9),
        appBar: AppBar(
          title: const Text('تفاصيل الطلب'),
          backgroundColor: Colors.white,
        ),
        body: V7SpotState(
          asset: V7Artwork.offline,
          title: 'تعذر تحميل الطلب',
          description: _loadError!,
          actionLabel: 'إعادة المحاولة',
          onAction: () => _fetchDetails(showLoading: true),
        ),
      );
    }
    if (order == null)
      return const V7OrderLoadingView(message: 'لا تتوفر تفاصيل هذا الطلب');

    final status = _normStatus(order.status);
    final terminal =
        status == CleaningBookingStatus.completed ||
        status == CleaningBookingStatus.cancelled;
    final liveAcceptance = _effectiveWorkerAcceptance(order);
    final searching = _isSearchingForWorkers(order, liveAcceptance);
    final workerCount =
        liveAcceptance?.required ??
        order.numberOfWorkers ??
        (order.isMultiWorkerTeam ? null : 1);
    final acceptedCount =
        liveAcceptance?.accepted ??
        (order.isMultiWorkerTeam
            ? order.acceptedWorkerAssignments.length
            : ((order.workerId != null || order.worker != null) ? 1 : 0));
    final leadTime = CleaningRebookPolicy.evaluateLeadTime(
      scheduledDate: order.scheduledDate,
      scheduledTime: order.scheduledTime,
    );
    final hiddenEdit =
        _blocksReschedule(order) ||
        _isRebooking ||
        leadTime.isPastScheduledTime;
    final editLocked =
        _blocksReschedule(order) || _isRebooking || !leadTime.allowed;
    final primary = cleaningLifecyclePrimaryAction(order.status);
    final statusLabel = cleaningOrderStatusLabelAr(
      order.status,
      startedTravelAt: order.startedTravelAt,
      arrivedAt: order.arrivedAt,
      forceTravelling: _liveWorkerTravelling,
    );
    final tone = switch (status) {
      CleaningBookingStatus.completed => V7OrderTone.success,
      CleaningBookingStatus.cancelled => V7OrderTone.danger,
      CleaningBookingStatus.timeExtensionRequested => V7OrderTone.warning,
      CleaningBookingStatus.underDispute => V7OrderTone.warning,
      _ => V7OrderTone.info,
    };
    final message = switch (status) {
      CleaningBookingStatus.pending =>
        'تم استلام طلبك، وسنخبرك عندما يقبل أحد مقدمي الخدمة.',
      CleaningBookingStatus.workerAssigned =>
        'تم قبول الطلب. يمكنك متابعة التفاصيل والتواصل مع مقدم الخدمة.',
      CleaningBookingStatus.awaitingStartVerification =>
        'العامل جاهز للبدء. اتبع خطوة تأكيد رمز الأمان عند ظهوره.',
      CleaningBookingStatus.awaitingWorkerStartConfirmation =>
        'تم تأكيد رمز الأمان. بانتظار بدء الخدمة.',
      CleaningBookingStatus.inProgress =>
        'الخدمة قيد التنفيذ. يمكنك متابعة الطلب وطلب المساعدة عند الحاجة.',
      CleaningBookingStatus.awaitingCustomerCompletion =>
        'أبلغ مقدم الخدمة بانتهاء العمل. راجع الخدمة لتأكيد الإكمال.',
      CleaningBookingStatus.timeExtensionRequested =>
        'تم طلب وقت إضافي. سنخبرك عندما تتوفر نتيجة الطلب.',
      CleaningBookingStatus.underDispute =>
        'تتم مراجعة المشكلة التي أبلغت عنها. تابع تحديثات الطلب.',
      CleaningBookingStatus.completed =>
        'اكتملت الخدمة، شكراً لاستخدام ع الندهة.',
      CleaningBookingStatus.cancelled => 'تم إلغاء هذا الطلب.',
      _ => 'تابع حالة طلبك وتفاصيل الخدمة هنا.',
    };

    final sections = <Widget>[
      if (_isRebooking)
        const V7OrderStatusHero(
          title: 'جارٍ تحديث الطلب',
          statusLabel: 'قيد التحديث',
          message: 'انتظر قليلاً حتى تظهر التفاصيل الجديدة.',
          icon: Icons.sync,
        ),
      V7OrderStatusHero(
        title: _serviceLabel(order),
        statusLabel: statusLabel,
        reference: _bookingLabel(order),
        message: message,
        tone: tone,
        icon: status == CleaningBookingStatus.completed
            ? Icons.task_alt_rounded
            : status == CleaningBookingStatus.cancelled
            ? Icons.event_busy_outlined
            : Icons.cleaning_services_outlined,
      ),
      V7OrderLifecyclePanel(order: order),
      if (searching)
        V7OrderPanel(
          title: 'جارٍ إيجاد مقدم خدمة',
          subtitle: 'سنرسل لك إشعاراً عند قبول الطلب.',
          child: (acceptedCount > 0 && workerCount != null)
              ? V7OrderInfoRow(
                  label: 'العمال الذين قبلوا',
                  value: '$acceptedCount من $workerCount',
                )
              : const Text(
                  'طلبك قيد المتابعة.',
                  style: TextStyle(color: SharedPlatformColors.muted),
                ),
        ),
      if (searching &&
          _showPreferredWorkerFallbackBanner(order, liveAcceptance))
        const CleaningPreferredWorkerFallbackBannerWidget(),
      if (searching &&
          (order.assignmentMode ?? '').toLowerCase() == 'preferred_worker' &&
          order.preferredWorker != null)
        CleaningPreferredWorkerCardWidget(
          worker: order.preferredWorker!,
          onCallWorker: _callWorker,
        ),
      if (order.lastHourTeamDecision?['required'] == true)
        CleaningLastHourTeamDecisionCard(
          decision: order.lastHourTeamDecision!,
          isSubmitting: _isLastHourDecisionSubmitting,
          onChoose: _submitLastHourDecision,
        ),
      if (order.scheduleChangeRequest != null)
        CleaningScheduleChangeResolutionCard(
          change: order.scheduleChangeRequest!,
          requiredWorkers: order.numberOfWorkers ?? 1,
          onResolved: () => _fetchDetails(showLoading: false),
        ),
      if (_gateError != null)
        V7OrderPanel(
          title: 'تنبيه بخصوص الطلب',
          child: Text(
            _gateError!,
            style: const TextStyle(color: Color(0xFFB42318)),
          ),
        ),
      if (status == CleaningBookingStatus.awaitingCustomerCompletion)
        V7OrderPanel(
          title: 'مراجعة إكمال الخدمة',
          subtitle: 'راجع نتيجة العمل قبل تأكيد إنهائه.',
          child: FilledButton(
            onPressed: _gateSubmitting
                ? null
                : () => unawaited(_openCompletionSheet(force: true)),
            child: const Text('مراجعة الخدمة'),
          ),
        ),
      if (status == CleaningBookingStatus.awaitingWorkerStartConfirmation)
        const V7OrderPanel(
          title: 'التحقق من بدء العمل',
          child: Text(
            'تم تأكيد رمز الأمان. بانتظار بدء مقدم الخدمة.',
            style: TextStyle(color: SharedPlatformColors.muted),
          ),
        ),
      V7OrderServicesPanel(order: order),
      V7OrderPanel(
        title: 'موعد الخدمة وموقعها',
        leading: const Icon(
          Icons.event_available_outlined,
          color: SharedPlatformColors.cleaning,
          size: 26,
        ),
        trailing: hiddenEdit
            ? null
            : TextButton(
                onPressed: editLocked
                    ? () => _showLeadTimeLockedMessage(leadTime)
                    : () => _goToReschedule(order),
                child: Text(editLocked ? 'التعديل غير متاح' : 'تعديل'),
              ),
        child: Column(
          children: [
            V7OrderInfoRow(
              label: 'التاريخ',
              value: CleaningDateTimeUiFormat.dateFromApiDate(
                order.scheduledDate,
              ),
            ),
            V7OrderInfoRow(
              label: 'الوقت',
              value: CleaningDateTimeUiFormat.timeRange(
                order.scheduledTime ?? '',
                _orderEndTime(order) ?? '',
              ),
            ),
            V7OrderInfoRow(
              label: 'المكان',
              value: order.locationName ?? 'عنوان الخدمة',
            ),
            V7OrderInfoRow(
              label: 'العنوان',
              value: order.propertyDetails?.address ?? 'غير محدد',
            ),
            if (!hiddenEdit)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: editLocked
                      ? () => _showLeadTimeLockedMessage(leadTime)
                      : () => _changeAddress(order),
                  icon: const Icon(Icons.location_on_outlined),
                  label: const Text('تعديل العنوان'),
                ),
              ),
          ],
        ),
      ),
      if (order.worker != null && !order.isMultiWorkerTeam)
        V7OrderWorkerPanel(
          name: order.worker?.name ?? 'مقدم الخدمة',
          avatarUrl: order.worker?.avatarUrl,
          rating: order.worker?.averageRating,
          onCall: (order.worker?.phone?.trim().isNotEmpty ?? false)
              ? () => _callWorker(order.worker?.phone)
              : null,
        ),
      if (order.isMultiWorkerTeam && order.acceptedWorkerAssignments.isNotEmpty)
        CleaningAcceptedWorkersSectionWidget(
          assignments: order.acceptedWorkerAssignments,
          onCallWorker: _callWorker,
        ),
      if ((order.roomAssignments ?? const []).isNotEmpty)
        CleaningRoomAssignmentsSectionWidget(
          roomAssignments: order.roomAssignments!,
          acceptedWorkers: order.acceptedWorkerAssignments,
          isEditable: _canEditRoomAssignments(order),
          isSaving: _isPatchingRoomAssignments,
          onAssignRoom: _assignRoom,
        ),
      if (CleaningEventAssistanceHelper.isEventAssistance(order.propertyType))
        V7OrderPanel(
          title: 'المناسبة',
          child: Column(
            children: [
              V7OrderInfoRow(
                label: 'النوع',
                value: CleaningEventAssistanceHelper.eventTypeLabelAr(
                  order.propertyDetails?.eventType,
                ),
              ),
              V7OrderInfoRow(
                label: 'عدد الضيوف',
                value: (order.propertyDetails?.guestCount ?? '-').toString(),
              ),
              OutlinedButton(
                onPressed: () async {
                  await Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => MultiDayCleaningOrderDetailsScreen(
                        orderId: _activeOrderId,
                      ),
                    ),
                  );
                  if (mounted) await _fetchDetails(showLoading: false);
                },
                child: const Text('عرض جلسات المناسبة'),
              ),
            ],
          ),
        )
      else
        CleaningRecurringScheduleLauncherWidget(
          orderId: _activeOrderId,
          onReturn: () => _fetchDetails(showLoading: false),
        ),
      if (order.addressLatitude != null && order.addressLongitude != null)
        V7OrderPanel(
          title: 'موقع الخدمة',
          child: CleaningWorkerTrackingMap(
            customerLatLng: LatLng(
              order.addressLatitude!,
              order.addressLongitude!,
            ),
            workerLatLng:
                _workerLiveLatitude != null && _workerLiveLongitude != null
                ? LatLng(_workerLiveLatitude!, _workerLiveLongitude!)
                : null,
            bookingStatus: status,
            hasStartedTravel:
                order.startedTravelAt != null && order.arrivedAt == null,
          ),
        ),
      V7OrderPricePanel(
        basePrice: order.basePrice?.formatMoney(),
        travelFee: order.travelFee?.formatMoney(),
        addonsTotal: (order.addonsTotal ?? 0) > 0
            ? order.addonsTotal?.formatMoney()
            : null,
        total: order.totalPrice?.formatMoney(),
        finalPrice: order.isPricingFinal != false,
      ),
      if (order.materials.isNotEmpty ||
          order.specialServices.isNotEmpty ||
          order.openTime != null)
        V7OrderPanel(
          title: 'الخدمات والمواد الإضافية',
          child: CleaningOrderExtrasDetailsSection(
            materials: order.materials,
            specialServices: order.specialServices,
            openTime: order.openTime,
            currency: order.openTime?.currency ?? 'SYP',
          ),
        ),
      if (order.openTime != null)
        CleaningOpenTimeLiveCard(
          orderId: order.id ?? _activeOrderId,
          initialValue: order.openTime!,
        ),
      if (!terminal && !_blocksCancel(order))
        Align(
          alignment: Alignment.center,
          child: TextButton.icon(
            onPressed: () => _cancelOrder(order),
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('إلغاء الطلب'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFB42318),
            ),
          ),
        ),
    ];

    return V7OrderDetailScaffold(
      heading: 'تفاصيل الطلب',
      sections: sections,
      onRefresh: () =>
          _fetchDetails(showLoading: false, triggerGatePrompts: true),
      helpAction: terminal
          ? null
          : IconButton(
              tooltip: 'المساعدة',
              icon: const Icon(Icons.support_agent_outlined),
              onPressed: () => context.pushRoute(
                '/cleaning-order-sos',
                arguments: CleaningOrderSosArgs(orderId: _activeOrderId),
              ),
            ),
      primaryAction: primary.kind == CleaningLifecycleActionKind.none
          ? null
          : _buildLifecycleActionBar(
              order: order,
              action: primary,
              isTerminalStatus: terminal,
            ),
    );
  }

  String? _orderEndTime(CleaningOrderDetailModel order) {
    final start = _resolveStartDateTime(order);
    if (start == null) return null;
    return CleaningScheduleDateTimeLogic.formatTimeApi(
      start.add(Duration(minutes: (_resolveHours(order) * 60).round())),
    );
  }

  Widget _buildLifecycleActionBar({
    required CleaningOrderDetailModel order,
    required CleaningLifecycleActionSpec action,
    required bool isTerminalStatus,
  }) {
    return Row(
      children: [
        if (!isTerminalStatus) ...[
          SizedBox(
            width: 50,
            height: 50,
            child: OutlinedButton(
              onPressed: () => context.pushRoute(
                '/cleaning-order-problem',
                arguments: CleaningOrderProblemReportArgs(
                  order: order.toCleaningOrderModel(),
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: SharedPlatformColors.primary,
                side: const BorderSide(color: Color(0xFFE0E5EC)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Icon(Icons.support_agent_outlined, size: 22),
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _handleLifecyclePrimaryAction(order, action),
            icon: Icon(action.icon, size: 19),
            label: Text(
              action.label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              foregroundColor: Colors.white,
              backgroundColor: SharedPlatformColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLifecyclePrimaryAction(
    CleaningOrderDetailModel order,
    CleaningLifecycleActionSpec action,
  ) async {
    switch (action.kind) {
      case CleaningLifecycleActionKind.verifyStart:
        final coordinator =
            CleaningGlobalVerificationGateCoordinator.activeInstance;
        if (coordinator != null) {
          await coordinator.requestStartVerificationPrompt(
            orderId: order.id ?? _activeOrderId,
            force: true,
          );
        } else {
          await _fetchDetails(showLoading: false, triggerGatePrompts: true);
        }
        return;
      case CleaningLifecycleActionKind.completionDecision:
        await _openCompletionSheet(force: true);
        return;
      case CleaningLifecycleActionKind.rateService:
        await _navigateToRating(order, workerId: order.workerId);
        return;
      case CleaningLifecycleActionKind.refreshSearch:
      case CleaningLifecycleActionKind.trackTeam:
      case CleaningLifecycleActionKind.waitingForWorkerStart:
      case CleaningLifecycleActionKind.followProgress:
      case CleaningLifecycleActionKind.waitingExtension:
        await _fetchDetails(showLoading: false, triggerGatePrompts: true);
        return;
      case CleaningLifecycleActionKind.none:
        return;
    }
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

  void _applyWorkerLocation(Map<String, dynamic> payload) {
    final location = CleaningRealtimeContract.parseLocation(payload);
    if (location == null || !mounted) return;
    setState(() {
      _workerLiveLatitude = location.latitude;
      _workerLiveLongitude = location.longitude;
      // Live location implies the worker is en route until arrival is confirmed.
      if (_order?.arrivedAt == null || _order!.arrivedAt!.trim().isEmpty) {
        _liveWorkerTravelling = true;
      }
    });
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

  bool _blocksCancel(CleaningOrderDetailModel order) {
    final s = _normStatus(order.status);
    return s == CleaningBookingStatus.awaitingStartVerification ||
        s == CleaningBookingStatus.awaitingWorkerStartConfirmation ||
        s == CleaningBookingStatus.awaitingCustomerCompletion ||
        s == CleaningBookingStatus.inProgress ||
        s == CleaningBookingStatus.timeExtensionRequested ||
        s == CleaningBookingStatus.underDispute;
  }

  bool _blocksReschedule(CleaningOrderDetailModel order) {
    final s = _normStatus(order.status);
    return s == CleaningBookingStatus.awaitingStartVerification ||
        s == CleaningBookingStatus.awaitingWorkerStartConfirmation ||
        s == CleaningBookingStatus.awaitingCustomerCompletion ||
        s == CleaningBookingStatus.inProgress ||
        s == CleaningBookingStatus.timeExtensionRequested;
  }

  String _bookingLabel(CleaningOrderDetailModel order) {
    final bookingNumber = order.bookingNumber;
    if (bookingNumber == null || bookingNumber.isEmpty) {
      return '#${order.id ?? '-'}';
    }
    return '#$bookingNumber';
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

  Future<void> _cancelOrder(CleaningOrderDetailModel order) async {
    if (_blocksCancel(order)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يمكن إلغاء الطلب في هذه المرحلة من التنفيذ.'),
        ),
      );
      return;
    }
    final orderId = order.id;
    final OrdersBloc ordersBloc = getIt<OrdersBloc>();
    if (orderId == null) return;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          CleaningCancelReasonDialog(orderId: orderId, bloc: ordersBloc),
    );
    if (result == true && mounted) {
      _gateSession.suppressStartVerification(
        orderId,
        CleaningGateSuppressionReason.cancelled,
      );
      Navigator.of(context).pop(true);
    }
  }

  bool _canEditRoomAssignments(CleaningOrderDetailModel order) {
    final s = _normStatus(order.status);
    return s == CleaningBookingStatus.pending ||
        s == CleaningBookingStatus.workerAssigned;
  }

  Future<void> _changeAddress(CleaningOrderDetailModel order) async {
    if (_isRebooking || _blocksReschedule(order)) return;
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

  CleaningWorkerAcceptanceModel? _effectiveWorkerAcceptance(
    CleaningOrderDetailModel order,
  ) {
    return _liveWorkerAcceptance ?? order.workerAcceptance;
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

  Future<void> _submitLastHourDecision(String choice, int? workerId) async {
    if (_isLastHourDecisionSubmitting) return;
    setState(() => _isLastHourDecisionSubmitting = true);
    try {
      await getIt<OrdersRemoteDataSource>().submitLastHourTeamDecision(
        orderId: _activeOrderId,
        choice: choice,
        workerId: workerId,
      );
      if (!mounted) return;
      await _fetchDetails(showLoading: false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث مهام فريق التنظيف بنجاح')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر حفظ القرار، حاول مجدداً.')),
      );
    } finally {
      if (mounted) setState(() => _isLastHourDecisionSubmitting = false);
    }
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
              _syncLiveTravellingFromOrder(updatedOrder);
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
      unawaited(_maybePromptForCompletionGate());
      final order = _order;
      final coordinator =
          CleaningGlobalVerificationGateCoordinator.activeInstance;
      if (order != null &&
          coordinator != null &&
          _normStatus(order.status) ==
              CleaningBookingStatus.awaitingStartVerification) {
        final orderId = order.id ?? _activeOrderId;
        unawaited(coordinator.requestStartVerificationPrompt(orderId: orderId));
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
          _syncLiveTravellingFromOrder(updatedOrder);
        });
      }
      return result.extendedTimeRanges;
    });
  }

  Future<void> _goToReschedule(CleaningOrderDetailModel order) async {
    if (_blocksReschedule(order) || _isRebooking) {
      return;
    }
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

  int? _intFromDynamic(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
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

  bool _showPreferredWorkerFallbackBanner(
    CleaningOrderDetailModel order,
    CleaningWorkerAcceptanceModel? acceptance,
  ) {
    return order.convertedFromPreferredWorker &&
        (order.assignmentMode ?? '').toLowerCase() == 'open_count' &&
        _isSearchingForWorkers(order, acceptance);
  }

  bool _isStartVerificationExpired(CleaningOrderDetailModel order) {
    return isCleaningBookingScheduledDateBeforeToday(
      scheduledDate: order.scheduledDate,
    );
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

  void _showLeadTimeLockedMessage(CleaningRebookGuardResult leadTimeCheck) {
    if (!mounted) return;
    final message = leadTimeCheck.allowed
        ? 'تغيير الموعد أو العنوان غير متاح في هذه المرحلة.'
        : _leadTimeLockMessage(leadTimeCheck.remaining);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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

  Future<void> _navigateToRating(
    CleaningOrderDetailModel order, {
    required int? workerId,
    int? sessionId,
  }) async {
    if (!mounted || order.id == null) return;
    final ratingTarget = await _resolveSessionRatingTarget(
      order.id!,
      preferredWorkerId: workerId ?? order.workerId,
    );
    if (!mounted) return;
    final resolvedWorkerId =
        workerId ?? ratingTarget.workerId ?? order.workerId;
    final resolvedSessionId = sessionId ?? ratingTarget.sessionId;
    final workerProfile = await resolveCleaningWorkerProfileForRating(
      workerId: resolvedWorkerId,
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
      sessionId: resolvedSessionId,
      workerProfile: workerProfile,
    );
    context.pushRoute('/cleaning-worker-rating', arguments: ratingArgs);
  }

  String _normStatus(String? status) => (status ?? '').toLowerCase();

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
      final coordinator =
          CleaningGlobalVerificationGateCoordinator.activeInstance;
      if (coordinator != null) {
        unawaited(
          coordinator.requestStartVerificationPrompt(
            orderId: _activeOrderId,
            force: true,
          ),
        );
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

    if (normalizedEvent == CleaningRealtimeContract.completionDecisionMade) {
      final unwrapped = CleaningRealtimeContract.unwrapPayload(payload);
      final decision = CleaningRealtimeContract.extractDecision(unwrapped);
      if (decision == 'extension_rejected' ||
          decision == 'extension_accepted' ||
          decision == 'extension_requested') {
        _reopenCompletionAfterRefresh = false;
        _completionSheetDismissed = false;
        _gateSession.clearCompletionAwaitingCycle(_activeOrderId);
      }
    }

    final extensionRejectedDialogData =
        CleaningExtensionDecisionPresenter.resolveRejectedDialog(
          normalizedEvent: normalizedEvent,
          payload: payload,
          currentStatus: _order?.status,
          handledWarningIds: _gateSession.handledExtensionRejectedWarningIds,
        );
    if (extensionRejectedDialogData != null) {
      final warningId = extensionRejectedDialogData.warningId;
      final shouldShowDialog =
          warningId == null ||
          _gateSession.markExtensionRejectedHandled(warningId);
      if (shouldShowDialog) {
        unawaited(
          _showExtensionRejectedDialogThenRate(
            extensionRejectedDialogData.message,
          ),
        );
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

  Future<void> _showExtensionRejectedDialogThenRate(String message) async {
    if (!mounted || _extensionRejectedDialogOpen) {
      return;
    }
    _extensionRejectedDialogOpen = true;
    try {
      await showDialog<void>(
        context: context,
        useRootNavigator: true,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'تم رفض طلب تمديد الوقت',
              textAlign: TextAlign.center,
            ),
            content: Text(message, textAlign: TextAlign.center),
            actions: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                  child: const Text('حسناً'),
                ),
              ),
            ],
          );
        },
      );
      if (!mounted) return;
      var order = _order;
      if (order == null || order.id == null) return;
      if ((order.status ?? '').toLowerCase() !=
          CleaningBookingStatus.completed) {
        await _fetchDetails(showLoading: false);
        if (!mounted) return;
        order = _order;
        if (order == null || order.id == null) return;
      }
      final workerId =
          order.workerId ?? order.pendingCompletionRequest?.workerId;
      await _navigateToRating(order, workerId: workerId);
    } finally {
      _extensionRejectedDialogOpen = false;
    }
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
    final completionRequest = order.pendingCompletionRequest;
    if (completionRequest == null) return;
    final ratingTarget = await _resolveSessionRatingTarget(
      orderId,
      preferredWorkerId: completionRequest.workerId ?? order.workerId,
    );
    if (!mounted) return;
    _completionSheetOpen = true;
    final decision = await CleaningCompletionDecisionSheet.show(
      context,
      useRootNavigator: true,
      completionRequest: completionRequest,
      cleaningOrder: order,
      onConfirm: () => _submitCompletionConfirm(
        order,
        completionRequest,
        sessionId: ratingTarget.sessionId,
      ),
      onReject: (reason) => _submitCompletionReject(
        order,
        completionRequest,
        reason,
        sessionId: ratingTarget.sessionId,
      ),
      onExtend: (minutes) => _submitExtendTime(
        order,
        completionRequest,
        minutes,
        sessionId: ratingTarget.sessionId,
      ),
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
        await _navigateToRating(
          updatedOrder,
          workerId:
              completionRequest.workerId ??
              ratingTarget.workerId ??
              updatedOrder.workerId,
          sessionId: ratingTarget.sessionId,
        );
      }
    }
    unawaited(_fetchDetails(showLoading: false));
  }

  void _openOrdersListFallback() {
    if (!mounted) return;
    context.pushRoute('/main', arguments: 1);
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

  double _resolveHours(CleaningOrderDetailModel order) {
    final total = order.totalHours;
    if (total != null && total > 0) return total;
    return double.tryParse(order.estimatedHours ?? '') ?? 0;
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

  String _serviceLabel(CleaningOrderDetailModel order) {
    if (order.openTime != null) return 'عامل بالساعة';
    return CleaningEventAssistanceHelper.serviceTitle(
      propertyType: order.propertyType,
      customService: order.propertyDetails?.customService,
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

  Future<({int? sessionId, int? workerId})> _resolveSessionRatingTarget(
    int orderId, {
    int? preferredWorkerId,
  }) async {
    try {
      final envelope = await getIt<CleaningSessionRemoteDataSource>()
          .fetchBookingSchedule(orderId);
      final sessions = envelope.schedule?.sessions;
      if (sessions == null || sessions.isEmpty) {
        return (sessionId: null, workerId: preferredWorkerId);
      }

      CleaningBookingSessionModel? target;
      for (final session in sessions) {
        if (session.canConfirmCompletion ||
            session.isAwaitingCustomerCompletion) {
          target = session;
          break;
        }
      }
      if (target == null) {
        for (final session in sessions.reversed) {
          if (session.isCompleted &&
              (session.canReview ||
                  session.reviewableWorkerIds.isNotEmpty ||
                  !session.hasReview)) {
            target = session;
            break;
          }
        }
      }
      target ??= sessions.last;

      final preferred = preferredWorkerId;
      if (preferred != null &&
          preferred > 0 &&
          (target.workerAssignments.any((item) => item.workerId == preferred) ||
              target.workerAssignmentState?.workerId == preferred)) {
        return (sessionId: target.id, workerId: preferred);
      }
      if (target.reviewableWorkerIds.isNotEmpty) {
        return (
          sessionId: target.id,
          workerId: target.reviewableWorkerIds.first,
        );
      }
      final stateWorkerId = target.workerAssignmentState?.workerId;
      if (stateWorkerId != null && stateWorkerId > 0) {
        return (sessionId: target.id, workerId: stateWorkerId);
      }
      const priority = <String>[
        'awaiting_customer_completion',
        'time_extension_requested',
        'completed',
        'in_progress',
        'start_approved',
        'awaiting_start_verification',
        'accepted_waiting_for_order_start',
        'accepted',
      ];
      for (final status in priority) {
        for (final assignment in target.workerAssignments) {
          if ((assignment.status ?? '').toLowerCase() != status) continue;
          final workerId = assignment.workerId;
          if (workerId != null && workerId > 0) {
            return (sessionId: target.id, workerId: workerId);
          }
        }
      }
      for (final assignment in target.workerAssignments) {
        final workerId = assignment.workerId;
        if (workerId != null && workerId > 0) {
          return (sessionId: target.id, workerId: workerId);
        }
      }

      return (sessionId: target.id, workerId: preferredWorkerId);
    } catch (_) {
      return (sessionId: null, workerId: preferredWorkerId);
    }
  }

  Future<String?> _submitCompletionConfirm(
    CleaningOrderDetailModel order,
    CleaningCompletionRequestModel completionRequest, {
    int? sessionId,
  }) async {
    final orderId = order.id;
    if (orderId == null) return 'تعذر تحديد الطلب';
    setState(() {
      _gateSubmitting = true;
      _gateError = null;
    });

    final resolvedSessionId =
        sessionId ??
        (await _resolveSessionRatingTarget(
          orderId,
          preferredWorkerId: completionRequest.workerId ?? order.workerId,
        )).sessionId;
    if (!mounted) return 'تعذر تحديث الحالة';

    if (resolvedSessionId != null) {
      try {
        await getIt<CleaningSessionRemoteDataSource>().confirmCompletion(
          orderId: orderId,
          sessionId: resolvedSessionId,
        );
        await _fetchDetails(showLoading: false);
        if (!mounted) return 'تعذر تحديث الحالة';
        setState(() {
          _gateSubmitting = false;
          _gateError = null;
        });
        return null;
      } catch (error) {
        if (!mounted) return 'تعذر تحديث الحالة';
        const errorMessage =
            'تعذر تأكيد إكمال هذه الجلسة. حدّث الطلب وتحقق من حالتها ثم حاول مرة أخرى.';
        setState(() {
          _gateSubmitting = false;
          _gateError = errorMessage;
        });
        return errorMessage;
      }
    }

    final response = await getIt<ConfirmCleaningCompletionUseCase>()(
      ConfirmCleaningCompletionParams(
        orderId: orderId,
        workerId: completionRequest.workerId,
        assignmentId: completionRequest.assignmentId,
      ),
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
    CleaningCompletionRequestModel completionRequest,
    String? reason, {
    int? sessionId,
  }) async {
    final orderId = order.id;
    if (orderId == null) return 'تعذر تحديد الطلب';
    setState(() {
      _gateSubmitting = true;
      _gateError = null;
    });

    if (sessionId != null) {
      try {
        await getIt<CleaningSessionRemoteDataSource>().rejectCompletion(
          orderId: orderId,
          sessionId: sessionId,
          reason: reason,
        );
        await _fetchDetails(showLoading: false);
        if (!mounted) return 'تعذر تحديث الحالة';
        setState(() {
          _gateSubmitting = false;
          _gateError = null;
        });
        CleaningTrackingSessionBus.requestRefresh(orderId);
        return null;
      } catch (error) {
        if (!mounted) return 'تعذر تحديث الحالة';
        const errorMessage =
            'تعذر رفض إكمال هذه الجلسة. حدّث الطلب وتحقق من حالتها ثم حاول مرة أخرى.';
        setState(() {
          _gateSubmitting = false;
          _gateError = errorMessage;
        });
        return errorMessage;
      }
    }

    final response = await getIt<RejectCleaningCompletionUseCase>()(
      RejectCleaningCompletionParams(
        orderId: orderId,
        reason: reason,
        workerId: completionRequest.workerId,
        assignmentId: completionRequest.assignmentId,
      ),
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
    CleaningCompletionRequestModel completionRequest,
    int? additionalMinutes, {
    int? sessionId,
  }) async {
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
        workerId: completionRequest.workerId,
        assignmentId: completionRequest.assignmentId,
        sessionId: sessionId,
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

  Future<void> _switchToOrder(int newOrderId, {String? successMessage}) async {
    final shouldReconnect = _activeOrderId != newOrderId;
    setState(() {
      _activeOrderId = newOrderId;
      if (shouldReconnect) {
        _workerLiveLatitude = null;
        _workerLiveLongitude = null;
        _liveWorkerTravelling = false;
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

  void _syncLiveTravellingFromOrder(CleaningOrderDetailModel order) {
    final hasArrived =
        order.arrivedAt != null && order.arrivedAt!.trim().isNotEmpty;
    final status = _normStatus(order.status);
    final leftTravelPhase =
        hasArrived ||
        status == CleaningBookingStatus.awaitingStartVerification ||
        status == CleaningBookingStatus.awaitingWorkerStartConfirmation ||
        status == CleaningBookingStatus.inProgress ||
        status == CleaningBookingStatus.awaitingCustomerCompletion ||
        status == CleaningBookingStatus.timeExtensionRequested ||
        status == CleaningBookingStatus.completed ||
        status == CleaningBookingStatus.cancelled;

    if (leftTravelPhase) {
      _liveWorkerTravelling = false;
      return;
    }

    final hasStartedTravel =
        order.startedTravelAt != null &&
        order.startedTravelAt!.trim().isNotEmpty;
    if (hasStartedTravel) {
      _liveWorkerTravelling = true;
    }
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
    _completionSheetDismissed =
        normalizedStatus == CleaningBookingStatus.awaitingCustomerCompletion &&
        _gateSession.isCompletionSuppressed(orderId);
  }
}
