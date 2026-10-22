import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/models/cleaning_gender_preference.dart';
import '../../../../core/models/cleaning_service_extras.dart';
import '../../../../core/utils/cleaning_date_time_ui_format.dart';
import '../../../../core/utils/cleaning_schedule_date_time_logic.dart';
import '../../../../core/widgets/toast_component.dart';
import '../../../orders/domain/usecases/check_restaurant_coupon_use_case.dart';
import '../../../orders/view/screens/cleaning_order_details_screen.dart';
import '../../../profile/domain/models/address_list_item.dart';
import '../../data/models/cleaning_services_response_model.dart';
import '../../data/models/cleaning_suite_config_model.dart';
import '../../data/source/cl_main_remote_data_source.dart';
import '../../domain/models/cl_worker_room_assignment.dart';
import '../../domain/models/cl_worker_room_assignment_result.dart';
import '../../domain/models/cleaning_assignment_mode.dart';
import '../../domain/models/cleaning_recurring_session.dart';
import '../../domain/models/cleaning_type.dart';
import '../../domain/models/cleaning_room_period_draft.dart';
import '../../domain/repository/cl_main_repo.dart';
import '../../domain/usecases/create_cleaning_order_use_case.dart';
import '../../domain/usecases/estimate_cleaning_price_use_case.dart';
import '../../domain/usecases/get_cleaning_services_use_case.dart';
import '../data/cl_main_route_args.dart';
import '../helpers/cl_service_schedule_time_utils.dart';
import '../manager/bloc/cl_main_bloc.dart';
import '../widgets/app_pickers.dart';
import '../widgets/cl_booking_confirmation_sheet.dart';
import '../widgets/cl_cleaning_extras_section_widget.dart';
import '../widgets/cl_cleaning_materials_step_widget.dart';
import '../widgets/cl_room_periods_editor.dart';
import '../widgets/cl_special_services_step_widget.dart';
import '../widgets/cl_female_worker_safety_confirmation_sheet.dart';
import '../widgets/cl_open_time_sessions_section_widget.dart';
import '../widgets/cl_recurring_schedule_section_widget.dart';
import '../widgets/cl_scheduled_previous_workers_section_widget.dart';
import '../widgets/cl_service_address_section_widget.dart';
import '../widgets/cl_service_assignment_mode_section_widget.dart';
import '../widgets/cl_service_worker_count_selector_widget.dart';
import '../widgets/cl_service_worker_room_assignment_widget.dart';
import '../widgets/cl_service_coupon_section_widget.dart';
import '../widgets/cl_service_gender_preference_section_widget.dart';
import '../widgets/cl_service_order_summary_section_widget.dart';
import '../widgets/cl_service_schedule_section_widget.dart';
import '../widgets/home_details_app_bar.dart';
import '../widgets/cl_redesign_components.dart';
import '../widgets/v6_booking_decision_guide.dart';
import '../helpers/v6_booking_quote_guard.dart';
import '../widgets/cl_booking_review_overview.dart';

@AutoRoutePage()
class ClMainServiceScheduleScreen extends StatefulWidget {
  final ClMainScheduleArgs? item;
  final ClMainScheduleArgs? args;

  const ClMainServiceScheduleScreen({super.key, this.item, this.args});

  @override
  State<ClMainServiceScheduleScreen> createState() =>
      _ClMainServiceScheduleScreenState();
}

