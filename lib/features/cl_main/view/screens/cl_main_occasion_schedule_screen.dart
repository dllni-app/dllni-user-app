import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/models/cleaning_gender_preference.dart';
import '../../../../core/utils/cleaning_date_time_ui_format.dart';
import '../../../../core/utils/cleaning_schedule_date_time_logic.dart';
import '../../../../core/widgets/toast_component.dart';
import '../../../orders/domain/usecases/check_restaurant_coupon_use_case.dart';
import '../../../orders/view/screens/cleaning_order_details_screen.dart';
import '../../../orders/view/screens/multi_day_cleaning_order_details_screen.dart';
import '../../../profile/domain/models/address_list_item.dart';
import '../../domain/models/cleaning_assignment_mode.dart';
import '../../domain/models/cleaning_event_session.dart';
import '../../domain/repository/cl_main_repo.dart';
import '../../domain/usecases/create_cleaning_order_use_case.dart';
import '../../domain/usecases/estimate_cleaning_price_use_case.dart';
import '../../domain/usecases/get_previous_cleaning_workers_use_case.dart';
import '../data/cl_main_route_args.dart';
import '../helpers/cl_event_assignment_helper.dart';
import '../helpers/cl_previous_workers_gender_filter.dart';
import '../helpers/cl_service_schedule_time_utils.dart';
import '../manager/bloc/cl_main_bloc.dart';
import '../widgets/app_pickers.dart';
import '../widgets/cl_booking_confirmation_sheet.dart';
import '../widgets/cl_female_worker_safety_confirmation_sheet.dart';
import '../widgets/cl_service_coupon_section_widget.dart';
import '../widgets/cl_service_gender_preference_section_widget.dart';
import '../widgets/cl_service_order_summary_section_widget.dart';
import '../widgets/cl_service_previous_workers_section_widget.dart';
import '../widgets/cl_redesign_components.dart';
import '../helpers/v6_booking_quote_guard.dart';
import '../widgets/home_details_app_bar.dart';
import 'cl_worker_profile_detail_screen.dart';

@AutoRoutePage()
class ClMainOccasionScheduleScreen extends StatefulWidget {
  final ClMainOccasionScheduleArgs? args;

  const ClMainOccasionScheduleScreen({this.args, super.key});

  @override
  State<ClMainOccasionScheduleScreen> createState() =>
      _ClMainOccasionScheduleScreenState();
}

class _ClMainOccasionScheduleScreenState
    extends State<ClMainOccasionScheduleScreen> {
  final List<_EventSessionDraft> _sessions = <_EventSessionDraft>[];
  CleaningGenderPreference? _explicitGenderPreference;
  late TextEditingController _couponController;
  ClMainOccasionScheduleArgs? _routeArgs;
  ClMainBloc? _bloc;
  bool _didReadArgs = false;
  int _v7Stage = 0;
  bool _submissionRequested = false;
  bool _confirmationOpen = false;
  bool _isCheckingSafetyPolicy = false;
  bool _processingOpen = false;
  int _requestedWorkerCount = 1;
  EstimatePriceResponseModel? _currentEstimate;
  late final ValueNotifier<AddressListItem?> _selectedAddress;
  ClCouponUiStatus _couponStatus = ClCouponUiStatus.idle;
  String? _couponMessage;
  String? _appliedCouponCode;

  // Price quotes are deliberately absent until the last review step.
  EstimatePriceResponseModel? get _activeEstimate => _currentEstimate;

  double get _defaultSessionHours {
    final routedHours = _routeArgs?.hours;
    if (routedHours != null && routedHours >= 1) return routedHours;
    final fromRecommendation = _activeEstimate?.recommendation?.hours;
    if (fromRecommendation != null && fromRecommendation >= 1) {
      return fromRecommendation;
    }
    return 4;
  }

  double get _scheduleTotalHours {
    if (_sessions.isEmpty) return _defaultSessionHours;
    return _sessions.fold<double>(0, (sum, item) => sum + item.hours);
  }

  List<CleaningEventSessionInput> get _eventSessionInputs => _sessions
      .map(
        (item) => CleaningEventSessionInput(
          date: item.date,
          time: item.time,
          hours: item.hours,
        ),
      )
      .toList(growable: false);

  double get _longestSessionHours => _sessions.fold<double>(
    0,
    (longest, session) => session.hours > longest ? session.hours : longest,
  );

  int get _minimumWorkerCount =>
      resolveMinimumEventWorkersForHours(_longestSessionHours);

  int get _resolvedNumberOfWorkers => resolveEventWorkerCountForHours(
    hours: _longestSessionHours,
    requestedWorkers: _requestedWorkerCount,
  );

  bool get _isMultiDay => _sessions.length > 1;

  _EventSessionDraft? get _firstSession =>
      _sessions.isEmpty ? null : _sessions.first;

  _EventSessionDraft? get _lastSession =>
      _sessions.isEmpty ? null : _sessions.last;

  DateTime get _minimumDate => CleaningScheduleDateTimeLogic.tomorrowDate();

  @override
  Widget build(BuildContext context) {
    final args = _routeArgs;
    final bloc = _bloc;
    if (args == null || bloc == null || _sessions.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F2F2),
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    final estimate = _activeEstimate;

    return BlocProvider.value(
      value: bloc,
      child: MultiBlocListener(
        listeners: [
          BlocListener<ClMainBloc, ClMainState>(
            listenWhen: (previous, current) =>
                previous.estimatePriceStatus != current.estimatePriceStatus,
            listener: (context, state) {
              if (state.estimatePriceStatus == BlocStatus.success &&
                  state.estimatePrice != null) {
                if (_v7Stage == 2) {
                  setState(() => _currentEstimate = state.estimatePrice);
                }
              } else if (state.estimatePriceStatus == BlocStatus.failed &&
                  state.errorMessage != null &&
                  state.errorMessage!.isNotEmpty) {
                AppToast.showToast(
                  context: context,
                  message: state.errorMessage!,
                  type: ToastificationType.error,
                );
              }
            },
          ),
          BlocListener<ClMainBloc, ClMainState>(
            listenWhen: (previous, current) =>
                previous.createOrderStatus != current.createOrderStatus,
            listener: (context, state) {
              if (state.createOrderStatus == BlocStatus.failed) {
                _submissionRequested = false;
              }
              if (state.createOrderStatus == BlocStatus.loading) {
                _showOrderPreparation();
                return;
              }
              _dismissOrderPreparation();
              if (state.createOrderStatus == BlocStatus.success) {
                final orderId = state.createOrderResult?.orderId;
                if (orderId == null) {
                  AppToast.showToast(
                    context: context,
                    message:
                        'تم إنشاء الطلب، لكن تعذر فتح تفاصيله. يمكنك متابعته من السلة.',
                    type: ToastificationType.warning,
                  );
                  context.pushRouteAndRemoveUntil('/clmain');
                  return;
                }
                AppToast.showToast(
                  context: context,
                  message: _isMultiDay
                      ? 'تم إنشاء طلب المناسبة متعدد الأيام بنجاح'
                      : 'تم إنشاء الطلب بنجاح، وهو الآن قيد الانتظار',
                  type: ToastificationType.success,
                );
                if (_isMultiDay) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          MultiDayCleaningOrderDetailsScreen(orderId: orderId),
                    ),
                    (route) => route.settings.name == '/clmain',
                  );
                  return;
                }
                context.pushRouteAndRemoveUntil(
                  '/cleaning-order-details',
                  arguments: CleaningOrderDetailsArgs(orderId: orderId),
                  predicate: (route) => route.settings.name == '/clmain',
                );
              } else if (state.createOrderStatus == BlocStatus.failed) {
                final message = (state.errorMessage ?? '').trim().isNotEmpty
                    ? state.errorMessage!
                    : 'فشل إرسال طلب المناسبة';
                AppToast.showToast(
                  context: context,
                  message: message,
                  type: ToastificationType.error,
                );
              }
            },
          ),
        ],
        child: BlocBuilder<ClMainBloc, ClMainState>(
          builder: (context, state) {
            return PopScope(
              canPop: _v7Stage == 0,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop && _v7Stage > 0) {
                  setState(() => _v7Stage--);
                }
              },
              child: Scaffold(
                backgroundColor: const Color(0xFFF6F7F9),
                body: SafeArea(
                  child: Column(
                    children: [
                      HomeDetailsAppBar(
                        title: 'طلب مناسبة',
                        subtitle: 'أكمل تفاصيل مناسبتك خطوة بخطوة',
                        onBack: () {
                          if (_v7Stage > 0) {
                            setState(() => _v7Stage--);
                          } else {
                            Navigator.of(context).maybePop();
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                        child: ClRedesignStepHeader(
                          currentStep: _v7Stage + 3,
                          totalSteps: 5,
                          title: switch (_v7Stage) {
                            0 => 'أيام المناسبة',
                            1 => 'فريق الخدمة',
                            _ => 'مراجعة المناسبة',
                          },
                          subtitle: switch (_v7Stage) {
                            0 => 'حدد أيام وأوقات الخدمة.',
                            1 => 'اختر مقدم الخدمة المناسب.',
                            _ => 'تأكد من التفاصيل والتكلفة قبل إرسال الطلب.',
                          },
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsetsDirectional.only(
                            start: 20,
                            end: 20,
                          ),
                          child: Column(
                            children: [
                              if (_v7Stage == 0) ...[
                                _buildMultiDayScheduleCard(),
                              ],
                              if (_v7Stage == 1) ...[
                                ClRedesignCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const Text(
                                        'عدد العمال للمناسبة',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          color: Color(0xFF172554),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          IconButton(
                                            key: const Key(
                                              'event_workers_increase',
                                            ),
                                            onPressed:
                                                _requestedWorkerCount >=
                                                    maxEventWorkerCount
                                                ? null
                                                : () => setState(
                                                    () => _requestedWorkerCount =
                                                        _resolvedNumberOfWorkers +
                                                        1,
                                                  ),
                                            icon: const Icon(
                                              Icons.add_circle_outline,
                                            ),
                                          ),
                                          Text(
                                            '$_resolvedNumberOfWorkers',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          IconButton(
                                            key: const Key(
                                              'event_workers_decrease',
                                            ),
                                            onPressed:
                                                _requestedWorkerCount <=
                                                    _minimumWorkerCount
                                                ? null
                                                : () => setState(
                                                    () =>
                                                        _requestedWorkerCount--,
                                                  ),
                                            icon: const Icon(
                                              Icons.remove_circle_outline,
                                            ),
                                          ),
                                          const Spacer(),
                                          const Icon(
                                            Icons.groups_2_outlined,
                                            color: Color(0xFF172554),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ClServiceGenderPreferenceSectionWidget(
                                  selectedPreference: _explicitGenderPreference,
                                  onChanged: (preference) {
                                    _handleGenderPreferenceChanged(
                                      bloc,
                                      preference,
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                if (state.previousWorkersStatus ==
                                        BlocStatus.success &&
                                    filterPreviousWorkersByGender(
                                      state.previousWorkers.list,
                                      _explicitGenderPreference ??
                                          state.genderPreference,
                                    ).isNotEmpty)
                                  ClRedesignCard(
                                    child: ClServicePreviousWorkersSectionWidget(
                                      workers: filterPreviousWorkersByGender(
                                        state.previousWorkers.list,
                                        _explicitGenderPreference ??
                                            state.genderPreference,
                                      ),
                                      selectedWorkerIds:
                                          state.selectedWorkerIds,
                                      isLoading: false,
                                      errorMessage:
                                          state.previousWorkersStatus ==
                                              BlocStatus.failed
                                          ? state.errorMessage
                                          : null,
                                      onSelectWorker: (workerId) {
                                        final updatedWorkerIds = List<int>.from(
                                          state.selectedWorkerIds,
                                        );
                                        if (updatedWorkerIds.contains(
                                          workerId,
                                        )) {
                                          updatedWorkerIds.remove(workerId);
                                        } else {
                                          updatedWorkerIds.add(workerId);
                                        }
                                        bloc.add(
                                          SetPreferredWorkerEvent(
                                            workerId: workerId,
                                          ),
                                        );
                                        // Worker preference is local until final review.
                                      },
                                      onOpenWorkerProfile: (worker) {
                                        context.pushRoute(
                                          '/clworkerprofiledetail',
                                          arguments:
                                              WorkerProfileRouteArgs.fromPreviousWorker(
                                                worker,
                                              ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                              if (_v7Stage == 2) ...[
                                ClServiceCouponSectionWidget(
                                  couponController: _couponController,
                                  status: _couponStatus,
                                  message: _couponMessage,
                                  onApply: _onApplyCoupon,
                                ),
                                if (_appliedCouponCode != null) ...[
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: AlignmentDirectional.centerStart,
                                    child: AppText.bodySmall(
                                      'الكوبون المطبق: $_appliedCouponCode',
                                      color: const Color(0xFF047857),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                if (state.estimatePriceStatus ==
                                    BlocStatus.failed)
                                  ClRedesignCard(
                                    child: Column(
                                      children: [
                                        const Icon(
                                          Icons.wifi_off_outlined,
                                          color: Color(0xFFB42318),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'تعذر جلب السعر. يمكنك المحاولة مجدداً.',
                                        ),
                                        const SizedBox(height: 10),
                                        OutlinedButton.icon(
                                          onPressed: () =>
                                              _requestUpdatedEstimate(state),
                                          icon: const Icon(Icons.refresh),
                                          label: const Text(
                                            'إعادة محاولة جلب السعر',
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else if (estimate == null ||
                                    state.estimatePriceStatus ==
                                        BlocStatus.loading)
                                  const ClRedesignCard(
                                    child: Column(
                                      children: [
                                        LinearProgressIndicator(),
                                        SizedBox(height: 12),
                                        Text(
                                          'جارٍ تجهيز السعر النهائي للمراجعة',
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  ClServiceOrderSummarySectionWidget(
                                    priceSummary:
                                        estimate.pricing?.priceSummary,
                                    basePrice: estimate.pricing?.basePrice ?? 0,
                                    travelFee: estimate.pricing?.travelFee ?? 0,
                                    addonsTotal:
                                        estimate.pricing?.addonsTotal ?? 0,
                                    totalPrice:
                                        estimate.pricing?.totalPrice ?? 0,
                                    adminMargin: estimate.pricing?.adminMargin,
                                    isPricingFinal:
                                        estimate.pricing?.isPricingFinal,
                                    currency:
                                        estimate.pricing?.currency ?? 'SYP',
                                    scheduleEntries:
                                        const <ClServiceScheduleEntry>[],
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      ClRedesignStickyActions(
                        primaryLabel: _v7Stage == 2
                            ? 'تأكيد طلب المناسبة'
                            : 'متابعة',
                        onPrimary: () => _advanceV7Occasion(state),
                        primaryEnabled:
                            !_submissionRequested &&
                            !_confirmationOpen &&
                            !_isCheckingSafetyPolicy &&
                            state.createOrderStatus != BlocStatus.loading &&
                            (_v7Stage != 2 ||
                                (estimate?.pricing?.totalPrice != null &&
                                    state.estimatePriceStatus !=
                                        BlocStatus.loading)),
                        secondaryLabel: 'السابق',
                        onSecondary: () => _v7Stage > 0
                            ? setState(() => _v7Stage--)
                            : context.pop(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _advanceV7Occasion(ClMainState state) {
    if (_v7Stage == 0) {
      final error = _validateSchedule();
      if (error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
        return;
      }
      setState(() {
        _v7Stage = 1;
        if (_requestedWorkerCount < _minimumWorkerCount) {
          _requestedWorkerCount = _minimumWorkerCount;
        }
      });
      _requestPreviousWorkers();
      return;
    }
    if (_v7Stage == 1) {
      if (_explicitGenderPreference == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('اختر عامل أو عاملة للمتابعة.')),
        );
        return;
      }
      if (_explicitGenderPreference == CleaningGenderPreference.female &&
          state.safetyConfirmation == null) {
        _confirmFemaleSafetyOnContinue();
        return;
      }
      _openReview(state);
      return;
    }
    _onSubmitPressed(state);
  }

  Widget _buildMultiDayScheduleCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'أيام وأوقات المناسبة',
                style: TextStyle(
                  color: Color(0xFF172554),
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ),
            TextButton.icon(
              key: const Key('add_event_session_day'),
              onPressed: _sessions.length >= 31 ? null : _addSessionDate,
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('إضافة يوم'),
            ),
          ],
        ),
        if (_sessions.length > 1)
          TextButton.icon(
            key: const Key('apply_event_time_to_all'),
            onPressed: _applyFirstSessionToAll,
            icon: const Icon(Icons.copy_all_outlined),
            label: const Text('نسخ وقت اليوم الأول للأيام الأخرى'),
          ),
        const SizedBox(height: 10),
        for (var index = 0; index < _sessions.length; index++) ...[
          _EventSessionCard(
            sequence: index + 1,
            session: _sessions[index],
            canRemove: _sessions.length > 1,
            onEditDate: () => _pickSessionDate(index),
            onEditTime: () => _pickSessionTime(index),
            onEditDuration: () => _editSessionDuration(index),
            onRemove: () => _removeSession(index),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didReadArgs) return;
    _didReadArgs = true;
    final args = widget.args ?? ModalRoute.of(context)?.settings.arguments;
    if (args is ClMainOccasionScheduleArgs) {
      _routeArgs = args;
      _bloc = args.bloc;
      _currentEstimate = null;
      _requestedWorkerCount = args.numberOfWorkers;
      _selectedAddress.value = args.defaultAddress;
      _sessions.add(
        _EventSessionDraft(
          date: _minimumDate,
          time: '09:00',
          hours: args.hours >= 1 ? args.hours : 4,
        ),
      );
      _sortSessions();
    }
  }

  @override
  void dispose() {
    _couponController.dispose();
    _selectedAddress.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _couponController = TextEditingController();
    _selectedAddress = ValueNotifier(null);
  }

  void _sortSessions() {
    _sessions.sort((a, b) {
      final dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) return dateCompare;
      return a.time.compareTo(b.time);
    });
  }

  String _slotKey(DateTime date, String time) =>
      '${CleaningScheduleDateTimeLogic.formatDateApi(date)}|$time';

  bool _hasDuplicateSlot({
    required DateTime date,
    required String time,
    int? exceptIndex,
  }) {
    final key = _slotKey(date, time);
    for (var index = 0; index < _sessions.length; index++) {
      if (index == exceptIndex) continue;
      final session = _sessions[index];
      if (_slotKey(session.date, session.time) == key) return true;
    }
    return false;
  }

  String _nextAvailableTimeForDate(
    DateTime date,
    String preferred, {
    int? exceptIndex,
  }) {
    if (!_hasDuplicateSlot(
      date: date,
      time: preferred,
      exceptIndex: exceptIndex,
    )) {
      return preferred;
    }
    final parts = preferred.split(':');
    final startHour = int.tryParse(parts.first) ?? 9;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    for (var offset = 1; offset < 24; offset++) {
      final hour = (startHour + offset) % 24;
      final candidate =
          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      if (!_hasDuplicateSlot(
        date: date,
        time: candidate,
        exceptIndex: exceptIndex,
      )) {
        return candidate;
      }
    }
    return preferred;
  }

  Future<void> _addSessionDate() async {
    if (_sessions.length >= 31) return;
    final startDate = _minimumDate;
    final initialDate = _lastSession?.date ?? startDate;
    final value = await AppPickers.showAppDatePicker(
      context: context,
      startDate: startDate,
      initialDate: initialDate.isBefore(startDate) ? startDate : initialDate,
    );
    if (!mounted) return;
    if (value.isEmpty) return;
    final date = CleaningScheduleDateTimeLogic.parseDateApi(value);
    if (date == null) return;

    final template = _firstSession;
    final preferredTime = template?.time ?? '09:00';
    final resolvedTime = _nextAvailableTimeForDate(date, preferredTime);
    if (_hasDuplicateSlot(date: date, time: resolvedTime)) {
      AppToast.showToast(
        context: context,
        message:
            'لا يوجد وقت افتراضي متاح لهذا اليوم. عدّل وقت يوم عمل آخر أولاً.',
        type: ToastificationType.warning,
      );
      return;
    }

    setState(() {
      _sessions.add(
        _EventSessionDraft(
          date: date,
          time: resolvedTime,
          hours: template?.hours ?? _defaultSessionHours,
          dateChosen: true,
        ),
      );
      _sortSessions();
    });
    _onScheduleChanged();
  }

  Future<void> _pickSessionDate(int index) async {
    if (index < 0 || index >= _sessions.length) return;
    final currentSession = _sessions[index];
    final initialDate = currentSession.date.isBefore(_minimumDate)
        ? _minimumDate
        : currentSession.date;
    final value = await AppPickers.showAppDatePicker(
      context: context,
      startDate: _minimumDate,
      initialDate: initialDate,
    );
    if (!mounted) return;
    if (value.isEmpty || index < 0 || index >= _sessions.length) return;
    final selectedDate = CleaningScheduleDateTimeLogic.parseDateApi(value);
    if (selectedDate == null) return;

    final session = _sessions[index];
    if (_hasDuplicateSlot(
      date: selectedDate,
      time: session.time,
      exceptIndex: index,
    )) {
      AppToast.showToast(
        context: context,
        message:
            'يوجد يوم عمل آخر بنفس التاريخ والوقت. غيّر الوقت أولاً أو اختر يوماً مختلفاً.',
        type: ToastificationType.warning,
      );
      return;
    }

    setState(() {
      _sessions[index].date = selectedDate;
      _sessions[index].dateChosen = true;
      _sortSessions();
    });
    _onScheduleChanged();
  }

  Future<void> _pickSessionTime(int index) async {
    final value = await AppPickers.showAppTimePicker(context: context);
    if (!mounted) return;
    if (value.isEmpty || index < 0 || index >= _sessions.length) return;
    final normalized = CleaningScheduleDateTimeLogic.normalizeTimeHhMm(value);
    final session = _sessions[index];
    if (_hasDuplicateSlot(
      date: session.date,
      time: normalized,
      exceptIndex: index,
    )) {
      AppToast.showToast(
        context: context,
        message: 'لا يمكن تكرار التاريخ والوقت نفسيهما ليوم عمل آخر.',
        type: ToastificationType.warning,
      );
      return;
    }
    setState(() {
      _sessions[index].time = normalized;
      _sessions[index].timeChosen = true;
      _sortSessions();
    });
    _onScheduleChanged();
  }

  Future<void> _editSessionDuration(int index) async {
    if (index < 0 || index >= _sessions.length) return;
    final controller = TextEditingController(
      text: _formatHours(_sessions[index].hours),
    );
    try {
      final result = await showDialog<double>(
        context: context,
        builder: (dialogContext) {
          String? errorText;
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('مدة الخدمة لهذا اليوم'),
                content: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d{0,2}(\.\d{0,2})?'),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: 'عدد الساعات',
                    hintText: 'مثال: 4',
                    errorText: errorText,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('إلغاء'),
                  ),
                  FilledButton(
                    onPressed: () {
                      final hours = double.tryParse(controller.text.trim());
                      if (hours == null || hours < 1 || hours > 24) {
                        setDialogState(() {
                          errorText = 'يجب أن تكون المدة بين 1 و24 ساعة';
                        });
                        return;
                      }
                      Navigator.of(dialogContext).pop(hours);
                    },
                    child: const Text('حفظ'),
                  ),
                ],
              );
            },
          );
        },
      );
      if (!mounted || result == null) return;
      setState(() {
        _sessions[index].hours = result;
        _sessions[index].hoursChosen = true;
      });
      _onScheduleChanged();
    } finally {
      controller.dispose();
    }
  }

  void _removeSession(int index) {
    if (_sessions.length <= 1 || index < 0 || index >= _sessions.length) return;
    setState(() {
      _sessions.removeAt(index);
    });
    _onScheduleChanged();
  }

  void _applyFirstSessionToAll() {
    final source = _firstSession;
    if (source == null || _sessions.length < 2) return;
    setState(() {
      for (var index = 1; index < _sessions.length; index++) {
        final session = _sessions[index];
        session.hours = source.hours;
        session.hoursChosen = source.hoursChosen;
        session.timeChosen = source.timeChosen;
        session.time = _nextAvailableTimeForDate(
          session.date,
          source.time,
          exceptIndex: index,
        );
      }
      _sortSessions();
    });
    _onScheduleChanged();
  }

  void _onScheduleChanged() {
    if (_appliedCouponCode != null) {
      setState(() {
        _appliedCouponCode = null;
        _couponStatus = ClCouponUiStatus.idle;
        _couponMessage = 'تم تعديل أيام المناسبة. أعد تطبيق الكوبون.';
      });
    }
    // A different day/time invalidates previously selected workers.
    _bloc?.add(ClearPreferredWorkersEvent());
    // Schedule edits are in-memory; request a single quote at final review.
    _currentEstimate = null;
  }

  void _requestPreviousWorkers() {
    final bloc = _bloc;
    final first = _firstSession;
    if (bloc == null || first == null) return;

    bloc.add(
      GetPreviousCleaningWorkersEvent(
        params: GetPreviousCleaningWorkersParams(
          page: 1,
          perPage: 20,
          propertyType: 'event_assistance',
          scheduledDate: CleaningScheduleDateTimeLogic.formatDateApi(
            first.date,
          ),
          scheduledTime: first.time,
          durationHours: first.hours,
          eventSessions: _eventSessionInputs,
        ),
        isReload: true,
      ),
    );
  }

  void _handleGenderPreferenceChanged(
    ClMainBloc bloc,
    CleaningGenderPreference preference,
  ) {
    if (_explicitGenderPreference != preference) {
      bloc.add(ClearPreferredWorkersEvent());
    }
    setState(() => _explicitGenderPreference = preference);
    if (preference != CleaningGenderPreference.female) {
      bloc.add(SetGenderPreferenceEvent(preference: preference));
    }
  }

  Future<void> _confirmFemaleSafetyOnContinue() async {
    if (_isCheckingSafetyPolicy) return;
    setState(() => _isCheckingSafetyPolicy = true);
    final response = await getIt<ClMainRepo>().getFemaleWorkerSafetyPolicy();
    if (!mounted) return;
    await response.fold(
      (failure) async {
        ToastComponent.showToast(context, msg: failure.message);
      },
      (policy) async {
        final confirmation = await showFemaleWorkerSafetyConfirmationSheet(
          context: context,
          policy: policy,
        );
        if (!mounted || confirmation == null) return;
        _bloc!.add(
          SetGenderPreferenceEvent(
            preference: CleaningGenderPreference.female,
            workEnvironmentConfirmation: confirmation,
          ),
        );
        _openReview(_bloc!.state);
      },
    );
    if (mounted) setState(() => _isCheckingSafetyPolicy = false);
  }

  void _openReview(ClMainState state) {
    setState(() {
      _v7Stage = 2;
      _currentEstimate = null;
    });
    _requestUpdatedEstimate(state);
  }

  Future<void> _onApplyCoupon(String code) async {
    final normalizedCode = code.trim();
    final args = _routeArgs;
    final state = _bloc?.state;
    final address = _selectedAddress.value;

    if (normalizedCode.isEmpty) {
      setState(() {
        _couponStatus = ClCouponUiStatus.failed;
        _couponMessage = 'يرجى إدخال كود الحسم أولاً.';
        _appliedCouponCode = null;
      });
      return;
    }
    if (args == null || state == null || address == null) {
      setState(() {
        _couponStatus = ClCouponUiStatus.failed;
        _couponMessage = 'يرجى اختيار عنوان الخدمة وإكمال البيانات أولاً.';
        _appliedCouponCode = null;
      });
      return;
    }

    setState(() {
      _couponStatus = ClCouponUiStatus.loading;
      _couponMessage = null;
      _appliedCouponCode = null;
    });

    final assignment = _resolveAssignment(state);
    final preferredWorkerId = assignment.preferredWorkerIds.isEmpty
        ? null
        : assignment.preferredWorkerIds.first;
    final response = await getIt<CheckRestaurantCouponUseCase>()(
      CheckRestaurantCouponParams(
        couponCode: normalizedCode,
        section: 'cleaning',
        propertyType: 'event_assistance',
        propertyDetails: _eventPropertyDetails(args, address),
        addressLatitude: address.latitude,
        addressLongitude: address.longitude,
        preferredWorkerId: preferredWorkerId,
      ),
    );
    if (!mounted) return;

    response.fold(
      (failure) => setState(() {
        _couponStatus = ClCouponUiStatus.failed;
        _couponMessage = failure.message;
        _appliedCouponCode = null;
      }),
      (result) {
        final data = result.data;
        if (data == null || !data.isAvailable) {
          setState(() {
            _couponStatus = ClCouponUiStatus.failed;
            _couponMessage = _couponReasonMessage(data?.reason);
            _appliedCouponCode = null;
          });
          return;
        }

        final discount = data.amounts?.discount ?? 0;
        setState(() {
          _couponStatus = ClCouponUiStatus.success;
          _couponMessage = discount > 0
              ? 'تم تطبيق الكوبون. قيمة الخصم ${_formatDiscount(discount)} ل.س'
              : 'تم التحقق من الكوبون بنجاح.';
          _appliedCouponCode = data.couponCode ?? normalizedCode;
        });
      },
    );
  }

  Map<String, dynamic> _eventPropertyDetails(
    ClMainOccasionScheduleArgs args,
    AddressListItem address,
  ) {
    final specialRequirement = args.specialRequirementId == 'none'
        ? null
        : args.specialRequirementLabel;
    final notes = args.notes?.trim();
    final details = <String, dynamic>{
      'address': address.line1,
      'location_name': address.label,
      'eventType': args.eventType,
      'guestCount': args.guestsCount,
      'venueType': args.venueType,
      'customService': args.customService,
      'hours': _scheduleTotalHours,
    };
    if (specialRequirement != null) {
      details['specialRequirement'] = specialRequirement;
    }
    if (notes != null && notes.isNotEmpty) {
      details['notes'] = notes;
    }
    return details;
  }

  String _couponReasonMessage(String? reason) {
    return switch (reason) {
      'not_found' => 'كود الكوبون غير موجود.',
      'inactive' => 'الكوبون غير فعال حالياً.',
      'not_started' => 'لم تبدأ صلاحية الكوبون بعد.',
      'expired' => 'انتهت صلاحية الكوبون.',
      'wrong_section' => 'الكوبون غير متاح لخدمات التنظيف.',
      'not_assigned_to_user' => 'هذا الكوبون غير مخصص لحسابك.',
      'global_usage_limit_reached' || 'user_usage_limit_reached' =>
        'تم الوصول إلى الحد المسموح لاستخدام الكوبون.',
      'min_order_not_met' => 'قيمة الطلب أقل من الحد الأدنى للكوبون.',
      'property_type_not_supported' => 'الكوبون لا يشمل خدمات المناسبات.',
      'event_type_not_supported' => 'الكوبون لا يشمل نوع المناسبة المحدد.',
      _ => 'الكوبون غير صالح لبيانات هذا الطلب.',
    };
  }

  String _formatDiscount(double value) {
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
  }

  String _formatHours(double value) {
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
  }

  String? _validateSchedule() {
    if (_sessions.isEmpty) return 'يرجى اختيار يوم عمل واحد على الأقل';
    if (_sessions.length > 31) {
      return 'الحد الأعلى لأيام عمل المناسبة هو 31 يوم عمل';
    }
    final seenSlots = <String>{};
    for (var index = 0; index < _sessions.length; index++) {
      final session = _sessions[index];
      if (!session.dateChosen) {
        return 'يرجى اختيار تاريخ يوم العمل ${index + 1}';
      }
      if (!session.timeChosen) {
        return 'يرجى اختيار وقت بدء يوم العمل ${index + 1}';
      }
      if (!session.hoursChosen) return 'يرجى تحديد مدة يوم العمل ${index + 1}';
      if (session.date.isBefore(_minimumDate)) {
        return 'تاريخ يوم العمل ${index + 1} يجب أن يكون غداً أو بعده';
      }
      final key = _slotKey(session.date, session.time);
      if (!seenSlots.add(key)) {
        return 'لا يمكن تكرار التاريخ والوقت نفسيهما لأكثر من يوم عمل';
      }
      if (!RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(session.time)) {
        return 'وقت يوم العمل ${index + 1} غير صالح';
      }
      if (session.hours < 1 || session.hours > 24) {
        return 'مدة يوم العمل ${index + 1} يجب أن تكون بين 1 و24 ساعة';
      }
    }
    return null;
  }

  void _showOrderPreparation() {
    if (_processingOpen || !mounted) return;
    _processingOpen = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Padding(
            padding: EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    color: Color(0xFF172554),
                  ),
                ),
                SizedBox(height: 22),
                Text(
                  'عم نرسل طلبك',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 8),
                Text(
                  'ثواني وبنوصل طلبك للفريق... خلّي الباقي علينا!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _dismissOrderPreparation() {
    if (!_processingOpen || !mounted) return;
    _processingOpen = false;
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> _onSubmitPressed(ClMainState state) async {
    if (_submissionRequested ||
        _confirmationOpen ||
        state.createOrderStatus == BlocStatus.loading ||
        state.estimatePriceStatus == BlocStatus.loading) {
      return;
    }
    if (_explicitGenderPreference == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار جنس العامل: ذكر أو أنثى')),
      );
      return;
    }

    final args = _routeArgs;
    final bloc = _bloc;
    if (args == null || bloc == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذر تجهيز بيانات الطلب')));
      return;
    }

    final scheduleError = _validateSchedule();
    if (scheduleError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(scheduleError)));
      return;
    }

    if (_explicitGenderPreference == CleaningGenderPreference.female &&
        state.safetyConfirmation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تأكيد بيئة العمل قبل طلب عاملة')),
      );
      return;
    }

    final selectedAddress = _selectedAddress.value;
    final addressId = int.tryParse(selectedAddress?.id ?? '') ?? 0;
    if (selectedAddress == null || addressId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار عنوان الخدمة أولاً')),
      );
      return;
    }
    if (!selectedAddress.hasCompleteServiceLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى اختيار عنوان يحتوي على موقع محدد على الخريطة وعنوان واضح',
          ),
        ),
      );
      return;
    }

    final pricing = _activeEstimate?.pricing;
    if (pricing == null ||
        state.estimatePriceStatus == BlocStatus.loading ||
        state.estimatePriceStatus == BlocStatus.failed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى انتظار تحديث التقدير قبل الإرسال.')),
      );
      return;
    }
    final quote = pricing.totalPrice;
    if (quote == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر عرض السعر. أعد محاولة تحديث التقدير.'),
        ),
      );
      return;
    }
    _confirmationOpen = true;
    final accepted = await showClBookingConfirmationSheet(
      context: context,
      title: 'تأكيد طلب المناسبة',
      total: quote,
      currency: pricing.currency ?? 'SYP',
      icon: Icons.event_available_outlined,
    );
    _confirmationOpen = false;
    if (!mounted ||
        accepted != true ||
        _submissionRequested ||
        bloc.state.createOrderStatus == BlocStatus.loading) {
      return;
    }
    if (!V6BookingQuoteGuard.canSubmit(
      confirmedTotal: quote,
      currentTotal: _activeEstimate?.pricing?.totalPrice,
      estimateRefreshing: bloc.state.estimatePriceStatus == BlocStatus.loading,
      estimateFailed: bloc.state.estimatePriceStatus == BlocStatus.failed,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تغير تقدير التكلفة. راجع السعر الجديد قبل الإرسال.'),
        ),
      );
      return;
    }

    final first = _firstSession!;
    final specialRequirement = args.specialRequirementId == 'none'
        ? null
        : args.specialRequirementLabel;
    final assignment = _resolveAssignment(state);
    _submissionRequested = true;
    bloc.add(
      CreateCleaningOrderEvent(
        params: CreateCleaningOrderParams.eventAssistance(
          addressId: addressId,
          eventType: args.eventType,
          eventTypeId: args.eventTypeId,
          eventDynamicAnswers: args.eventDynamicAnswers,
          guestCount: args.guestsCount,
          venueType: args.venueType,
          customService: args.customService,
          hours: _scheduleTotalHours,
          eventSessions: _eventSessionInputs,
          address: selectedAddress.line1,
          locationName: selectedAddress.label,
          scheduledDate: CleaningScheduleDateTimeLogic.formatDateApi(
            first.date,
          ),
          scheduledTime: first.time,
          genderPreference: _explicitGenderPreference ?? state.genderPreference,
          workEnvironmentConfirmation: state.safetyConfirmation,
          assignmentMode: assignment.assignmentMode,
          preferredWorkerIds: assignment.preferredWorkerIds,
          specialRequirement: specialRequirement,
          notes: args.notes,
          numberOfWorkers: _resolvedNumberOfWorkers,
          couponCode: _appliedCouponCode,
          termsAccepted: true,
        ),
      ),
    );
  }

  void _requestUpdatedEstimate(
    ClMainState state, {
    List<int>? selectedWorkerIds,
  }) {
    final args = _routeArgs;
    final bloc = _bloc;
    final address = _selectedAddress.value;
    if (args == null || bloc == null || address == null) return;

    if (_appliedCouponCode != null) {
      setState(() {
        _appliedCouponCode = null;
        _couponStatus = ClCouponUiStatus.idle;
        _couponMessage = 'تم تحديث بيانات الطلب. أعد تطبيق الكوبون.';
      });
    }

    final assignment = _resolveAssignment(
      state,
      selectedWorkerIds: selectedWorkerIds,
    );
    final specialRequirement = args.specialRequirementId == 'none'
        ? null
        : args.specialRequirementLabel;

    bloc.add(
      EstimateCleaningPriceEvent(
        params: EstimateCleaningPriceParams.eventAssistance(
          eventType: args.eventType,
          eventTypeId: args.eventTypeId,
          eventDynamicAnswers: args.eventDynamicAnswers,
          guestCount: args.guestsCount,
          venueType: args.venueType,
          customService: args.customService,
          hours: _scheduleTotalHours,
          eventSessions: _eventSessionInputs,
          addressId: int.tryParse(address.id),
          addressLatitude: address.latitude,
          addressLongitude: address.longitude,
          numberOfWorkers: _resolvedNumberOfWorkers,
          preferredWorkerIds: assignment.preferredWorkerIds,
          assignmentMode: assignment.assignmentMode,
          specialRequirement: specialRequirement,
          notes: args.notes,
        ),
      ),
    );
  }

  EventAssignmentFields _resolveAssignment(
    ClMainState state, {
    List<int>? selectedWorkerIds,
  }) {
    final workerIds = _normalizeWorkerIds(
      selectedWorkerIds ?? state.selectedWorkerIds,
    );
    return EventAssignmentFields(
      assignmentMode: workerIds.isEmpty
          ? CleaningAssignmentMode.openCount
          : CleaningAssignmentMode.preferredWorker,
      numberOfWorkers: _resolvedNumberOfWorkers,
      preferredWorkerIds: workerIds,
    );
  }

  List<int> _normalizeWorkerIds(List<int> ids) {
    final normalized = <int>[];
    for (final id in ids) {
      if (id <= 0 || normalized.contains(id)) continue;
      normalized.add(id);
    }
    return normalized;
  }
}

class _EventSessionDraft {
  DateTime date;
  String time;
  double hours;
  bool dateChosen;
  bool timeChosen;
  bool hoursChosen;

  _EventSessionDraft({
    required this.date,
    required this.time,
    required this.hours,
    this.dateChosen = false,
  }) : timeChosen = false,
       hoursChosen = false;

  String get endTime =>
      formatClServiceEndTime(startTime: time, durationHours: hours);
}

class _EventSessionCard extends StatelessWidget {
  const _EventSessionCard({
    required this.sequence,
    required this.session,
    required this.canRemove,
    required this.onEditDate,
    required this.onEditTime,
    required this.onEditDuration,
    required this.onRemove,
  });

  final int sequence;
  final _EventSessionDraft session;
  final bool canRemove;
  final VoidCallback onEditDate;
  final VoidCallback onEditTime;
  final VoidCallback onEditDuration;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => ClRedesignCard(
    key: Key('event_session_card_$sequence'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'اليوم $sequence',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF172554),
                ),
              ),
            ),
            if (canRemove)
              IconButton(
                onPressed: onRemove,
                tooltip: 'إزالة اليوم',
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFB42318),
                ),
              ),
          ],
        ),
        Text(
          session.dateChosen
              ? '${CleaningDateTimeUiFormat.weekday(session.date)}، ${CleaningDateTimeUiFormat.date(session.date)}'
              : 'اختر تاريخ اليوم',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onEditDate,
          icon: const Icon(Icons.event_outlined),
          label: const Text('اختيار التاريخ'),
        ),
        const SizedBox(height: 12),
        const Divider(color: Color(0xFFE4E9F1)),
        _OccasionInfoRow(
          label: 'وقت البدء',
          value: session.timeChosen
              ? CleaningDateTimeUiFormat.time(session.time)
              : 'لم يُحدد',
        ),
        _OccasionInfoRow(
          label: 'مدة العمل',
          value: session.hoursChosen
              ? '${session.hours.toStringAsFixed(session.hours % 1 == 0 ? 0 : 1)} ساعة'
              : 'لم تُحدد',
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onEditTime,
                icon: const Icon(Icons.schedule_outlined),
                label: const Text('تحديد الوقت'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onEditDuration,
                icon: const Icon(Icons.timelapse_outlined),
                label: const Text('تحديد المدة'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _OccasionInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _OccasionInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppText.bodySmall(
            label,
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AppText.bodySmall(
            value,
            color: const Color(0xFF111827),
            textAlign: TextAlign.end,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