class _ClMainServiceScheduleScreenState
    extends State<ClMainServiceScheduleScreen> {
  ClMainBloc? _bloc;
  CleaningGenderPreference? _explicitGenderPreference;
  bool _dateChosen = false;
  bool _timeChosen = false;
  late DateTime _selectedDate;
  late String _fromTimeHhMm;
  late String _toTimeHhMm;
  late TextEditingController _fromTimeController;
  late TextEditingController _toTimeController;
  late TextEditingController _couponController;
  ClMainScheduleArgs? _routeArgs;
  bool _didReadArgs = false;
  EstimatePriceResponseModel? _currentEstimate;
  ValueNotifier<AddressListItem?> selectedAddress = ValueNotifier(null);
  ClCouponUiStatus _couponStatus = ClCouponUiStatus.idle;
  String? _couponMessage;
  String? _appliedCouponCode;
  double? _appliedCouponDiscount;
  double? _appliedCouponTotal;
  BlocStatus _specialServicesStatus = BlocStatus.init;
  String? _specialServicesErrorMessage;
  List<CleaningServiceModel> _availableSpecialServices =
      const <CleaningServiceModel>[];
  // Catalog is stable within one booking draft; never cache the quote itself.
  List<CleaningMaterialLineModel> _availableMaterialsCatalog =
      const <CleaningMaterialLineModel>[];
  final Set<String> _selectedCleaningServiceNames = <String>{};
  CleaningServiceExtrasRequest _serviceExtras =
      const CleaningServiceExtrasRequest();
  CleaningSuiteConfigModel _suiteConfig = const CleaningSuiteConfigModel();
  bool _isRecurring = false;
  CleaningRoomPeriodDrafts? _roomPeriods;
  final Map<String, int> _roomWorkMinutes = <String, int>{};
  int _periodQuoteRefreshGeneration = 0;
  bool get _isPeriodBooking =>
      (_routeArgs?.roomUnits.isNotEmpty ?? false) && _roomPeriods != null;

  void _updateRoomPeriods(CleaningRoomPeriodDrafts next) {
    final prior = {
      for (final period
          in _roomPeriods?.periods ?? const <CleaningRoomPeriodDraft>[])
        period.clientKey: period,
    };

    setState(() {
      for (final updated in next.periods) {
        final previous = prior[updated.clientKey];
        if (previous == null ||
            !_samePeriodServices(
              previous.specialServices,
              updated.specialServices,
            )) {
          // Specialized work changes total work minutes. Never show a stale
          // duration while its fresh room quote is pending.
          _roomWorkMinutes.remove(updated.clientKey);
        }
      }
      _roomPeriods = next;
      _priceNeedsRefresh = true;
      _currentEstimate = null;
    });

    // Changes to a period must refresh the backend quote even before review,
    // but fast counter taps should not create a burst of HTTP requests.
    final revision = ++_periodQuoteRefreshGeneration;
    Future<void>.delayed(const Duration(milliseconds: 260), () {
      if (!mounted || revision != _periodQuoteRefreshGeneration) return;
      final address = selectedAddress.value;
      final bloc = _bloc;
      if (bloc != null &&
          address != null &&
          (int.tryParse(address.id) ?? 0) > 0 &&
          address.hasCompleteServiceLocation) {
        _requestUpdatedEstimate(bloc.state, force: true);
      }
    });
  }

  bool _samePeriodServices(
    List<Map<String, dynamic>> before,
    List<Map<String, dynamic>> after,
  ) {
    if (before.length != after.length) return false;
    for (var index = 0; index < before.length; index++) {
      final original = before[index];
      final revised = after[index];
      if (original.length != revised.length) return false;
      for (final entry in original.entries) {
        if (!revised.containsKey(entry.key) ||
            revised[entry.key] != entry.value) {
          return false;
        }
      }
    }
    return true;
  }

  Widget _buildPeriodReview() {
    final periodDrafts = _roomPeriods;
    if (periodDrafts == null) return const SizedBox.shrink();
    final quotePeriods =
        _currentEstimate?.roomPeriods ?? const <Map<String, dynamic>>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'ملخص فترات الغرف',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        for (final period in periodDrafts.periods)
          Card(
            child: ListTile(
              title: Text(
                '${period.room.roomType.apiKey} ${period.room.index} · ${period.room.cleaningType.title}',
              ),
              subtitle: Text(
                '${period.scheduledDate.toIso8601String().substring(0, 10)} · ${period.scheduledTime} · ${period.workers} عامل · ${period.providedByPlatform
                        ? 'مواد من المنصة'
                        : 'مواد من العميل'} · ${period.specialServices.length} خدمات',
              ),
              trailing: Text(
                (() {
                  final value = quotePeriods
                      .where((q) => q['clientKey'] == period.clientKey)
                      .firstOrNull;
                  return value == null
                      ? ''
                      : '${value['estimatedDurationMinutes']?.toString() ?? ''} د';
                })(),
              ),
            ),
          ),
      ],
    );
  }

  CleaningRecurringPattern _recurringPattern = CleaningRecurringPattern.custom;
  CleaningRecurringCalculationMode _recurringCalculationMode =
      CleaningRecurringCalculationMode.hours;
  CleaningRecurringWorkerScope _recurringWorkerScope =
      CleaningRecurringWorkerScope.any;
  double _recurringHoursPerVisit = 2;
  int _recurringOccurrences = 2;
  List<CleaningRecurringSessionInput> _recurringSessions =
      const <CleaningRecurringSessionInput>[];
  List<CleaningOpenTimeSessionRequest> _openTimeSessions =
      const <CleaningOpenTimeSessionRequest>[];
  bool _manualRoomAssignmentEnabled = false;
  bool _customerProvidesMaterials = true;
  Set<int> _missingMaterialTypeIds = <int>{};
  int _scheduleStep = 0;
  final TextEditingController _bookingNotesController = TextEditingController();
  bool _loadingFemaleSafetyPolicy = false;
  bool _priceNeedsRefresh = true;
  bool _isSubmittingDialogOpen = false;
  bool _submissionRequested = false;
  bool _confirmationOpen = false;
  bool _exitDialogOpen = false;
  final ScrollController _scheduleScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final dayAr = _dateChosen
        ? CleaningDateTimeUiFormat.weekday(_selectedDate)
        : 'اختر التاريخ';
    final dayDate = _dateChosen
        ? CleaningDateTimeUiFormat.date(_selectedDate)
        : '';
    final estimate = _currentEstimate;
    final bloc = _bloc;

    if (bloc == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F2F2),
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: BlocProvider.value(
        value: bloc,
        child: BlocConsumer<ClMainBloc, ClMainState>(
          listenWhen: (previous, current) =>
              previous.createOrderStatus != current.createOrderStatus ||
              previous.estimatePriceStatus != current.estimatePriceStatus ||
              !identical(previous.estimatePrice, current.estimatePrice),
          listener: (context, state) {
            if (state.estimatePriceStatus == BlocStatus.loading &&
                _currentEstimate != null) {
              setState(() {
                _currentEstimate = null;
                _priceNeedsRefresh = true;
              });
            } else if (state.estimatePriceStatus == BlocStatus.success &&
                state.estimatePrice != null) {
              setState(() {
                _currentEstimate = state.estimatePrice;
                for (final room in state.estimatePrice!.roomPeriods) {
                  final key = room['clientKey']?.toString();
                  final minutes = (room['estimatedWorkMinutes'] as num?)
                      ?.toInt();
                  if (key != null && minutes != null && minutes > 0) {
                    _roomWorkMinutes[key] = minutes;
                  }
                }
                if (state.estimatePrice!.availableMaterials.isNotEmpty) {
                  _availableMaterialsCatalog =
                      state.estimatePrice!.availableMaterials;
                  _routeArgs?.draft?['availableMaterialsCatalog'] =
                      _availableMaterialsCatalog;
                }
                _priceNeedsRefresh = false;
                _syncToTime();
              });
            } else if (state.estimatePriceStatus == BlocStatus.failed &&
                state.errorMessage != null &&
                state.errorMessage!.isNotEmpty) {
              setState(() {
                _currentEstimate = null;
                _priceNeedsRefresh = true;
              });
              AppToast.showToast(
                context: context,
                message: state.errorMessage!,
                type: ToastificationType.error,
              );
            }

            if (state.createOrderStatus == BlocStatus.loading) {
              _showSendingOrderDialog();
              return;
            }
            _hideSendingOrderDialog();
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
                message: 'وصلنا طلبك! خلي الباقي علينا، ورح نخبرك بكل جديد.',
                type: ToastificationType.success,
              );
              context.pushRouteAndRemoveUntil(
                '/cleaning-order-details',
                arguments: CleaningOrderDetailsArgs(orderId: orderId),
                predicate: (route) => route.settings.name == '/clmain',
              );
            } else if (state.createOrderStatus == BlocStatus.failed) {
              _submissionRequested = false;
              final message = (state.errorMessage ?? '').trim().isNotEmpty
                  ? state.errorMessage!
                  : 'فشل تنفيذ الطلب';
              AppToast.showToast(
                context: context,
                message: message,
                type: ToastificationType.error,
              );
            }
          },
          builder: (context, state) {
            return Scaffold(
              backgroundColor: const Color(0xFFF6F7F9),
              body: SafeArea(
                child: Column(
                  children: [
                    HomeDetailsAppBar(onBack: _confirmExit),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scheduleScrollController,
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          16,
                          18,
                          16,
                          24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ClRedesignStepHeader(
                              currentStep: _scheduleStep + 4,
                              totalSteps: 8,
                              title: switch (_scheduleStep) {
                                0 => 'مواد التنظيف',
                                1 => 'الخدمات المتخصصة',
                                2 => 'الموعد والعنوان',
                                3 => 'العمال',
                                _ => 'مراجعة الطلب',
                              },
                              subtitle: switch (_scheduleStep) {
                                0 => 'اختر من يوفر المواد وحدد ما ينقصك بدقة.',
                                1 => 'أضف الخدمات المتخصصة إن كنت بحاجة إليها.',
                                2 => 'اختر الوقت والمكان المناسبين لك.',
                                3 => 'اختر فريق العمل المناسب بعد تحديد موعدك.',
                                _ => 'راجع التفاصيل والتكلفة قبل إرسال طلبك.',
                              },
                            ),
                            const SizedBox(height: 18),
                            if (_scheduleStep == 2 && _isPeriodBooking) ...[
                              const Text(
                                'حدد وقت وعدد عمال كل فترة',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ClRoomPeriodsEditor(
                                phase: ClPeriodEditingPhase.schedule,
                                workMinutesByRoom: _roomWorkMinutes,
                                drafts: _roomPeriods!,
                                onChanged: _updateRoomPeriods,
                              ),
                              CleaningAddressSelectWidget(
                                selectedAddress: selectedAddress,
                                onChangeTap: _selectAddress,
                                afterBringDefault: () =>
                                    _requestUpdatedEstimate(state),
                              ),
                            ],
                            if (_scheduleStep == 2 && !_isPeriodBooking) ...[
                              const V6BookingDecisionGuide(
                                topic: V6BookingDecisionTopic.appointment,
                              ),
                              const SizedBox(height: 12),
                              ClServiceScheduleSectionWidget(
                                dayAr: dayAr,
                                dayDate: dayDate,
                                fromTimeController: _fromTimeController,
                                toTimeController: _toTimeController,
                                onPickDate: _pickDate,
                                onPickFromTime: _pickFromTime,
                                showExpectedEnd: _dateChosen && _timeChosen,
                              ),
                              const SizedBox(height: 10),
                              const V6BookingDecisionGuide(
                                topic: V6BookingDecisionTopic.recurrence,
                              ),
                              const SizedBox(height: 10),
                              ClRecurringScheduleSectionWidget(
                                enabled: _isRecurring,
                                pattern: _recurringPattern,
                                workerScope: _recurringWorkerScope,
                                calculationMode: _recurringCalculationMode,
                                hoursPerVisit: _recurringHoursPerVisit,
                                occurrences: _recurringOccurrences,
                                maxOccurrences: _recurringMaxOccurrences,
                                sessions: _recurringSessions,
                                onEnabledChanged: (enabled) =>
                                    _setRecurringEnabled(enabled, state),
                                onPatternChanged: (pattern) =>
                                    _setRecurringPattern(pattern, state),
                                onWorkerScopeChanged: (scope) =>
                                    _setRecurringWorkerScope(scope, state),
                                onCalculationModeChanged: (mode) =>
                                    _setRecurringCalculationMode(mode, state),
                                onHoursPerVisitChanged: (hours) =>
                                    _setRecurringHoursPerVisit(hours, state),
                                onOccurrencesChanged: (occurrences) =>
                                    _setRecurringOccurrences(
                                      occurrences,
                                      state,
                                    ),
                                onAddVisit: () => _addRecurringVisit(state),
                                onEditVisit: (index) =>
                                    _editRecurringVisit(index, state),
                                onRemoveVisit: (index) =>
                                    _removeRecurringVisit(index, state),
                              ),
                              const SizedBox(height: 10),
                              CleaningAddressSelectWidget(
                                selectedAddress: selectedAddress,
                                onChangeTap: _selectAddress,
                                afterBringDefault: () =>
                                    _requestUpdatedEstimate(state),
                              ),
                            ],
                            if (_scheduleStep == 3) ...[
                              ClServiceGenderPreferenceSectionWidget(
                                selectedPreference: _explicitGenderPreference,
                                onChanged: (preference) {
                                  _handleGenderPreferenceChanged(
                                    bloc,
                                    preference,
                                  );
                                },
                              ),
                              if (_loadingFemaleSafetyPolicy)
                                const Padding(
                                  key: Key('female_safety_inline_loading'),
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'عم نجهّز تأكيد بيئة العمل...',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 12),
                            ],
                            if (_scheduleStep == 0 && _isPeriodBooking) ...[
                              ClRoomPeriodsEditor(
                                phase: ClPeriodEditingPhase.materials,
                                drafts: _roomPeriods!,
                                materials: _availableMaterialsCatalog,
                                onChanged: _updateRoomPeriods,
                              ),
                            ],
                            if (_scheduleStep == 0 && !_isPeriodBooking) ...[
                              ClCleaningMaterialsStepWidget(
                                customerProvides: _customerProvidesMaterials,
                                requiredMaterials:
                                    (estimate?.availableMaterials.isNotEmpty ==
                                        true)
                                    ? estimate!.availableMaterials
                                    : _availableMaterialsCatalog,
                                missingTypeIds: _missingMaterialTypeIds,
                                isLoading:
                                    _availableMaterialsCatalog.isEmpty &&
                                    state.estimatePriceStatus ==
                                        BlocStatus.loading,
                                onRetry: () =>
                                    _requestUpdatedEstimate(state, force: true),
                                onCustomerProvidesChanged: (customer) =>
                                    _setMaterialsProvider(customer, state),
                                onMissingChanged: (ids) =>
                                    _setMissingMaterialTypes(ids, state),
                              ),
                            ],
                            if (_scheduleStep == 1 && _isPeriodBooking) ...[
                              ClRoomPeriodsEditor(
                                phase: ClPeriodEditingPhase.specialized,
                                drafts: _roomPeriods!,
                                services: _availableSpecialServices,
                                onChanged: _updateRoomPeriods,
                              ),
                            ],
                            if (_scheduleStep == 1 && !_isPeriodBooking) ...[
                              ClSpecialServicesStepWidget(
                                catalog: _availableSpecialServices,
                                selectedIds: _serviceExtras.specialServices
                                    .map((e) => e.specialServiceId)
                                    .toSet(),
                                isLoading:
                                    _specialServicesStatus ==
                                    BlocStatus.loading,
                                onToggle: (id) =>
                                    _toggleSpecialServiceById(id, state),
                                selectedServices:
                                    _serviceExtras.specialServices,
                                onServiceChanged: (service) {
                                  final index = _serviceExtras.specialServices
                                      .indexWhere(
                                        (item) =>
                                            item.specialServiceId ==
                                            service.specialServiceId,
                                      );
                                  if (index >= 0) {
                                    _replaceSpecialService(
                                      index,
                                      service,
                                      state,
                                    );
                                  }
                                },
                                editor: ClCleaningExtrasSectionWidget(
                                  showMaterials: false,
                                  showAddButton: false,
                                  compactSpecialEditor: true,
                                  showOpenTime: false,
                                  requestMaterials:
                                      _serviceExtras.requestMaterials,
                                  specialServices:
                                      _serviceExtras.specialServices,
                                  openTime: _serviceExtras.openTime,
                                  availableSpecialServices:
                                      _availableSpecialServices,
                                  materials:
                                      estimate?.materials ??
                                      const <CleaningMaterialLineModel>[],
                                  estimatedSpecialServices:
                                      estimate?.specialServices ??
                                      const <CleaningSpecialServiceLineModel>[],
                                  estimatedOpenTime: estimate?.openTime,
                                  isSpecialServicesLoading:
                                      _specialServicesStatus ==
                                      BlocStatus.loading,
                                  isEstimateLoading:
                                      state.estimatePriceStatus ==
                                      BlocStatus.loading,
                                  specialServicesError:
                                      _specialServicesStatus ==
                                          BlocStatus.failed
                                      ? _specialServicesErrorMessage
                                      : null,
                                  estimateError:
                                      state.estimatePriceStatus ==
                                          BlocStatus.failed
                                      ? state.errorMessage
                                      : null,
                                  onRequestMaterialsChanged: (value) =>
                                      _setMaterialsRequested(value, state),
                                  onAddSpecialService: () =>
                                      _addSpecialService(state),
                                  onSpecialServiceChanged: (index, service) =>
                                      _replaceSpecialService(
                                        index,
                                        service,
                                        state,
                                      ),
                                  onRemoveSpecialService: (index) =>
                                      _removeSpecialService(index, state),
                                  onOpenTimeChanged: (enabled) =>
                                      _setOpenTimeEnabled(enabled, state),
                                  onOpenTimeWorkerCountChanged: (count) =>
                                      _setOpenTimeWorkerCount(count, state),
                                  onOpenTimeExpectedMaxMinutesChanged:
                                      (minutes) =>
                                          _setOpenTimeExpectedMaxMinutes(
                                            minutes,
                                            state,
                                          ),
                                  openTimeDurationOptions:
                                      _suiteConfig.openTime.durationOptions,
                                  selectableSessionIds: _isRecurring
                                      ? List<int>.generate(
                                          _recurringSessions.length,
                                          (index) => index + 1,
                                        )
                                      : const <int>[],
                                  sessionLabels: _isRecurring
                                      ? <int, String>{
                                          for (
                                            var index = 0;
                                            index < _recurringSessions.length;
                                            index++
                                          )
                                            index + 1: 'الجلسة ${index + 1}',
                                        }
                                      : const <int, String>{},
                                  onRetryEstimate: () =>
                                      _requestUpdatedEstimate(
                                        state,
                                        force: true,
                                      ),
                                  onRetrySpecialServices: _loadSpecialServices,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                key: const Key('booking_global_notes'),
                                controller: _bookingNotesController,
                                maxLines: 3,
                                maxLength: 500,
                                textAlign: TextAlign.start,
                                decoration: const InputDecoration(
                                  labelText: 'ملاحظات الطلب (اختياري)',
                                  hintText: 'أي تفاصيل تهم فريق التنظيف',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.notes_outlined),
                                ),
                              ),
                              if (_serviceExtras.openTime != null) ...[
                                const SizedBox(height: 12),
                                ClOpenTimeSessionsSectionWidget(
                                  sessions: _openTimeSessions,
                                  durationOptions:
                                      _suiteConfig.openTime.durationOptions,
                                  defaultExpectedMaxMinutes: _serviceExtras
                                      .openTime!
                                      .expectedMaxMinutes,
                                  onAddSession: () =>
                                      _addOpenTimeSession(state),
                                  onEditSession: (index) =>
                                      _editOpenTimeSession(index, state),
                                  onRemoveSession: (index) =>
                                      _removeOpenTimeSession(index, state),
                                  onDurationChanged: (index, minutes) =>
                                      _setOpenTimeSessionDuration(
                                        index,
                                        minutes,
                                        state,
                                      ),
                                ),
                              ],
                            ],
                            if (_scheduleStep == 3) ...[
                              const SizedBox(height: 16),
                              if (_serviceExtras.openTime == null &&
                                  (!_isRecurring ||
                                      _recurringWorkerScope ==
                                          CleaningRecurringWorkerScope
                                              .specific)) ...[
                                const V6BookingDecisionGuide(
                                  topic: V6BookingDecisionTopic.teamSelection,
                                ),
                                const SizedBox(height: 12),
                              ],
                              _buildWorkerSelectionSection(
                                state: state,
                                bloc: bloc,
                                estimate: estimate,
                              ),
                            ],
                            if (_scheduleStep == 4) ...[
                              const V6BookingDecisionGuide(
                                topic: V6BookingDecisionTopic.bookingReview,
                              ),
                              const SizedBox(height: 12),
                              if (_isPeriodBooking) _buildPeriodReview(),
                              if (!_isPeriodBooking)
                                ClBookingReviewOverview(
                                  service:
                                      _routeArgs?.cleaningType.title ?? 'تنظيف',
                                  address:
                                      [
                                            selectedAddress.value?.label,
                                            selectedAddress.value?.line1,
                                          ]
                                          .whereType<String>()
                                          .where(
                                            (item) => item.trim().isNotEmpty,
                                          )
                                          .toSet()
                                          .join('، '),
                                  workerLabel:
                                      (_serviceExtras.openTime?.workerCount ??
                                              _requiredWorkersCount(state))
                                          .toString(),
                                  materialsRequested:
                                      _serviceExtras.requestMaterials,
                                  missingMaterialTypeIds:
                                      _serviceExtras.materialTypeIds,
                                  missingMaterialNames:
                                      (estimate?.availableMaterials ??
                                              const <
                                                CleaningMaterialLineModel
                                              >[])
                                          .where(
                                            (line) => _missingMaterialTypeIds
                                                .contains(line.materialTypeId),
                                          )
                                          .map((line) => line.name)
                                          .whereType<String>()
                                          .toList(growable: false),
                                  services:
                                      _selectedCleaningServiceNames.toList()
                                        ..sort(),
                                  recurring: _isRecurring,
                                  roomSizeBreakdown:
                                      _routeArgs?.roomSizeBreakdown,
                                  roomNamesByCode:
                                      Map<String, String>.fromEntries(
                                        (_routeArgs?.roomUnits ?? const [])
                                            .where(
                                              (unit) =>
                                                  unit.displayName
                                                      ?.trim()
                                                      .isNotEmpty ??
                                                  false,
                                            )
                                            .map(
                                              (unit) => MapEntry(
                                                unit.roomType.apiKey,
                                                unit.displayName!.trim(),
                                              ),
                                            ),
                                      ),
                                  roomCleaningModes:
                                      _routeArgs?.roomCleaningModes ??
                                      const <String, String>{},
                                ),
                              const SizedBox(height: 12),
                              if (!_isPeriodBooking)
                                ClServiceCouponSectionWidget(
                                  couponController: _couponController,
                                  status: _couponStatus,
                                  message: _couponMessage,
                                  onApply: _applyCoupon,
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
                              if (_priceNeedsRefresh) ...[
                                const Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                    4,
                                    0,
                                    4,
                                    8,
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text('جارٍ تحديث السعر...'),
                                    ],
                                  ),
                                ),
                              ],
                              if (_isPeriodBooking)
                                ClRedesignCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const Text(
                                        'السعر النهائي لطلب التنظيف',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        estimate?.pricing?.totalPrice == null
                                            ? 'جارٍ حساب السعر...'
                                            : '${estimate!.pricing!.totalPrice!
                                                      .toStringAsFixed(0)} ل.س',
                                        style: const TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF075A50),
                                        ),
                                      ),
                                      const Text(
                                        'المبلغ الكامل للحجز، دون رسوم إضافية مفصلة.',
                                      ),
                                    ],
                                  ),
                                ),
                              if (!_isPeriodBooking)
                                ClServiceOrderSummarySectionWidget(
                                  priceSummary: estimate?.pricing?.priceSummary,
                                  basePrice: estimate?.pricing?.basePrice ?? 0,
                                  travelFee: estimate?.pricing?.travelFee ?? 0,
                                  addonsTotal:
                                      estimate?.pricing?.addonsTotal ?? 0,
                                  totalPrice:
                                      estimate?.pricing?.totalPrice ?? 0,
                                  discountAmount: _appliedCouponDiscount,
                                  totalAfterDiscount: _appliedCouponTotal,
                                  adminMargin: estimate?.pricing?.adminMargin,
                                  isPricingFinal:
                                      estimate?.pricing?.isPricingFinal,
                                  minimumOrderPrice:
                                      estimate?.pricing?.minimumOrderPrice,
                                  minimumOrderApplied:
                                      estimate?.pricing?.minimumOrderApplied ??
                                      false,
                                  currency:
                                      estimate?.pricing?.currency ?? 'SYP',
                                  scheduleDayLabel: dayAr,
                                  scheduleDateLabel: dayDate,
                                  scheduleTimeRange:
                                      CleaningDateTimeUiFormat.timeRange(
                                        _fromTimeHhMm,
                                        _toTimeHhMm,
                                      ),
                                ),
                              const SizedBox(height: 12),
                              const ClRedesignCard(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.payments_outlined,
                                      color: Color(0xFF0B7480),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'الدفع نقداً عند إتمام الخدمة.',
                                        style: TextStyle(
                                          color: Color(0xFF172554),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    ClRedesignStickyActions(
                      primaryLabel: _scheduleStep == 4
                          ? 'تأكيد وإرسال الطلب'
                          : 'متابعة',
                      onPrimary: () => _advanceSchedule(state),
                      primaryEnabled:
                          !_submissionRequested &&
                          !_confirmationOpen &&
                          state.createOrderStatus != BlocStatus.loading &&
                          state.estimatePriceStatus != BlocStatus.loading,
                      secondaryLabel: 'السابق',
                      onSecondary: _previousScheduleStep,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _setScheduleStep(int nextStep) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _scheduleStep = nextStep.clamp(0, 4));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scheduleScrollController.hasClients) {
        _scheduleScrollController.jumpTo(0);
      }
    });
  }

  Future<void> _confirmExit() async {
    if (_exitDialogOpen || !mounted) return;
    _exitDialogOpen = true;
    final shouldLeave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('هل تريد مغادرة طلب التنظيف؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('متابعة الطلب'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('مغادرة'),
          ),
        ],
      ),
    );
    _exitDialogOpen = false;
    if (shouldLeave == true && mounted) {
      // The parent booking route closes itself when this route returns true.
      Navigator.of(context).pop(true);
    }
  }

  void _previousScheduleStep() {
    if (_scheduleStep > 0) {
      _setScheduleStep(_scheduleStep - 1);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _bookingFeedback(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _advanceSchedule(ClMainState state) {
    // Final booking sequence: materials -> specialized services ->
    // appointment/address -> workers -> review/submit.
    if (_scheduleStep == 0) {
      if (_isPeriodBooking) {
        _setScheduleStep(1);
        return;
      }
      if (state.estimatePriceStatus == BlocStatus.loading) {
        _bookingFeedback('عم نجهّز قائمة مواد التنظيف، انتظر شوي.');
        return;
      }
      if (state.estimatePriceStatus == BlocStatus.failed) {
        _bookingFeedback('تعذر تحميل المواد. أعد المحاولة.');
        return;
      }
      _setScheduleStep(1);
      return;
    }
    if (_scheduleStep == 1) {
      _setScheduleStep(2);
      if (_isPeriodBooking) {
        _requestUpdatedEstimate(state, force: true);
      }
      return;
    }
    if (_scheduleStep == 2) {
      if (_isPeriodBooking) {
        final address = selectedAddress.value;
        if (address == null ||
            !address.hasCompleteServiceLocation ||
            (int.tryParse(address.id) ?? 0) <= 0) {
          _bookingFeedback('حدد عنوان خدمة واضحاً قبل المتابعة');
          return;
        }
        _setScheduleStep(3);
        _requestUpdatedEstimate(state, force: true);
        return;
      }
      if (!_dateChosen) {
        _bookingFeedback('اختر تاريخ الخدمة للمتابعة.');
        return;
      }
      if (!_timeChosen) {
        _bookingFeedback('اختر وقت بدء الخدمة للمتابعة.');
        return;
      }
      final address = selectedAddress.value;
      if (address == null || (int.tryParse(address.id) ?? 0) <= 0) {
        _bookingFeedback('اختر عنوان الخدمة للمتابعة.');
        return;
      }
      if (!address.hasCompleteServiceLocation) {
        _bookingFeedback('اختر عنواناً واضحاً مع موقعه على الخريطة.');
        return;
      }
      // Worker availability needs a quote for the selected address and extras.
      // Clear the provisional quote before rendering the worker list.
      setState(() => _currentEstimate = null);
      _setScheduleStep(3);
      _requestUpdatedEstimate(state, force: true);
      return;
    }
    if (_scheduleStep == 3) {
      if (_explicitGenderPreference == null) {
        _bookingFeedback('اختر عامل أو عاملة للمتابعة.');
        return;
      }
      if (state.genderPreference.apiValue == 'female' &&
          state.safetyConfirmation == null) {
        _bookingFeedback('أكد بيئة العمل قبل طلب عاملة.');
        return;
      }
      if (!_isPeriodBooking &&
          !_isRecurring &&
          state.assignmentMode == CleaningAssignmentMode.preferredWorker &&
          state.selectedWorkerIds.length != state.numberOfWorkers) {
        _bookingFeedback(
          'حدد ${state.numberOfWorkers} عامل من الذين تعاملت معهم سابقاً، أو اختر البحث التلقائي.',
        );
        return;
      }
      if (_isRecurring &&
          _recurringWorkerScope == CleaningRecurringWorkerScope.specific &&
          state.selectedWorkerIds.isEmpty) {
        _bookingFeedback(
          'يرجى اختيار عامل واحد على الأقل للحجز الدوري المحدد.',
        );
        return;
      }
      _priceNeedsRefresh = true;
      setState(() => _currentEstimate = null);
      _setScheduleStep(4);
      _requestUpdatedEstimate(state, force: true);
      return;
    }
    _onSubmitPressed(state);
  }

  Widget _buildWorkerSelectionSection({
    required ClMainState state,
    required ClMainBloc bloc,
    required EstimatePriceResponseModel? estimate,
  }) {
    final args = _routeArgs;
    if (args == null || _isPeriodBooking) return const SizedBox.shrink();

    if (_serviceExtras.openTime != null) {
      return const SizedBox.shrink();
    }

    if (_isRecurring &&
        _recurringWorkerScope == CleaningRecurringWorkerScope.any) {
      return const SizedBox.shrink();
    }

    if (_isRecurring &&
        _recurringWorkerScope == CleaningRecurringWorkerScope.specific) {
      return _buildScheduledPreviousWorkers(
        state: state,
        bloc: bloc,
        estimate: estimate,
        propertyType: args.propertyType,
        numberOfWorkersForDuration: _requiredWorkersCount(state),
      );
    }

    final roomUnits = enumerateRoomUnits(args.roomSizeBreakdown);
    final maxWorkers = (roomUnits.isEmpty ? 1 : roomUnits.length).clamp(
      1,
      ClServiceWorkerCountSelectorWidget.maxSupportedWorkers,
    );

    return Column(
      children: [
        ClServiceAssignmentModeSectionWidget(
          selectedMode: state.assignmentMode,
          onModeChanged: (mode) {
            if (mode == state.assignmentMode) return;
            if (mode == CleaningAssignmentMode.openCount) {
              final safeCount = state.numberOfWorkers.clamp(1, maxWorkers);
              bloc.add(SetAssignmentModeEvent(mode: mode));
              bloc.add(ClearWorkerRoomAssignmentsEvent());
              setState(() => _manualRoomAssignmentEnabled = false);
              _requestUpdatedEstimate(
                state.copyWith(
                  assignmentMode: mode,
                  numberOfWorkers: safeCount,
                  clearSelectedWorkers: true,
                  clearWorkerRoomAssignments: true,
                ),
                selectedWorkerIds: const <int>[],
              );
              return;
            }

            bloc.add(SetAssignmentModeEvent(mode: mode));
            bloc.add(ClearWorkerRoomAssignmentsEvent());
            setState(() => _manualRoomAssignmentEnabled = false);
            _requestUpdatedEstimate(
              state.copyWith(
                assignmentMode: mode,
                numberOfWorkers: 1,
                clearWorkerRoomAssignments: true,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        if (state.assignmentMode == CleaningAssignmentMode.preferredWorker) ...[
          ClServiceWorkerCountSelectorWidget(
            count: state.numberOfWorkers,
            maxCount: maxWorkers,
            onChanged: (count) {
              bloc.add(SetNumberOfWorkersEvent(count: count));
              _requestUpdatedEstimate(
                state.copyWith(
                  numberOfWorkers: count,
                  clearWorkerRoomAssignments: true,
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _workerDurationHint(state.numberOfWorkers, estimate),
          const SizedBox(height: 10),
          Text(
            'اختر من العمال السابقين نفس العدد المحدد أعلاه. عند اختيار أكثر من عامل سيُرسل الطلب إلى هؤلاء العمال تحديداً.',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
          const SizedBox(height: 10),
          _buildScheduledPreviousWorkers(
            state: state,
            estimate: estimate,
            maxSelectedWorkers: state.numberOfWorkers,
            bloc: bloc,
            propertyType: args.propertyType,
            numberOfWorkersForDuration: 1,
          ),
        ],
        if (state.assignmentMode == CleaningAssignmentMode.openCount) ...[
          ClServiceWorkerCountSelectorWidget(
            count: state.numberOfWorkers,
            maxCount: maxWorkers,
            onChanged: (count) {
              bloc.add(SetNumberOfWorkersEvent(count: count));
              if (!_manualRoomAssignmentEnabled) {
                bloc.add(ClearWorkerRoomAssignmentsEvent());
              }
              _requestUpdatedEstimate(
                state.copyWith(
                  assignmentMode: CleaningAssignmentMode.openCount,
                  numberOfWorkers: count,
                  clearSelectedWorkers: true,
                  clearWorkerRoomAssignments: !_manualRoomAssignmentEnabled,
                ),
                selectedWorkerIds: const <int>[],
              );
            },
          ),
          const SizedBox(height: 10),
          _workerDurationHint(state.numberOfWorkers, estimate),
        ],
        if (roomUnits.isNotEmpty &&
            (state.numberOfWorkers > 1 ||
                (state.assignmentMode ==
                        CleaningAssignmentMode.preferredWorker &&
                    state.selectedWorkerIds.isNotEmpty))) ...[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: SwitchListTile.adaptive(
              value: _manualRoomAssignmentEnabled,
              onChanged: (enabled) {
                setState(() => _manualRoomAssignmentEnabled = enabled);
                if (!enabled) {
                  bloc.add(ClearWorkerRoomAssignmentsEvent());
                  _requestUpdatedEstimate(
                    state.copyWith(clearWorkerRoomAssignments: true),
                  );
                }
              },
              title: const Text(
                'تحديد الغرف لكل عامل',
                textAlign: TextAlign.start,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: const Text(
                'اترك هذا الخيار مغلقاً إذا لم تكن لديك تفضيلات.',
                textAlign: TextAlign.start,
              ),
            ),
          ),
          if (_manualRoomAssignmentEnabled) ...[
            const SizedBox(height: 12),
            ClServiceWorkerRoomAssignmentWidget(
              units: roomUnits,
              numberOfWorkers: state.numberOfWorkers,
              slotByRoomKey: state.workerRoomAssignments,
              fieldErrors: state.assignmentFieldErrors,
              submittedAssignments: buildWorkerRoomAssignmentsJson(
                slotByRoomKey: state.workerRoomAssignments,
                units: roomUnits,
                preferredWorkerId: state.primarySelectedWorkerId,
                assignmentMode: state.numberOfWorkers > 1
                    ? CleaningAssignmentMode.openCount
                    : state.assignmentMode,
              ),
              onAssign: (roomKey, workerSlot) {
                bloc.add(
                  SetWorkerRoomSlotEvent(
                    roomKey: roomKey,
                    workerSlot: workerSlot,
                  ),
                );
                _requestUpdatedEstimate(
                  state.copyWith(
                    workerRoomAssignments: {
                      ...state.workerRoomAssignments,
                      roomKey: workerSlot,
                    },
                  ),
                );
              },
            ),
          ],
        ],
      ],
    );
  }

  /// Presentation-only duration derived from the last authoritative work estimate.
  /// Selecting more workers updates this immediately while the new quote loads.
  Widget _workerDurationHint(
    int workerCount,
    EstimatePriceResponseModel? estimate,
  ) {
    final workHours = _isRecurring
        ? _perVisitEstimatedHours(estimate)
        : (estimate?.size?.estimatedWorkHours ??
              _perVisitEstimatedHours(estimate));
    if (workHours <= 0) return const SizedBox.shrink();
    final totalMinutes = (workHours * 60).ceil();
    final durationMinutes = (totalMinutes / workerCount.clamp(1, 20)).ceil();
    final hourPart = durationMinutes ~/ 60;
    final minutePart = durationMinutes % 60;
    return Container(
      key: const Key('worker_duration_preview'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF7F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFB8DBD4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule_outlined, color: Color(0xFF006B60)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'مدة التنفيذ المتوقعة مع $workerCount عامل: $hourPart ساعة و$minutePart دقيقة',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF075A50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledPreviousWorkers({
    required ClMainState state,
    required ClMainBloc bloc,
    required EstimatePriceResponseModel? estimate,
    required String propertyType,
    required int numberOfWorkersForDuration,
    int? maxSelectedWorkers,
  }) {
    final estimatedHours = _perVisitEstimatedHours(estimate);
    final durationHours = _effectiveServiceHours(
      estimatedHours: estimatedHours,
      numberOfWorkers: numberOfWorkersForDuration,
    );
    if (state.estimatePriceStatus == BlocStatus.loading || durationHours <= 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: state.estimatePriceStatus == BlocStatus.loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const Text('تعذر تقدير مدة الخدمة. أعد تحميل التقدير.'),
                  TextButton.icon(
                    onPressed: () =>
                        _requestUpdatedEstimate(state, force: true),
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
      );
    }
    return ClScheduledPreviousWorkersSectionWidget(
      bloc: bloc,
      maxSelectedWorkers: maxSelectedWorkers,
      propertyType: propertyType,
      scheduledDate: CleaningScheduleDateTimeLogic.formatDateApi(_selectedDate),
      scheduledTime: _fromTimeHhMm,
      durationHours: durationHours,
      onSelectedWorkersChanged: (workerIds) => _requestUpdatedEstimate(
        state,
        selectedWorkerIds: workerIds,
        force: true,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didReadArgs) return;
    _didReadArgs = true;
    final args = widget.args ?? ModalRoute.of(context)?.settings.arguments;
    if (args is ClMainScheduleArgs) {
      _routeArgs = args;
      _bloc = args.bloc;
      if (args.roomUnits.isNotEmpty) {
        final previousPeriods = args.draft?['roomPeriodDrafts'];
        _roomPeriods = previousPeriods is CleaningRoomPeriodDrafts
            ? previousPeriods.reconcileRooms(
                args.roomUnits,
                defaultDate: DateTime.now().add(const Duration(days: 1)),
              )
            : CleaningRoomPeriodDrafts.fromRooms(
                args.roomUnits,
                date: DateTime.now().add(const Duration(days: 1)),
              );
        _isRecurring = false;
      }
      // Defensive reset for direct/reused navigation into this screen. The
      // create-order result belongs only to the current explicit submission.
      _bloc?.add(ResetCreateOrderStatusEvent());
      _currentEstimate = args.estimate;
      final draft = args.draft;
      if (draft != null && draft.isNotEmpty) {
        _scheduleStep = (draft['step'] as int? ?? 0).clamp(0, 4);
        _serviceExtras =
            draft['extras'] as CleaningServiceExtrasRequest? ?? _serviceExtras;
        _customerProvidesMaterials =
            draft['customerProvides'] as bool? ?? _customerProvidesMaterials;
        _missingMaterialTypeIds = Set<int>.from(
          draft['missingMaterialIds'] as Set<int>? ?? <int>{},
        );
        _selectedDate = draft['date'] as DateTime? ?? _selectedDate;
        _dateChosen = draft['dateChosen'] as bool? ?? _dateChosen;
        _timeChosen = draft['timeChosen'] as bool? ?? _timeChosen;
        _fromTimeHhMm = draft['time'] as String? ?? _fromTimeHhMm;
        _bookingNotesController.text = draft['notes'] as String? ?? '';
        _explicitGenderPreference =
            draft['gender'] as CleaningGenderPreference? ??
            _explicitGenderPreference;
        _isRecurring = draft['recurringEnabled'] as bool? ?? _isRecurring;
        _recurringPattern =
            draft['recurringPattern'] as CleaningRecurringPattern? ??
            _recurringPattern;
        _recurringSessions =
            draft['recurringSessions']
                as List<CleaningRecurringSessionInput>? ??
            _recurringSessions;
        _recurringCalculationMode =
            draft['recurringCalculationMode']
                as CleaningRecurringCalculationMode? ??
            _recurringCalculationMode;
        _recurringHoursPerVisit =
            draft['recurringHoursPerVisit'] as double? ??
            _recurringHoursPerVisit;
        _recurringWorkerScope =
            draft['recurringWorkerScope'] as CleaningRecurringWorkerScope? ??
            _recurringWorkerScope;
        _manualRoomAssignmentEnabled =
            draft['manualRoomAssignment'] as bool? ??
            _manualRoomAssignmentEnabled;
      }
      if (_isPeriodBooking) _isRecurring = false;
      // A restored worker/review step needs a fresh address- and worker-scoped
      // quote before exposing availability or payment figures.
      if (_scheduleStep >= 3) _currentEstimate = null;
      selectedAddress = ValueNotifier(
        (draft?['address'] as AddressListItem?) ??
            args.defaultAddress ??
            widget.item?.defaultAddress,
      );
      _syncToTime();
      final cachedMaterials = draft?['availableMaterialsCatalog'];
      if (cachedMaterials is List<CleaningMaterialLineModel>) {
        _availableMaterialsCatalog = cachedMaterials;
      }
      final cachedServices = draft?['specialServicesCatalog'];
      if (cachedServices is List<CleaningServiceModel>) {
        _availableSpecialServices = cachedServices;
        _specialServicesStatus = BlocStatus.success;
      } else {
        _loadSpecialServices();
      }
      final cachedConfig = draft?['suiteConfig'];
      if (cachedConfig is CleaningSuiteConfigModel) {
        _suiteConfig = cachedConfig;
      } else {
        _loadSuiteConfig();
      }
      // Restoring a booking draft never triggers a blocking overlay.
      // Fetch a fresh catalog only when the restored step needs one.
      if ((_scheduleStep == 0 &&
              _availableMaterialsCatalog.isEmpty &&
              (_currentEstimate?.availableMaterials.isEmpty ?? true)) ||
          (_scheduleStep >= 3)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _requestUpdatedEstimate(args.bloc.state, force: true);
        });
      }
    } else if (args is AddressListItem) {
      selectedAddress = ValueNotifier(args);
    }
  }

  @override
  void dispose() {
    final draft = _routeArgs?.draft;
    if (draft != null) {
      draft
        ..['step'] = _scheduleStep
        ..['roomPeriodDrafts'] = _roomPeriods
        ..['extras'] = _serviceExtras
        ..['customerProvides'] = _customerProvidesMaterials
        ..['missingMaterialIds'] = {..._missingMaterialTypeIds}
        ..['date'] = _selectedDate
        ..['dateChosen'] = _dateChosen
        ..['timeChosen'] = _timeChosen
        ..['time'] = _fromTimeHhMm
        ..['address'] = selectedAddress.value
        ..['notes'] = _bookingNotesController.text
        ..['gender'] = _explicitGenderPreference
        ..['recurringEnabled'] = _isRecurring
        ..['recurringPattern'] = _recurringPattern
        ..['recurringSessions'] = List<CleaningRecurringSessionInput>.of(
          _recurringSessions,
        )
        ..['recurringCalculationMode'] = _recurringCalculationMode
        ..['recurringHoursPerVisit'] = _recurringHoursPerVisit
        ..['recurringWorkerScope'] = _recurringWorkerScope
        ..['manualRoomAssignment'] = _manualRoomAssignmentEnabled;
    }
    _scheduleScrollController.dispose();
    _fromTimeController.dispose();
    _toTimeController.dispose();
    _couponController.dispose();
    _bookingNotesController.dispose();
    selectedAddress.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = CleaningScheduleDateTimeLogic.tomorrowDate();
    _fromTimeHhMm = '09:00';
    _toTimeHhMm = '09:00';
    _fromTimeController = TextEditingController(text: '');
    _toTimeController = TextEditingController(
      text: CleaningDateTimeUiFormat.time(_toTimeHhMm),
    );
    _couponController = TextEditingController();
  }

  void _updateTimeDisplay() {
    _fromTimeController.text = _timeChosen
        ? CleaningDateTimeUiFormat.time(_fromTimeHhMm)
        : '';
    _toTimeController.text = CleaningDateTimeUiFormat.time(_toTimeHhMm);
  }

  Future<void> _handleGenderPreferenceChanged(
    ClMainBloc bloc,
    CleaningGenderPreference preference,
  ) async {
    if (_loadingFemaleSafetyPolicy) return;
    final previous = _explicitGenderPreference;
    setState(() => _explicitGenderPreference = preference);
    if (preference != CleaningGenderPreference.female) {
      bloc.add(SetGenderPreferenceEvent(preference: preference));
      return;
    }

    setState(() => _loadingFemaleSafetyPolicy = true);
    final response = await getIt<ClMainRepo>().getFemaleWorkerSafetyPolicy();
    if (!mounted) return;
    setState(() => _loadingFemaleSafetyPolicy = false);
    if (_explicitGenderPreference != preference) return;

    await response.fold(
      (failure) async {
        setState(() => _explicitGenderPreference = previous);
        ToastComponent.showToast(context, msg: failure.message);
      },
      (policy) async {
        final confirmation = await showFemaleWorkerSafetyConfirmationSheet(
          context: context,
          policy: policy,
        );
        if (!mounted) return;
        if (confirmation == null) {
          setState(() => _explicitGenderPreference = previous);
          return;
        }
        bloc.add(
          SetGenderPreferenceEvent(
            preference: preference,
            workEnvironmentConfirmation: confirmation,
          ),
        );
      },
    );
  }

  Future<void> _applyCoupon(String code) async {
    final normalizedCode = code.trim();
    final args = _routeArgs;
    final state = _bloc?.state;
    final address = selectedAddress.value;

    if (normalizedCode.isEmpty) {
      setState(() {
        _couponStatus = ClCouponUiStatus.failed;
        _couponMessage = 'يرجى إدخال كود الحسم أولاً.';
        _appliedCouponCode = null;
        _appliedCouponDiscount = null;
        _appliedCouponTotal = null;
      });
      return;
    }
    if (args == null || state == null || address == null) {
      setState(() {
        _couponStatus = ClCouponUiStatus.failed;
        _couponMessage = 'يرجى إكمال بيانات الخدمة والعنوان أولاً.';
        _appliedCouponCode = null;
        _appliedCouponDiscount = null;
        _appliedCouponTotal = null;
      });
      return;
    }

    setState(() {
      _couponStatus = ClCouponUiStatus.loading;
      _couponMessage = null;
      _appliedCouponCode = null;
      _appliedCouponDiscount = null;
      _appliedCouponTotal = null;
    });

    final response = await getIt<CheckRestaurantCouponUseCase>()(
      CheckRestaurantCouponParams(
        couponCode: normalizedCode,
        section: 'cleaning',
        propertyType: args.propertyType,
        propertyDetails: _regularPropertyDetails(args, address),
        addressLatitude: address.latitude,
        addressLongitude: address.longitude,
        preferredWorkerId: state.primarySelectedWorkerId,
      ),
    );
    if (!mounted) return;

    response.fold(
      (failure) => setState(() {
        _couponStatus = ClCouponUiStatus.failed;
        _couponMessage = failure.message;
        _appliedCouponCode = null;
        _appliedCouponDiscount = null;
        _appliedCouponTotal = null;
      }),
      (result) {
        final data = result.data;
        if (data == null || !data.isAvailable) {
          setState(() {
            _couponStatus = ClCouponUiStatus.failed;
            _couponMessage = _couponReasonMessage(data?.reason);
            _appliedCouponCode = null;
            _appliedCouponDiscount = null;
            _appliedCouponTotal = null;
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
          _appliedCouponDiscount = data.amounts?.discount;
          _appliedCouponTotal = data.amounts?.total;
        });
      },
    );
  }

  Map<String, dynamic> _regularPropertyDetails(
    ClMainScheduleArgs args,
    AddressListItem address,
  ) {
    return {
      'address': address.line1,
      'location_name': address.label,
      'bedrooms': args.roomSizeBreakdown.legacyBedroomsCount,
      'rooms': args.roomSizeBreakdown.legacyRoomsCount,
      'bathrooms': args.roomSizeBreakdown.legacyBathroomsCount,
      'balconies': args.roomSizeBreakdown.legacyBalconiesCount,
      'living_room_size': args.roomSizeBreakdown.legacyLivingRoomSize,
      'room_size_breakdown': args.roomSizeBreakdown.toBackendJson(),
      if (args.roomCleaningModes.isNotEmpty)
        'room_cleaning_modes': args.roomCleaningModes,
      'cleaning_mode': args.cleaningType.cleaningModeValue,
    };
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
      'property_type_not_supported' => 'الكوبون لا يشمل نوع العقار المحدد.',
      'cleaning_mode_not_supported' => 'الكوبون لا يشمل نوع التنظيف المحدد.',
      _ => 'الكوبون غير صالح لبيانات هذا الطلب.',
    };
  }

  String _formatDiscount(double value) {
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
  }

  void _resetAppliedCoupon({String? message}) {
    _appliedCouponCode = null;
    _appliedCouponDiscount = null;
    _appliedCouponTotal = null;
    _couponStatus = ClCouponUiStatus.idle;
    _couponMessage = message;
  }

  Future<void> _pickDate() async {
    final tomorrow = CleaningScheduleDateTimeLogic.tomorrowDate();
    final value = await AppPickers.showAppDatePicker(
      context: context,
      startDate: tomorrow,
      initialDate: _selectedDate,
    );
    if (value.isEmpty) return;
    final selectedDate = CleaningScheduleDateTimeLogic.parseDateApi(value);
    if (selectedDate == null) return;
    if (_isRecurring && _recurringPattern.isGenerated) {
      final maxOccurrences =
          CleaningRecurringScheduleGenerator.maxOccurrencesWithinWindow(
            pattern: _recurringPattern,
            startDate: selectedDate,
          );
      if (_recurringOccurrences > maxOccurrences) {
        _showRecurringPatternDateLimit(maxOccurrences);
        return;
      }
    }
    setState(() {
      _selectedDate = selectedDate;
      _dateChosen = true;
      _replacePrimaryRecurringVisit();
      _replacePrimaryOpenTimeSession();
    });
    _requestRecurringEstimateIfPossible();
  }

  Future<void> _pickFromTime() async {
    final now = DateTime.now();
    final isToday =
        _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
    final value = await AppPickers.showAppTimePicker(
      context: context,
      minimumTime: isToday ? now.add(const Duration(hours: 1)) : null,
    );
    if (value.isEmpty) return;
    setState(() {
      _fromTimeHhMm = CleaningScheduleDateTimeLogic.normalizeTimeHhMm(value);
      _timeChosen = true;
      _replacePrimaryRecurringVisit();
      _replacePrimaryOpenTimeSession();
      _syncToTime();
    });
    _requestRecurringEstimateIfPossible();
  }

  List<CleaningRecurringSessionInput> get _recurringSessionsForRequest {
    if (!_isRecurring ||
        _recurringSessions.length < 2 ||
        _recurringSessions.exceedsMaxWindow) {
      return const <CleaningRecurringSessionInput>[];
    }
    return _recurringSessions.normalized;
  }

  double _perVisitEstimatedHours(EstimatePriceResponseModel? estimate) {
    if (_isRecurring) {
      final sessions = estimate?.schedule?.sessions;
      if (sessions != null && sessions.isNotEmpty && sessions.first.hours > 0) {
        return sessions.first.hours;
      }
      final total = estimate?.size?.estimatedHours ?? 0;
      final count = _recurringSessions.length;
      if (count >= 2 && total > 0) return total / count;
    }
    return estimate?.size?.estimatedHours ?? 0;
  }

  void _setRecurringEnabled(bool enabled, ClMainState state) {
    setState(() {
      _isRecurring = enabled;
      if (enabled) {
        _serviceExtras = _serviceExtras.copyWith(clearOpenTime: true);
        _openTimeSessions = const <CleaningOpenTimeSessionRequest>[];
      }
      _recurringPattern = CleaningRecurringPattern.custom;
      _recurringCalculationMode = CleaningRecurringCalculationMode.hours;
      _recurringWorkerScope = enabled && state.selectedWorkerIds.isNotEmpty
          ? CleaningRecurringWorkerScope.specific
          : CleaningRecurringWorkerScope.any;
      final estimatedVisitHours = _currentEstimate?.size?.estimatedHours ?? 2.0;
      final roundedHours =
          (estimatedVisitHours.clamp(1.0, 24.0) * 2).round() / 2;
      _recurringHoursPerVisit =
          normalizeCleaningRecurringHoursPerVisit(roundedHours) ?? 2;
      _recurringOccurrences = 2;
      _recurringSessions = enabled
          ? <CleaningRecurringSessionInput>[
              CleaningRecurringSessionInput(
                date: _selectedDate,
                time: _fromTimeHhMm,
              ),
            ]
          : const <CleaningRecurringSessionInput>[];
      _resetAppliedCoupon(message: 'تم تغيير نمط الحجز. أعد تطبيق الكوبون.');
    });
    _requestUpdatedEstimate(state);
  }

  void _setRecurringWorkerScope(
    CleaningRecurringWorkerScope scope,
    ClMainState state,
  ) {
    if (!_isRecurring || scope == _recurringWorkerScope) return;
    setState(() {
      _recurringWorkerScope = scope;
      _resetAppliedCoupon(message: 'تم تغيير نطاق العمال. أعد تطبيق الكوبون.');
    });
    if (scope == CleaningRecurringWorkerScope.any) {
      _bloc?.add(ClearPreferredWorkersEvent());
      _requestUpdatedEstimate(
        state,
        selectedWorkerIds: const <int>[],
        force: _scheduleStep >= 3,
      );
      return;
    }
    _requestUpdatedEstimate(state, force: _scheduleStep >= 3);
  }

  void _setRecurringCalculationMode(
    CleaningRecurringCalculationMode mode,
    ClMainState state,
  ) {
    if (mode == _recurringCalculationMode) return;
    setState(() {
      _recurringCalculationMode = mode;
      _resetAppliedCoupon(
        message: 'تم تغيير طريقة احتساب الزيارات. أعد تطبيق الكوبون.',
      );
    });
    _requestUpdatedEstimate(state);
  }

  void _setRecurringHoursPerVisit(double hours, ClMainState state) {
    final normalized = normalizeCleaningRecurringHoursPerVisit(hours);
    if (normalized == null || normalized == _recurringHoursPerVisit) return;
    setState(() {
      _recurringHoursPerVisit = normalized;
      _resetAppliedCoupon(
        message: 'تم تغيير ساعات الزيارة. أعد تطبيق الكوبون.',
      );
    });
    _requestUpdatedEstimate(state);
  }

  int get _recurringMaxOccurrences {
    if (!_recurringPattern.isGenerated) return 0;
    return CleaningRecurringScheduleGenerator.maxOccurrencesWithinWindow(
      pattern: _recurringPattern,
      startDate: _selectedDate,
    );
  }

  void _setRecurringPattern(
    CleaningRecurringPattern pattern,
    ClMainState state,
  ) {
    if (pattern == _recurringPattern) return;

    if (!pattern.isGenerated) {
      setState(() {
        _recurringPattern = pattern;
        _recurringOccurrences = _recurringSessions.length < 2
            ? 2
            : _recurringSessions.length;
        _resetAppliedCoupon(
          message: 'تم تغيير نمط التكرار. أعد تطبيق الكوبون.',
        );
      });
      _requestUpdatedEstimate(state);
      return;
    }

    final maxOccurrences =
        CleaningRecurringScheduleGenerator.maxOccurrencesWithinWindow(
          pattern: pattern,
          startDate: _selectedDate,
        );
    if (maxOccurrences < 2) {
      _showRecurringPatternDateLimit(maxOccurrences);
      return;
    }

    final generated = CleaningRecurringScheduleGenerator.generate(
      pattern: pattern,
      startDate: _selectedDate,
      time: _fromTimeHhMm,
      occurrences: 2,
    );
    setState(() {
      _recurringPattern = pattern;
      _recurringOccurrences = 2;
      _recurringSessions = generated;
      _syncToTime();
      _resetAppliedCoupon(message: 'تم تغيير نمط التكرار. أعد تطبيق الكوبون.');
    });
    _requestUpdatedEstimate(state);
  }

  void _setRecurringOccurrences(int occurrences, ClMainState state) {
    if (!_recurringPattern.isGenerated || occurrences < 2) return;
    final maxOccurrences = _recurringMaxOccurrences;
    if (occurrences > maxOccurrences) {
      _showRecurringPatternDateLimit(maxOccurrences);
      return;
    }

    final generated = CleaningRecurringScheduleGenerator.generate(
      pattern: _recurringPattern,
      startDate: _selectedDate,
      time: _fromTimeHhMm,
      occurrences: occurrences,
    );
    setState(() {
      _recurringOccurrences = occurrences;
      _recurringSessions = generated;
      _syncToTime();
      _resetAppliedCoupon(message: 'تم تحديث عدد الزيارات. أعد تطبيق الكوبون.');
    });
    _requestUpdatedEstimate(state);
  }

  Future<void> _addRecurringVisit(ClMainState state) async {
    if (_recurringPattern != CleaningRecurringPattern.custom) return;
    final tomorrow = CleaningScheduleDateTimeLogic.tomorrowDate();
    final initialDate = _recurringSessions.isEmpty
        ? _selectedDate
        : _recurringSessions.last.date.add(const Duration(days: 7));
    final dateValue = await AppPickers.showAppDatePicker(
      context: context,
      startDate: tomorrow,
      initialDate: initialDate,
    );
    if (!mounted || dateValue.isEmpty) return;
    final date = CleaningScheduleDateTimeLogic.parseDateApi(dateValue);
    if (date == null) return;

    final timeValue = await AppPickers.showAppTimePicker(context: context);
    if (!mounted || timeValue.isEmpty) return;
    final time = CleaningScheduleDateTimeLogic.normalizeTimeHhMm(timeValue);
    final next = CleaningRecurringSessionInput(date: date, time: time);
    if (_recurringSessions.any((session) => session.slotKey == next.slotKey)) {
      _showDuplicateRecurringVisit();
      return;
    }

    final proposed = <CleaningRecurringSessionInput>[
      ..._recurringSessions,
      next,
    ];
    if (proposed.exceedsMaxWindow) {
      _showRecurringWindowLimit();
      return;
    }

    _applyRecurringSessions(proposed);
    _requestUpdatedEstimate(state);
  }

  Future<void> _editRecurringVisit(int index, ClMainState state) async {
    if (_recurringPattern != CleaningRecurringPattern.custom) return;
    if (index < 0 || index >= _recurringSessions.length) return;
    final current = _recurringSessions[index];
    final tomorrow = CleaningScheduleDateTimeLogic.tomorrowDate();
    final dateValue = await AppPickers.showAppDatePicker(
      context: context,
      startDate: tomorrow,
      initialDate: current.date,
    );
    if (!mounted || dateValue.isEmpty) return;
    final date = CleaningScheduleDateTimeLogic.parseDateApi(dateValue);
    if (date == null) return;

    final timeValue = await AppPickers.showAppTimePicker(context: context);
    if (!mounted || timeValue.isEmpty) return;
    final time = CleaningScheduleDateTimeLogic.normalizeTimeHhMm(timeValue);
    final replacement = CleaningRecurringSessionInput(date: date, time: time);
    final duplicated = _recurringSessions.indexed.any(
      (entry) => entry.$1 != index && entry.$2.slotKey == replacement.slotKey,
    );
    if (duplicated) {
      _showDuplicateRecurringVisit();
      return;
    }

    final next = _recurringSessions.toList(growable: false);
    final edited = <CleaningRecurringSessionInput>[...next];
    edited[index] = replacement;
    if (edited.exceedsMaxWindow) {
      _showRecurringWindowLimit();
      return;
    }
    _applyRecurringSessions(edited);
    _requestUpdatedEstimate(state);
  }

  void _removeRecurringVisit(int index, ClMainState state) {
    if (_recurringPattern != CleaningRecurringPattern.custom) return;
    if (index <= 0 || index >= _recurringSessions.length) return;
    final next = <CleaningRecurringSessionInput>[..._recurringSessions]
      ..removeAt(index);
    _applyRecurringSessions(next);
    _requestUpdatedEstimate(state);
  }

  void _applyRecurringSessions(List<CleaningRecurringSessionInput> sessions) {
    setState(() {
      _recurringSessions = sessions.normalized;
      if (_recurringSessions.isNotEmpty) {
        final first = _recurringSessions.first;
        _selectedDate = first.date;
        _fromTimeHhMm = first.time;
      }
      _syncToTime();
      _resetAppliedCoupon(message: 'تم تحديث الزيارات. أعد تطبيق الكوبون.');
    });
  }

  void _replacePrimaryRecurringVisit() {
    if (!_isRecurring || _recurringSessions.isEmpty) return;

    if (_recurringPattern.isGenerated) {
      _recurringSessions = CleaningRecurringScheduleGenerator.generate(
        pattern: _recurringPattern,
        startDate: _selectedDate,
        time: _fromTimeHhMm,
        occurrences: _recurringOccurrences,
      );
      return;
    }

    final updated = <CleaningRecurringSessionInput>[..._recurringSessions];
    updated[0] = CleaningRecurringSessionInput(
      date: _selectedDate,
      time: _fromTimeHhMm,
    );
    _recurringSessions = updated.normalized;
    final first = _recurringSessions.first;
    _selectedDate = first.date;
    _fromTimeHhMm = first.time;
  }

  void _requestRecurringEstimateIfPossible() {
    if (!_isRecurring ||
        _recurringSessions.length < 2 ||
        _recurringSessions.exceedsMaxWindow) {
      return;
    }
    final bloc = _bloc;
    if (bloc != null) _requestUpdatedEstimate(bloc.state);
  }

  void _showDuplicateRecurringVisit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('لا يمكن إضافة نفس تاريخ ووقت الزيارة مرتين.'),
      ),
    );
  }

  void _showRecurringWindowLimit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'يجب أن تقع جميع زيارات الحجز الدوري ضمن فترة لا تتجاوز 30 يوماً.',
        ),
      ),
    );
  }

  void _showRecurringPatternDateLimit(int maxOccurrences) {
    final message = maxOccurrences >= 2
        ? 'التاريخ المختار يسمح بحد أقصى $maxOccurrences زيارات لهذا النمط ضمن 30 يوماً.'
        : 'لا يمكن إنشاء زيارة ثانية لهذا النمط من التاريخ المختار ضمن نافذة 30 يوماً.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _syncToTime() {
    final estimate = _currentEstimate;
    final estimatedHours = _perVisitEstimatedHours(estimate);
    final blocState = _bloc?.state;
    final numberOfWorkers = blocState == null
        ? 1
        : _requiredWorkersCount(blocState);
    _toTimeHhMm = formatClServiceEndTime(
      startTime: _fromTimeHhMm,
      durationHours: _effectiveServiceHours(
        estimatedHours: estimatedHours,
        numberOfWorkers: numberOfWorkers,
      ),
    );
    _updateTimeDisplay();
  }

  int _requiredWorkersCount(ClMainState state) {
    if (_isRecurring &&
        _recurringWorkerScope == CleaningRecurringWorkerScope.specific) {
      return state.selectedWorkerIds.isEmpty
          ? 1
          : state.selectedWorkerIds.length;
    }
    final openCount = state.numberOfWorkers < 1 ? 1 : state.numberOfWorkers;
    final preferredCount = _isRecurring ? 0 : state.selectedWorkerIds.length;
    return preferredCount > openCount ? preferredCount : openCount;
  }

  double _effectiveServiceHours({
    required double estimatedHours,
    required int numberOfWorkers,
  }) {
    return effectiveCleaningWorkerDurationHours(
      estimatedHours: estimatedHours,
      numberOfWorkers: numberOfWorkers,
    );
  }

  Future<void> _loadSpecialServices() async {
    if (!mounted) return;
    setState(() {
      _specialServicesStatus = BlocStatus.loading;
      _specialServicesErrorMessage = null;
    });
    final response = await getIt<GetCleaningServicesUseCase>()(
      GetCleaningServicesParams(category: 'special_service'),
    );
    if (!mounted) return;
    response.fold(
      (failure) => setState(() {
        _specialServicesStatus = BlocStatus.failed;
        _specialServicesErrorMessage = failure.message;
      }),
      (result) {
        final catalog = result.data
            .where(
              (service) =>
                  service.id != null && service.name?.trim().isNotEmpty == true,
            )
            .toList(growable: false);
        setState(() {
          _specialServicesStatus = BlocStatus.success;
          _specialServicesErrorMessage = null;
          _availableSpecialServices = catalog;
          _routeArgs?.draft?['specialServicesCatalog'] = catalog;
          _serviceExtras = _serviceExtras.copyWith(
            specialServices: _normalizeSpecialServicesForCatalog(
              _serviceExtras.specialServices,
              catalog,
            ),
          );
        });
      },
    );
  }

  Future<void> _loadSuiteConfig() async {
    try {
      final config = await getIt<ClMainRemoteDataSource>()
          .getCleaningSuiteConfig();
      if (!mounted) return;
      setState(() {
        _suiteConfig = config;
        _routeArgs?.draft?['suiteConfig'] = config;
        final current = _serviceExtras.openTime;
        if (current != null &&
            !config.openTime.durationOptions.contains(
              current.expectedMaxMinutes,
            )) {
          _serviceExtras = _serviceExtras.copyWith(
            openTime: current.copyWith(
              expectedMaxMinutes: config.openTime.legacyDefaultMinutes,
            ),
          );
        }
      });
    } catch (_) {
      // The v1 fallback policy keeps older servers and cached flows usable.
    }
  }

  List<CleaningSpecialServiceRequest> _normalizeSpecialServicesForCatalog(
    List<CleaningSpecialServiceRequest> requests,
    List<CleaningServiceModel> catalog,
  ) {
    if (requests.isEmpty || catalog.isEmpty) return requests;
    return requests
        .map((request) {
          CleaningServiceModel? selected;
          for (final service in catalog) {
            if (service.id == request.specialServiceId) {
              selected = service;
              break;
            }
          }
          if (selected == null) return request;
          final normalized = selected.normalizeDirtinessLevel(
            request.dirtinessLevel,
          );
          if (normalized == request.dirtinessLevel) return request;
          return request.copyWith(dirtinessLevel: normalized);
        })
        .toList(growable: false);
  }

  void _updateServiceExtras(
    CleaningServiceExtrasRequest extras,
    ClMainState state,
  ) {
    setState(() {
      _serviceExtras = extras;
      _resetAppliedCoupon(
        message: 'تم تغيير إضافات الخدمة. أعد تطبيق الكوبون.',
      );
    });
    _requestUpdatedEstimate(state);
  }

  void _setMaterialsProvider(bool customerProvides, ClMainState state) {
    setState(() => _customerProvidesMaterials = customerProvides);
    final ids = customerProvides ? _missingMaterialTypeIds.toList() : null;
    _updateServiceExtras(
      _serviceExtras.copyWith(
        requestMaterials: !customerProvides || (ids?.isNotEmpty ?? false),
        materialTypeIds: ids,
        clearMaterialTypeIds: !customerProvides,
      ),
      state,
    );
  }

  void _setMissingMaterialTypes(Set<int> ids, ClMainState state) {
    final availableIds =
        (_availableMaterialsCatalog.isNotEmpty
                ? _availableMaterialsCatalog
                : _currentEstimate?.availableMaterials ??
                      const <CleaningMaterialLineModel>[])
            .map((e) => e.materialTypeId)
            .whereType<int>()
            .toSet();
    final validIds = ids.intersection(availableIds);
    setState(() {
      _customerProvidesMaterials = true;
      _missingMaterialTypeIds = validIds;
    });
    _updateServiceExtras(
      _serviceExtras.copyWith(
        requestMaterials: validIds.isNotEmpty,
        materialTypeIds: validIds.toList()..sort(),
      ),
      state,
    );
  }

  void _toggleSpecialServiceById(int id, ClMainState state) {
    final existing = _serviceExtras.specialServices;
    final selectedIndex = existing.indexWhere((e) => e.specialServiceId == id);
    if (selectedIndex >= 0) {
      _removeSpecialService(selectedIndex, state);
      return;
    }
    if (existing.length >= 10) {
      _bookingFeedback('يمكنك إضافة 10 خدمات متخصصة كحد أقصى.');
      return;
    }
    final matched = _availableSpecialServices.where((e) => e.id == id);
    if (matched.isEmpty) return;
    final service = matched.first;
    _updateServiceExtras(
      _serviceExtras.copyWith(
        specialServices: [
          ...existing,
          CleaningSpecialServiceRequest(
            specialServiceId: id,
            quantity: 1,
            dirtinessLevel: service.normalizeDirtinessLevel(null),
            items: [
              CleaningSpecialServiceItemRequest(
                quantity: 1,
                dirtinessLevelId: service.dirtinessRules
                    .map((rule) => rule.id)
                    .whereType<int>()
                    .firstOrNull,
              ),
            ],
            sessionIds: _isRecurring
                ? List<int>.generate(
                    _recurringSessions.length,
                    (index) => index + 1,
                  )
                : const <int>[],
          ),
        ],
      ),
      state,
    );
  }

  void _addSpecialService(ClMainState state) {
    if (_serviceExtras.openTime != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يمكن جمع الخدمات الخاصة مع طلب الوقت المفتوح.'),
        ),
      );
      return;
    }
    final selectedIds = _serviceExtras.specialServices
        .map((service) => service.specialServiceId)
        .toSet();
    final firstService = _availableSpecialServices.firstWhere(
      (service) => service.id != null && !selectedIds.contains(service.id),
      orElse: () => const CleaningServiceModel(),
    );
    final id = firstService.id;
    if (id == null) {
      _bookingFeedback('أضفت كل الخدمات المتخصصة المتاحة.');
      return;
    }
    _updateServiceExtras(
      _serviceExtras.copyWith(
        specialServices: <CleaningSpecialServiceRequest>[
          ..._serviceExtras.specialServices,
          CleaningSpecialServiceRequest(
            specialServiceId: id,
            quantity: 1,
            dirtinessLevel: firstService.normalizeDirtinessLevel(null),
            items: <CleaningSpecialServiceItemRequest>[
              CleaningSpecialServiceItemRequest(
                quantity: 1,
                dirtinessLevelId: firstService.dirtinessRules
                    .map((rule) => rule.id)
                    .whereType<int>()
                    .firstOrNull,
              ),
            ],
            sessionIds: _isRecurring
                ? List<int>.generate(
                    _recurringSessions.length,
                    (index) => index + 1,
                  )
                : const <int>[],
          ),
        ],
      ),
      state,
    );
  }

  void _replaceSpecialService(
    int index,
    CleaningSpecialServiceRequest service,
    ClMainState state,
  ) {
    if (index < 0 || index >= _serviceExtras.specialServices.length) return;
    if (_serviceExtras.specialServices.asMap().entries.any(
      (entry) =>
          entry.key != index &&
          entry.value.specialServiceId == service.specialServiceId,
    )) {
      _bookingFeedback(
        'هذه الخدمة المتخصصة مضافة بالفعل. عدّل كميتها بدلاً من تكرارها.',
      );
      return;
    }
    CleaningServiceModel? catalogService;
    for (final item in _availableSpecialServices) {
      if (item.id == service.specialServiceId) {
        catalogService = item;
        break;
      }
    }
    final normalizedService = catalogService == null
        ? service
        : service.copyWith(
            dirtinessLevel: catalogService.normalizeDirtinessLevel(
              service.dirtinessLevel,
            ),
          );
    final services = List<CleaningSpecialServiceRequest>.of(
      _serviceExtras.specialServices,
    );
    services[index] = normalizedService;
    _updateServiceExtras(
      _serviceExtras.copyWith(specialServices: services),
      state,
    );
  }

  void _removeSpecialService(int index, ClMainState state) {
    if (index < 0 || index >= _serviceExtras.specialServices.length) return;
    final services = List<CleaningSpecialServiceRequest>.of(
      _serviceExtras.specialServices,
    )..removeAt(index);
    _updateServiceExtras(
      _serviceExtras.copyWith(specialServices: services),
      state,
    );
  }

  void _setOpenTimeEnabled(bool enabled, ClMainState state) {
    final minutes =
        _suiteConfig.openTime.durationOptions.firstOrNull ??
        _suiteConfig.openTime.legacyDefaultMinutes;
    setState(() {
      if (enabled) {
        _isRecurring = false;
        _recurringSessions = const <CleaningRecurringSessionInput>[];
        _openTimeSessions = <CleaningOpenTimeSessionRequest>[
          CleaningOpenTimeSessionRequest(
            date: CleaningScheduleDateTimeLogic.formatDateApi(_selectedDate),
            time: _fromTimeHhMm,
            expectedMaxMinutes: minutes,
          ),
        ];
        _serviceExtras = CleaningServiceExtrasRequest(
          openTime: CleaningOpenTimeRequest(
            workerCount: state.numberOfWorkers < 1 ? 1 : state.numberOfWorkers,
            expectedMaxMinutes: minutes,
          ),
        );
      } else {
        _openTimeSessions = const <CleaningOpenTimeSessionRequest>[];
        _serviceExtras = _serviceExtras.copyWith(clearOpenTime: true);
      }
      _resetAppliedCoupon(message: 'تم تغيير نمط الطلب. أعد تطبيق الكوبون.');
    });
    _requestUpdatedEstimate(state);
  }

  void _setMaterialsRequested(bool value, ClMainState state) {
    if (value && _serviceExtras.openTime != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يمكن جمع مواد التنظيف مع طلب الوقت المفتوح.'),
        ),
      );
      return;
    }
    _updateServiceExtras(
      _serviceExtras.copyWith(requestMaterials: value),
      state,
    );
  }

  void _setOpenTimeWorkerCount(int count, ClMainState state) {
    if (_serviceExtras.openTime == null || count < 1) return;
    _updateServiceExtras(
      _serviceExtras.copyWith(
        openTime: _serviceExtras.openTime!.copyWith(workerCount: count),
      ),
      state,
    );
  }

  void _setOpenTimeExpectedMaxMinutes(int minutes, ClMainState state) {
    final current = _serviceExtras.openTime;
    if (current == null ||
        !_suiteConfig.openTime.durationOptions.contains(minutes)) {
      return;
    }
    final sessions = <CleaningOpenTimeSessionRequest>[
      for (var index = 0; index < _openTimeSessions.length; index++)
        index == 0
            ? CleaningOpenTimeSessionRequest(
                date: _openTimeSessions[index].date,
                time: _openTimeSessions[index].time,
                expectedMaxMinutes: minutes,
              )
            : _openTimeSessions[index],
    ];
    _updateServiceExtras(
      _serviceExtras.copyWith(
        openTime: current.copyWith(
          expectedMaxMinutes: minutes,
          sessions: sessions.length > 1
              ? sessions
              : const <CleaningOpenTimeSessionRequest>[],
        ),
      ),
      state,
    );
    setState(() => _openTimeSessions = sessions);
  }

  Future<void> _addOpenTimeSession(ClMainState state) async {
    if (_serviceExtras.openTime == null || _openTimeSessions.length >= 30) {
      return;
    }
    final tomorrow = CleaningScheduleDateTimeLogic.tomorrowDate();
    final lastDate = _openTimeSessions.isEmpty
        ? _selectedDate
        : DateTime.tryParse(_openTimeSessions.last.date) ?? _selectedDate;
    final dateValue = await AppPickers.showAppDatePicker(
      context: context,
      startDate: tomorrow,
      initialDate: lastDate.add(const Duration(days: 1)),
    );
    if (!mounted || dateValue.isEmpty) return;
    final date = CleaningScheduleDateTimeLogic.parseDateApi(dateValue);
    if (date == null) return;

    final timeValue = await AppPickers.showAppTimePicker(context: context);
    if (!mounted || timeValue.isEmpty) return;
    final next = CleaningOpenTimeSessionRequest(
      date: CleaningScheduleDateTimeLogic.formatDateApi(date),
      time: CleaningScheduleDateTimeLogic.normalizeTimeHhMm(timeValue),
      expectedMaxMinutes: _serviceExtras.openTime!.expectedMaxMinutes,
    );
    if (_openTimeSessions.any(
      (session) => session.date == next.date && session.time == next.time,
    )) {
      _showDuplicateOpenTimeSession();
      return;
    }

    _applyOpenTimeSessions(<CleaningOpenTimeSessionRequest>[
      ..._openTimeSessions,
      next,
    ], state);
  }

  Future<void> _editOpenTimeSession(int index, ClMainState state) async {
    if (_serviceExtras.openTime == null ||
        index < 0 ||
        index >= _openTimeSessions.length) {
      return;
    }
    final current = _openTimeSessions[index];
    final tomorrow = CleaningScheduleDateTimeLogic.tomorrowDate();
    final dateValue = await AppPickers.showAppDatePicker(
      context: context,
      startDate: tomorrow,
      initialDate: DateTime.tryParse(current.date) ?? _selectedDate,
    );
    if (!mounted || dateValue.isEmpty) return;
    final date = CleaningScheduleDateTimeLogic.parseDateApi(dateValue);
    if (date == null) return;

    final timeValue = await AppPickers.showAppTimePicker(context: context);
    if (!mounted || timeValue.isEmpty) return;
    final replacement = CleaningOpenTimeSessionRequest(
      date: CleaningScheduleDateTimeLogic.formatDateApi(date),
      time: CleaningScheduleDateTimeLogic.normalizeTimeHhMm(timeValue),
      expectedMaxMinutes: current.expectedMaxMinutes,
    );
    if (_openTimeSessions.indexed.any(
      (entry) =>
          entry.$1 != index &&
          entry.$2.date == replacement.date &&
          entry.$2.time == replacement.time,
    )) {
      _showDuplicateOpenTimeSession();
      return;
    }

    final sessions = <CleaningOpenTimeSessionRequest>[..._openTimeSessions];
    sessions[index] = replacement;
    _applyOpenTimeSessions(sessions, state);
  }

  void _removeOpenTimeSession(int index, ClMainState state) {
    if (index <= 0 || index >= _openTimeSessions.length) return;
    final sessions = <CleaningOpenTimeSessionRequest>[..._openTimeSessions]
      ..removeAt(index);
    _applyOpenTimeSessions(sessions, state);
  }

  void _setOpenTimeSessionDuration(int index, int minutes, ClMainState state) {
    if (index < 0 ||
        index >= _openTimeSessions.length ||
        !_suiteConfig.openTime.durationOptions.contains(minutes)) {
      return;
    }
    final current = _openTimeSessions[index];
    final sessions = <CleaningOpenTimeSessionRequest>[..._openTimeSessions];
    sessions[index] = CleaningOpenTimeSessionRequest(
      date: current.date,
      time: current.time,
      expectedMaxMinutes: minutes,
    );
    _applyOpenTimeSessions(sessions, state, updatePrimaryDateTime: false);
  }

  void _applyOpenTimeSessions(
    List<CleaningOpenTimeSessionRequest> sessions,
    ClMainState state, {
    bool updatePrimaryDateTime = true,
  }) {
    final current = _serviceExtras.openTime;
    if (current == null || sessions.isEmpty) return;
    final normalized = <CleaningOpenTimeSessionRequest>[...sessions]
      ..sort((left, right) {
        final dateCompare = left.date.compareTo(right.date);
        return dateCompare != 0 ? dateCompare : left.time.compareTo(right.time);
      });

    setState(() {
      _openTimeSessions = normalized;
      if (updatePrimaryDateTime) {
        final first = normalized.first;
        _selectedDate = DateTime.tryParse(first.date) ?? _selectedDate;
        _fromTimeHhMm = first.time;
        _syncToTime();
      }
      _serviceExtras = _serviceExtras.copyWith(
        openTime: current.copyWith(
          expectedMaxMinutes:
              normalized.first.expectedMaxMinutes ?? current.expectedMaxMinutes,
          sessions: normalized.length > 1
              ? normalized
              : const <CleaningOpenTimeSessionRequest>[],
        ),
      );
      _resetAppliedCoupon(
        message: 'تم تحديث جلسات الوقت المفتوح. أعد تطبيق الكوبون.',
      );
    });
    _requestUpdatedEstimate(state);
  }

  void _replacePrimaryOpenTimeSession() {
    if (_serviceExtras.openTime == null || _openTimeSessions.isEmpty) return;
    final current = _openTimeSessions.first;
    _openTimeSessions = <CleaningOpenTimeSessionRequest>[
      CleaningOpenTimeSessionRequest(
        date: CleaningScheduleDateTimeLogic.formatDateApi(_selectedDate),
        time: _fromTimeHhMm,
        expectedMaxMinutes: current.expectedMaxMinutes,
      ),
      ..._openTimeSessions.skip(1),
    ];
    _serviceExtras = _serviceExtras.copyWith(
      openTime: _serviceExtras.openTime!.copyWith(
        sessions: _openTimeSessions.length > 1
            ? _openTimeSessions
            : const <CleaningOpenTimeSessionRequest>[],
      ),
    );
  }

  void _showDuplicateOpenTimeSession() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('هذا التاريخ والوقت مضافان مسبقاً للطلب المفتوح.'),
      ),
    );
  }

  Future<void> _onSubmitPressed(ClMainState state) async {
    if (_submissionRequested ||
        _confirmationOpen ||
        state.createOrderStatus == BlocStatus.loading) {
      return;
    }
    if (_priceNeedsRefresh ||
        state.estimatePriceStatus == BlocStatus.loading ||
        state.estimatePriceStatus == BlocStatus.failed ||
        _currentEstimate?.pricing == null) {
      _bookingFeedback('يرجى تحديث تكلفة الخدمة قبل إرسال الطلب.');
      return;
    }
    if (_isPeriodBooking && _currentEstimate?.quoteSignature == null) {
      _bookingFeedback('انتظر تحديث السعر النهائي للفترات');
      return;
    }
    if (!_isPeriodBooking && !_dateChosen) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى اختيار تاريخ الخدمة')));
      return;
    }
    if (!_isPeriodBooking && !_timeChosen) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار وقت بدء الخدمة')),
      );
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
      ).showSnackBar(const SnackBar(content: Text('بيانات الطلب غير مكتملة')));
      return;
    }

    final address = selectedAddress.value;
    final addressId = int.tryParse(address?.id ?? '') ?? 0;
    if (address == null || addressId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار عنوان الخدمة أولاً')),
      );
      return;
    }
    if (!address.hasCompleteServiceLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى اختيار عنوان يحتوي على موقع محدد على الخريطة وعنوان واضح',
          ),
        ),
      );
      return;
    }

    if (state.genderPreference.apiValue == 'female' &&
        state.safetyConfirmation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تأكيد بيئة العمل قبل طلب عاملة')),
      );
      return;
    }

    if (_isRecurring &&
        _recurringWorkerScope == CleaningRecurringWorkerScope.specific &&
        state.selectedWorkerIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار عامل واحد على الأقل للحجز الدوري المحدد.'),
        ),
      );
      return;
    }

    final estimateForWorkers = _currentEstimate;
    final estimatedHours = _perVisitEstimatedHours(estimateForWorkers);
    final selectedWorkers =
        _serviceExtras.openTime?.workerCount ?? _requiredWorkersCount(state);
    final requiredWorkers =
        estimateForWorkers?.requiredWorkers ??
        (estimatedHours <= 0 ? 1 : (estimatedHours / 8).ceil());

    if (!_isPeriodBooking && selectedWorkers < requiredWorkers) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'هذا الطلب يحتاج إلى $requiredWorkers عمال على الأقل. غيّر العدد ثم تابع.',
          ),
        ),
      );
      return;
    }

    if (_isRecurring && _recurringSessions.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الحجز الدوري يحتاج إلى زيارتين على الأقل.'),
        ),
      );
      return;
    }

    if (_isRecurring && _recurringSessions.exceedsMaxWindow) {
      _showRecurringWindowLimit();
      return;
    }

    final approvedPrice =
        _appliedCouponTotal ?? _currentEstimate?.pricing?.totalPrice;
    _confirmationOpen = true;
    final acceptedPledge = await _showPersonalPropertyPledgeDialog();
    _confirmationOpen = false;
    if (!mounted ||
        !acceptedPledge ||
        _submissionRequested ||
        bloc.state.createOrderStatus == BlocStatus.loading) {
      return;
    }
    final currentPrice =
        _appliedCouponTotal ?? _currentEstimate?.pricing?.totalPrice;
    if (!V6BookingQuoteGuard.canSubmit(
      confirmedTotal: approvedPrice,
      currentTotal: currentPrice,
      estimateRefreshing: bloc.state.estimatePriceStatus == BlocStatus.loading,
      estimateFailed: bloc.state.estimatePriceStatus == BlocStatus.failed,
    )) {
      _bookingFeedback(
        'تم تحديث تقدير التكلفة. راجع السعر الجديد ثم أكد الطلب مرة أخرى.',
      );
      return;
    }
    _submissionRequested = true;

    final estimate = _currentEstimate;
    final selectedWorkerIds =
        _serviceExtras.openTime != null ||
            (_isRecurring &&
                _recurringWorkerScope == CleaningRecurringWorkerScope.any)
        ? const <int>[]
        : state.selectedWorkerIds;
    final requestAssignmentMode = _serviceExtras.openTime != null
        ? CleaningAssignmentMode.openCount
        : _isRecurring
        ? (_recurringWorkerScope == CleaningRecurringWorkerScope.any
              ? CleaningAssignmentMode.openCount
              : (selectedWorkerIds.length <= 1
                    ? CleaningAssignmentMode.preferredWorker
                    : CleaningAssignmentMode.openCount))
        : state.assignmentMode;
    final normalizedAssignments = estimate?.workerRoomAssignments ?? const [];
    final explicitAssignments = buildWorkerRoomAssignmentsJson(
      slotByRoomKey: state.workerRoomAssignments,
      units: enumerateRoomUnits(args.roomSizeBreakdown),
      preferredWorkerId: selectedWorkerIds.length == 1
          ? selectedWorkerIds.first
          : null,
      assignmentMode: requestAssignmentMode,
    );
    final workerRoomAssignments =
        _manualRoomAssignmentEnabled && explicitAssignments.isNotEmpty
        ? explicitAssignments
        : normalizedAssignments.isNotEmpty
        ? workerRoomAssignmentsToRequestJson(normalizedAssignments)
        : explicitAssignments;

    bloc.add(
      CreateCleaningOrderEvent(
        params: CreateCleaningOrderParams(
          roomPeriods: _isPeriodBooking ? _roomPeriods!.toApiJson() : null,
          quoteSignature: _isPeriodBooking ? estimate?.quoteSignature : null,
          propertyType: args.propertyType,
          bedrooms: args.bedrooms,
          rooms: args.rooms,
          bathrooms: args.bathrooms,
          balconies: args.roomSizeBreakdown.legacyBalconiesCount,
          livingRoomSize: args.livingRoomSize,
          roomSizeBreakdown: args.roomSizeBreakdown,
          roomCleaningModes: args.roomCleaningModes,
          cleaningType: args.cleaningType,
          addressId: addressId,
          address: address.line1,
          locationName: address.label,
          scheduledDate: CleaningScheduleDateTimeLogic.formatDateApi(
            _selectedDate,
          ),
          scheduledTime: _fromTimeHhMm,
          addressLatitude: null,
          addressLongitude: null,
          genderPreference: state.genderPreference,
          workEnvironmentConfirmation: state.safetyConfirmation,
          assignmentMode: requestAssignmentMode,
          numberOfWorkers: selectedWorkers,
          preferredWorkerIds: selectedWorkerIds,
          recurringSessions: _recurringSessionsForRequest,
          recurringCalculationMode: _recurringCalculationMode,
          recurringHoursPerVisit:
              _recurringCalculationMode ==
                  CleaningRecurringCalculationMode.hours
              ? _recurringHoursPerVisit
              : null,
          recurringWorkerScope: _recurringWorkerScope,
          cleaningServices: _selectedCleaningServicesPayload(),
          workerRoomAssignments: workerRoomAssignments.isEmpty
              ? null
              : workerRoomAssignments,
          couponCode: _appliedCouponCode,
          notes: _bookingNotesController.text.trim(),
          serviceExtras: _serviceExtras,
          termsAccepted: true,
        ),
      ),
    );
  }

  void _showSendingOrderDialog() {
    if (_isSubmittingDialogOpen || !mounted) return;
    _isSubmittingDialogOpen = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const PopScope(
        canPop: false,
        child: Dialog(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 26, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 64,
                  width: 64,
                  child: CircularProgressIndicator(strokeWidth: 5),
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

  void _hideSendingOrderDialog() {
    if (!_isSubmittingDialogOpen) return;
    _isSubmittingDialogOpen = false;
    if (mounted) Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> _selectAddress() async {
    final selectedAddressVal = await context.pushRoute(
      '/myaddresses',
      arguments: true,
    );
    if (!mounted) return;
    if (selectedAddressVal is AddressListItem) {
      setState(() {
        selectedAddress.value = selectedAddressVal;
        _resetAppliedCoupon(message: 'تم تغيير العنوان. أعد تطبيق الكوبون.');
      });
      final bloc = _bloc;
      if (bloc != null) _requestUpdatedEstimate(bloc.state);
    }
  }

  void _requestUpdatedEstimate(
    ClMainState state, {
    List<int>? selectedWorkerIds,
    bool force = false,
  }) {
    if (_scheduleStep < 4 && !force) {
      _priceNeedsRefresh = true;
      _currentEstimate = null;
      return;
    }
    _priceNeedsRefresh = true;
    _currentEstimate = null;
    final args = _routeArgs;
    final bloc = _bloc;
    final address = selectedAddress.value;
    if (args == null || bloc == null) return;

    if (_appliedCouponCode != null) {
      setState(() {
        _resetAppliedCoupon(message: 'تم تحديث السعر. أعد تطبيق الكوبون.');
      });
    }

    final rawWorkerIds = selectedWorkerIds ?? state.selectedWorkerIds;
    final needsSpecificWorkerSelection =
        _isRecurring &&
        _recurringWorkerScope == CleaningRecurringWorkerScope.specific &&
        rawWorkerIds.isEmpty;
    // Bootstrap the worker picker with an unscoped estimate. The final booking
    // remains specific and is validated before advancing from worker selection.
    final estimateWorkerScope = needsSpecificWorkerSelection
        ? CleaningRecurringWorkerScope.any
        : _recurringWorkerScope;
    final workerIds =
        _isRecurring && estimateWorkerScope == CleaningRecurringWorkerScope.any
        ? const <int>[]
        : rawWorkerIds;
    final preferredWorkerId = workerIds.isEmpty ? null : workerIds.first;
    final stateWorkerCount = state.numberOfWorkers < 1
        ? 1
        : state.numberOfWorkers;
    final requestedWorkers =
        _serviceExtras.openTime?.workerCount ??
        (_isRecurring
            ? (estimateWorkerScope == CleaningRecurringWorkerScope.specific
                  ? (workerIds.isEmpty ? 1 : workerIds.length)
                  : stateWorkerCount)
            : (workerIds.length > stateWorkerCount
                  ? workerIds.length
                  : stateWorkerCount));
    final assignmentMode = _serviceExtras.openTime != null
        ? CleaningAssignmentMode.openCount
        : _isRecurring
        ? (estimateWorkerScope == CleaningRecurringWorkerScope.any
              ? CleaningAssignmentMode.openCount
              : (workerIds.length <= 1
                    ? CleaningAssignmentMode.preferredWorker
                    : CleaningAssignmentMode.openCount))
        : (requestedWorkers > 1
              ? CleaningAssignmentMode.openCount
              : state.assignmentMode);
    final workerRoomAssignments = buildWorkerRoomAssignmentsJson(
      slotByRoomKey: state.workerRoomAssignments,
      units: enumerateRoomUnits(args.roomSizeBreakdown),
      preferredWorkerId: preferredWorkerId,
      assignmentMode: assignmentMode,
    );

    bloc.add(
      EstimateCleaningPriceEvent(
        params: EstimateCleaningPriceParams(
          roomPeriods: _isPeriodBooking ? _roomPeriods!.toApiJson() : null,
          propertyType: args.propertyType,
          bedrooms: args.bedrooms,
          rooms: args.rooms,
          bathrooms: args.bathrooms,
          balconies: args.roomSizeBreakdown.legacyBalconiesCount,
          livingRoomSize: args.livingRoomSize,
          roomSizeBreakdown: args.roomSizeBreakdown,
          roomCleaningModes: args.roomCleaningModes,
          cleaningType: args.cleaningType,
          addressId: address == null ? null : int.tryParse(address.id),
          addressLatitude: null,
          addressLongitude: null,
          assignmentMode: assignmentMode,
          numberOfWorkers: requestedWorkers,
          preferredWorkerIds: workerIds,
          recurringSessions: _recurringSessionsForRequest,
          recurringCalculationMode: _recurringCalculationMode,
          recurringHoursPerVisit:
              _recurringCalculationMode ==
                  CleaningRecurringCalculationMode.hours
              ? _recurringHoursPerVisit
              : null,
          recurringWorkerScope: estimateWorkerScope,
          workerRoomAssignments: workerRoomAssignments.isEmpty
              ? null
              : workerRoomAssignments,
          serviceExtras: _serviceExtras,
        ),
      ),
    );
  }

  List<String> _selectedCleaningServicesPayload() {
    final normalized = <String>[];
    for (final service in _selectedCleaningServiceNames) {
      final value = service.trim();
      if (value.isEmpty || value.length > 255) continue;
      if (normalized.contains(value)) continue;
      normalized.add(value);
    }
    return normalized;
  }

  Future<bool> _showPersonalPropertyPledgeDialog() async {
    const pledgeMessage =
        'أتعهد بحماية وتأمين كافة ممتلكاتي الشخصية والثمينة طوال فترة الخدمة، وأقر بأنني المسؤول الأول والأخير عنها دون أدنى مسؤولية على المنصة';
    final pricing = _currentEstimate?.pricing;
    final amount = _appliedCouponTotal ?? pricing?.totalPrice;
    if (amount == null || pricing == null) {
      _bookingFeedback('تعذر عرض السعر. أعد محاولة مراجعة التكلفة.');
      return false;
    }
    return showClBookingConfirmationSheet(
      context: context,
      title: 'تأكيد طلب التنظيف',
      total: amount,
      currency: pricing.currency ?? 'SYP',
      icon: Icons.cleaning_services_outlined,
      acknowledgement: pledgeMessage,
    );
  }
}
