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
import '../../domain/models/cl_worker_room_assignment.dart';
import '../../domain/models/cl_worker_room_assignment_result.dart';
import '../../domain/models/cleaning_assignment_mode.dart';
import '../../domain/models/cleaning_recurring_session.dart';
import '../../domain/models/cleaning_type.dart';
import '../../domain/repository/cl_main_repo.dart';
import '../../domain/usecases/create_cleaning_order_use_case.dart';
import '../../domain/usecases/estimate_cleaning_price_use_case.dart';
import '../../domain/usecases/get_cleaning_services_use_case.dart';
import '../data/cl_main_route_args.dart';
import '../helpers/cl_service_schedule_time_utils.dart';
import '../manager/bloc/cl_main_bloc.dart';
import '../widgets/app_pickers.dart';
import '../widgets/cl_cleaning_services_selector_widget.dart';
import '../widgets/cl_cleaning_extras_section_widget.dart';
import '../widgets/cl_female_worker_safety_confirmation_sheet.dart';
import '../widgets/cl_recurring_schedule_section_widget.dart';
import '../widgets/cl_scheduled_previous_workers_section_widget.dart';
import '../widgets/cl_service_address_section_widget.dart';
import '../widgets/cl_service_bottom_actions_widget.dart';
import '../widgets/cl_service_coupon_section_widget.dart';
import '../widgets/cl_service_gender_preference_section_widget.dart';
import '../widgets/cl_service_gradient_info_card_widget.dart';
import '../widgets/cl_service_order_summary_section_widget.dart';
import '../widgets/cl_service_schedule_section_widget.dart';
import '../widgets/cl_service_worker_assignment_summary_widget.dart';
import '../widgets/home_details_app_bar.dart';

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
  late DateTime _selectedDate;
  late String _fromTimeHhMm;
  late String _toTimeHhMm;
  late TextEditingController _fromTimeController;
  late TextEditingController _toTimeController;
  late TextEditingController _couponController;
  late TextEditingController _customServiceController;
  ClMainScheduleArgs? _routeArgs;
  bool _didReadArgs = false;
  EstimatePriceResponseModel? _currentEstimate;
  ValueNotifier<AddressListItem?> selectedAddress = ValueNotifier(null);
  ClCouponUiStatus _couponStatus = ClCouponUiStatus.idle;
  String? _couponMessage;
  String? _appliedCouponCode;
  double? _appliedCouponDiscount;
  double? _appliedCouponTotal;
  BlocStatus _cleaningServicesStatus = BlocStatus.init;
  String? _cleaningServicesErrorMessage;
  List<CleaningServiceModel> _availableCleaningServices =
      const <CleaningServiceModel>[];
  BlocStatus _specialServicesStatus = BlocStatus.init;
  String? _specialServicesErrorMessage;
  List<CleaningServiceModel> _availableSpecialServices =
      const <CleaningServiceModel>[];
  final Set<String> _selectedCleaningServiceNames = <String>{};
  CleaningServiceExtrasRequest _serviceExtras =
      const CleaningServiceExtrasRequest();
  bool _isRecurring = false;
  CleaningRecurringPattern _recurringPattern = CleaningRecurringPattern.custom;
  CleaningRecurringCalculationMode _recurringCalculationMode =
      CleaningRecurringCalculationMode.task;
  CleaningRecurringWorkerScope _recurringWorkerScope =
      CleaningRecurringWorkerScope.any;
  double _recurringHoursPerVisit = 2;
  int _recurringOccurrences = 2;
  List<CleaningRecurringSessionInput> _recurringSessions =
      const <CleaningRecurringSessionInput>[];

  @override
  Widget build(BuildContext context) {
    final dayAr = CleaningDateTimeUiFormat.weekday(_selectedDate);
    final dayDate = CleaningDateTimeUiFormat.date(_selectedDate);
    final estimate = _currentEstimate ?? _routeArgs?.estimate;
    final bloc = _bloc;

    if (bloc == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F2F2),
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    return BlocProvider.value(
      value: bloc,
      child: BlocConsumer<ClMainBloc, ClMainState>(
        listenWhen: (previous, current) =>
            previous.createOrderStatus != current.createOrderStatus ||
            previous.estimatePriceStatus != current.estimatePriceStatus,
        listener: (context, state) {
          if (state.estimatePriceStatus == BlocStatus.success &&
              state.estimatePrice != null) {
            setState(() {
              _currentEstimate = state.estimatePrice;
              _syncToTime();
            });
          } else if (state.estimatePriceStatus == BlocStatus.failed &&
              state.errorMessage != null &&
              state.errorMessage!.isNotEmpty) {
            AppToast.showToast(
              context: context,
              message: state.errorMessage!,
              type: ToastificationType.error,
            );
          }

          if (state.createOrderStatus == BlocStatus.loading) {
            Loading.show(context);
            return;
          }
          Loading.close();
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
              message: 'تم إنشاء الطلب بنجاح، وهو الآن قيد الانتظار',
              type: ToastificationType.success,
            );
            context.pushRouteAndRemoveUntil(
              '/cleaning-order-details',
              arguments: CleaningOrderDetailsArgs(orderId: orderId),
              predicate: (route) => route.settings.name == '/clmain',
            );
          } else if (state.createOrderStatus == BlocStatus.failed) {
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
            backgroundColor: const Color(0xFFF2F2F2),
            body: SafeArea(
              child: Column(
                children: [
                  const HomeDetailsAppBar(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsetsDirectional.only(
                        start: 20,
                        end: 20,
                      ),
                      child: Column(
                        children: [
                          ClServiceGradientInfoCardWidget(
                            estimatedSqm: estimate?.size?.estimatedSqm ?? 0,
                            estimatedHours: _effectiveServiceHours(
                              estimatedHours: _perVisitEstimatedHours(estimate),
                              numberOfWorkers: _requiredWorkersCount(state),
                            ),
                          ),
                          if (estimate?.workerRoomAssignments.isNotEmpty ??
                              false) ...[
                            const SizedBox(height: 10),
                            ClServiceWorkerAssignmentSummaryWidget(
                              assignments: estimate!.workerRoomAssignments,
                              fieldErrors: state.assignmentFieldErrors,
                            ),
                          ],
                          const SizedBox(height: 10),
                          ClServiceScheduleSectionWidget(
                            dayAr: dayAr,
                            dayDate: dayDate,
                            fromTimeController: _fromTimeController,
                            toTimeController: _toTimeController,
                            onPickDate: _pickDate,
                            onPickFromTime: _pickFromTime,
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
                                _setRecurringOccurrences(occurrences, state),
                            onAddVisit: () => _addRecurringVisit(state),
                            onEditVisit: (index) =>
                                _editRecurringVisit(index, state),
                            onRemoveVisit: (index) =>
                                _removeRecurringVisit(index, state),
                          ),
                          const SizedBox(height: 10),
                          ClServiceGenderPreferenceSectionWidget(
                            selectedPreference: state.genderPreference,
                            onChanged: (preference) {
                              _handleGenderPreferenceChanged(bloc, preference);
                            },
                          ),
                          const SizedBox(height: 10),
                          if (!_isRecurring ||
                              _recurringWorkerScope ==
                                  CleaningRecurringWorkerScope.specific) ...[
                            ClScheduledPreviousWorkersSectionWidget(
                              bloc: bloc,
                              propertyType: _routeArgs?.propertyType ?? '',
                              scheduledDate:
                                  CleaningScheduleDateTimeLogic.formatDateApi(
                                    _selectedDate,
                                  ),
                              scheduledTime: _fromTimeHhMm,
                              durationHours: _effectiveServiceHours(
                                estimatedHours: _perVisitEstimatedHours(
                                  estimate,
                                ),
                                numberOfWorkers: _requiredWorkersCount(state),
                              ),
                              onSelectedWorkersChanged: (workerIds) {
                                _requestUpdatedEstimate(
                                  state,
                                  selectedWorkerIds: workerIds,
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                          CleaningAddressSelectWidget(
                            selectedAddress: selectedAddress,
                            onChangeTap: _selectAddress,
                            afterBringDefault: () {
                              _requestUpdatedEstimate(state);
                            },
                          ),
                          const SizedBox(height: 12),
                          ClCleaningServicesSelectorWidget(
                            availableServices: _availableCleaningServices,
                            selectedServiceNames: _selectedCleaningServiceNames,
                            customServiceController: _customServiceController,
                            isLoading:
                                _cleaningServicesStatus == BlocStatus.loading,
                            errorMessage:
                                _cleaningServicesStatus == BlocStatus.failed
                                ? _cleaningServicesErrorMessage ??
                                      'تعذر تحميل الخدمات'
                                : null,
                            onToggleService: _toggleCleaningService,
                            onAddCustomService: _addCustomCleaningService,
                            onRemoveService: _removeCleaningService,
                            onRetry: _loadCleaningServices,
                          ),
                          const SizedBox(height: 12),
                          ClCleaningExtrasSectionWidget(
                            requestMaterials: _serviceExtras.requestMaterials,
                            specialServices: _serviceExtras.specialServices,
                            openTime: _serviceExtras.openTime,
                            availableSpecialServices: _availableSpecialServices,
                            materials: estimate?.materials ??
                                const <CleaningMaterialLineModel>[],
                            estimatedSpecialServices:
                                estimate?.specialServices ??
                                    const <CleaningSpecialServiceLineModel>[],
                            estimatedOpenTime: estimate?.openTime,
                            isSpecialServicesLoading:
                                _specialServicesStatus == BlocStatus.loading,
                            isEstimateLoading:
                                state.estimatePriceStatus == BlocStatus.loading,
                            specialServicesError: _specialServicesStatus ==
                                    BlocStatus.failed
                                ? _specialServicesErrorMessage
                                : null,
                            estimateError: state.estimatePriceStatus ==
                                    BlocStatus.failed
                                ? state.errorMessage
                                : null,
                            onRequestMaterialsChanged: (value) =>
                                _updateServiceExtras(
                                  _serviceExtras.copyWith(
                                    requestMaterials: value,
                                  ),
                                  state,
                                ),
                            onAddSpecialService: () =>
                                _addSpecialService(state),
                            onSpecialServiceChanged: (index, service) =>
                                _replaceSpecialService(index, service, state),
                            onRemoveSpecialService: (index) =>
                                _removeSpecialService(index, state),
                            onOpenTimeChanged: (enabled) =>
                                _setOpenTimeEnabled(enabled, state),
                            onOpenTimeWorkerCountChanged: (count) =>
                                _setOpenTimeWorkerCount(count, state),
                            onRetryEstimate: () =>
                                _requestUpdatedEstimate(state),
                            onRetrySpecialServices: _loadSpecialServices,
                          ),
                          const SizedBox(height: 16),
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
                          ClServiceOrderSummarySectionWidget(
                            basePrice: estimate?.pricing?.basePrice ?? 0,
                            travelFee: estimate?.pricing?.travelFee ?? 0,
                            addonsTotal: estimate?.pricing?.addonsTotal ?? 0,
                            totalPrice: estimate?.pricing?.totalPrice ?? 0,
                            discountAmount: _appliedCouponDiscount,
                            totalAfterDiscount: _appliedCouponTotal,
                            adminMargin: estimate?.pricing?.adminMargin,
                            isPricingFinal: estimate?.pricing?.isPricingFinal,
                            currency: estimate?.pricing?.currency ?? 'SYP',
                            scheduleDayLabel: dayAr,
                            scheduleDateLabel: dayDate,
                            scheduleTimeRange:
                                CleaningDateTimeUiFormat.timeRange(
                                  _fromTimeHhMm,
                                  _toTimeHhMm,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: const Color(0xFFF2F2F2),
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: ClServiceBottomActionsWidget(
                      onBackPressed: () => context.pop(),
                      onSubmitPressed: () => _onSubmitPressed(state),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
      _currentEstimate = args.estimate;
      selectedAddress = ValueNotifier(
        args.defaultAddress ?? widget.item?.defaultAddress,
      );
      _syncToTime();
      _loadCleaningServices();
      _loadSpecialServices();
    } else if (args is AddressListItem) {
      selectedAddress = ValueNotifier(args);
    }
  }

  @override
  void dispose() {
    _fromTimeController.dispose();
    _toTimeController.dispose();
    _couponController.dispose();
    _customServiceController.dispose();
    selectedAddress.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = CleaningScheduleDateTimeLogic.tomorrowDate();
    _fromTimeHhMm = '09:00';
    _toTimeHhMm = '09:00';
    _fromTimeController = TextEditingController(
      text: CleaningDateTimeUiFormat.time(_fromTimeHhMm),
    );
    _toTimeController = TextEditingController(
      text: CleaningDateTimeUiFormat.time(_toTimeHhMm),
    );
    _couponController = TextEditingController();
    _customServiceController = TextEditingController();
  }

  void _updateTimeDisplay() {
    _fromTimeController.text = CleaningDateTimeUiFormat.time(_fromTimeHhMm);
    _toTimeController.text = CleaningDateTimeUiFormat.time(_toTimeHhMm);
  }

  void _addCustomCleaningService() {
    final normalized = _customServiceController.text.trim();
    if (normalized.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى كتابة اسم الخدمة أولاً')),
      );
      return;
    }
    if (normalized.length > 255) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('اسم الخدمة طويل جداً')));
      return;
    }
    setState(() {
      _selectedCleaningServiceNames.add(normalized);
      _customServiceController.clear();
      _resetAppliedCoupon();
    });
  }

  Future<void> _handleGenderPreferenceChanged(
    ClMainBloc bloc,
    CleaningGenderPreference preference,
  ) async {
    if (preference != CleaningGenderPreference.female) {
      bloc.add(SetGenderPreferenceEvent(preference: preference));
      return;
    }

    Loading.show(context);
    final response = await getIt<ClMainRepo>().getFemaleWorkerSafetyPolicy();
    Loading.close();
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
      _replacePrimaryRecurringVisit();
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
      _replacePrimaryRecurringVisit();
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
      _recurringPattern = CleaningRecurringPattern.custom;
      _recurringCalculationMode = CleaningRecurringCalculationMode.task;
      _recurringWorkerScope = enabled && state.selectedWorkerIds.isNotEmpty
          ? CleaningRecurringWorkerScope.specific
          : CleaningRecurringWorkerScope.any;
      _recurringHoursPerVisit = 2;
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
      _requestUpdatedEstimate(state, selectedWorkerIds: const <int>[]);
      return;
    }
    if (state.selectedWorkerIds.isNotEmpty) {
      _requestUpdatedEstimate(state);
    }
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
    final estimate = _currentEstimate ?? _routeArgs?.estimate;
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
    final openCount = state.assignmentMode == CleaningAssignmentMode.openCount
        ? (state.numberOfWorkers < 1 ? 1 : state.numberOfWorkers)
        : 1;
    final preferredCount = _isRecurring ? 0 : state.selectedWorkerIds.length;
    return preferredCount > openCount ? preferredCount : openCount;
  }

  double _effectiveServiceHours({
    required double estimatedHours,
    required int numberOfWorkers,
  }) {
    if (numberOfWorkers <= 1 || estimatedHours <= 0) return estimatedHours;
    return double.parse((estimatedHours / numberOfWorkers).toStringAsFixed(1));
  }

  Future<void> _loadCleaningServices() async {
    if (!mounted) return;
    setState(() {
      _cleaningServicesStatus = BlocStatus.loading;
      _cleaningServicesErrorMessage = null;
    });
    final response = await getIt<GetCleaningServicesUseCase>()(
      GetCleaningServicesParams(category: 'cleaning'),
    );
    if (!mounted) return;
    response.fold(
      (failure) => setState(() {
        _cleaningServicesStatus = BlocStatus.failed;
        _cleaningServicesErrorMessage = failure.message;
      }),
      (result) => setState(() {
        _cleaningServicesStatus = BlocStatus.success;
        _cleaningServicesErrorMessage = null;
        _availableCleaningServices = result.data
            .where((service) => service.name?.trim().isNotEmpty == true)
            .toList(growable: false);
      }),
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
      (result) => setState(() {
        _specialServicesStatus = BlocStatus.success;
        _specialServicesErrorMessage = null;
        _availableSpecialServices = result.data
            .where(
              (service) =>
                  service.id != null && service.name?.trim().isNotEmpty == true,
            )
            .toList(growable: false);
      }),
    );
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

  void _addSpecialService(ClMainState state) {
    final firstService = _availableSpecialServices.firstWhere(
      (service) => service.id != null,
      orElse: () => const CleaningServiceModel(),
    );
    final id = firstService.id;
    if (id == null) return;
    _updateServiceExtras(
      _serviceExtras.copyWith(
        specialServices: <CleaningSpecialServiceRequest>[
          ..._serviceExtras.specialServices,
          CleaningSpecialServiceRequest(
            specialServiceId: id,
            quantity: 1,
            dirtinessLevel: 'medium',
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
    final services = List<CleaningSpecialServiceRequest>.of(
      _serviceExtras.specialServices,
    );
    services[index] = service;
    _updateServiceExtras(_serviceExtras.copyWith(specialServices: services), state);
  }

  void _removeSpecialService(int index, ClMainState state) {
    if (index < 0 || index >= _serviceExtras.specialServices.length) return;
    final services = List<CleaningSpecialServiceRequest>.of(
      _serviceExtras.specialServices,
    )..removeAt(index);
    _updateServiceExtras(_serviceExtras.copyWith(specialServices: services), state);
  }

  void _setOpenTimeEnabled(bool enabled, ClMainState state) {
    _updateServiceExtras(
      enabled
          ? _serviceExtras.copyWith(
              openTime: CleaningOpenTimeRequest(
                workerCount: state.numberOfWorkers < 1
                    ? 1
                    : state.numberOfWorkers,
              ),
            )
          : _serviceExtras.copyWith(clearOpenTime: true),
      state,
    );
  }

  void _setOpenTimeWorkerCount(int count, ClMainState state) {
    if (_serviceExtras.openTime == null || count < 1) return;
    _updateServiceExtras(
      _serviceExtras.copyWith(
        openTime: CleaningOpenTimeRequest(workerCount: count),
      ),
      state,
    );
  }

  Future<void> _onSubmitPressed(ClMainState state) async {
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
            'يرجى اختيار أو تعديل عنوان مكتمل يحتوي على المدينة والحي والتفاصيل الأخرى والموقع على الخريطة',
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

    final estimateForWorkers = _currentEstimate ?? args.estimate;
    final estimatedHours = _perVisitEstimatedHours(estimateForWorkers);
    final selectedWorkers =
        _serviceExtras.openTime?.workerCount ?? _requiredWorkersCount(state);
    final requiredWorkers =
        estimateForWorkers.requiredWorkers ??
        (estimatedHours <= 0 ? 1 : (estimatedHours / 8).ceil());

    if (selectedWorkers < requiredWorkers) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'مدة العمل تتجاوز 8 ساعات لكل عامل. يجب طلب $requiredWorkers عمال على الأقل لإتمام هذا الطلب.',
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

    final acceptedPledge = await _showPersonalPropertyPledgeDialog();
    if (!mounted || !acceptedPledge) return;

    final estimate = _currentEstimate ?? _routeArgs?.estimate;
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
    final workerRoomAssignments = normalizedAssignments.isNotEmpty
        ? workerRoomAssignmentsToRequestJson(normalizedAssignments)
        : buildWorkerRoomAssignmentsJson(
            slotByRoomKey: state.workerRoomAssignments,
            units: enumerateRoomUnits(args.roomSizeBreakdown),
            preferredWorkerId: selectedWorkerIds.isEmpty
                ? null
                : selectedWorkerIds.first,
            assignmentMode: requestAssignmentMode,
          );

    bloc.add(
      CreateCleaningOrderEvent(
        params: CreateCleaningOrderParams(
          propertyType: args.propertyType,
          bedrooms: args.bedrooms,
          rooms: args.rooms,
          bathrooms: args.bathrooms,
          balconies: args.roomSizeBreakdown.legacyBalconiesCount,
          livingRoomSize: args.livingRoomSize,
          roomSizeBreakdown: args.roomSizeBreakdown,
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
           serviceExtras: _serviceExtras,
           termsAccepted: true,
        ),
      ),
    );
  }

  void _removeCleaningService(String name) {
    final normalized = name.trim();
    if (normalized.isEmpty) return;
    setState(() {
      _selectedCleaningServiceNames.remove(normalized);
      _resetAppliedCoupon(
        message: 'تم تغيير بيانات الخدمة. أعد تطبيق الكوبون.',
      );
    });
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
  }) {
    final args = _routeArgs;
    final bloc = _bloc;
    final address = selectedAddress.value;
    if (args == null || bloc == null || address == null) return;

    if (_appliedCouponCode != null) {
      setState(() {
        _resetAppliedCoupon(message: 'تم تحديث السعر. أعد تطبيق الكوبون.');
      });
    }

    final rawWorkerIds = selectedWorkerIds ?? state.selectedWorkerIds;
    if (_isRecurring &&
        _recurringWorkerScope == CleaningRecurringWorkerScope.specific &&
        rawWorkerIds.isEmpty) {
      return;
    }
    final workerIds =
        _isRecurring &&
            _recurringWorkerScope == CleaningRecurringWorkerScope.any
        ? const <int>[]
        : rawWorkerIds;
    final preferredWorkerId = workerIds.isEmpty ? null : workerIds.first;
    final stateWorkerCount = state.numberOfWorkers < 1
        ? 1
        : state.numberOfWorkers;
    final requestedWorkers = _serviceExtras.openTime?.workerCount ??
        (_isRecurring
        ? (_recurringWorkerScope == CleaningRecurringWorkerScope.specific
              ? (workerIds.isEmpty ? 1 : workerIds.length)
              : stateWorkerCount)
        : (workerIds.length > stateWorkerCount
              ? workerIds.length
              : stateWorkerCount));
    final assignmentMode = _serviceExtras.openTime != null
        ? CleaningAssignmentMode.openCount
        : _isRecurring
        ? (_recurringWorkerScope == CleaningRecurringWorkerScope.any
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
          propertyType: args.propertyType,
          bedrooms: args.bedrooms,
          rooms: args.rooms,
          bathrooms: args.bathrooms,
          balconies: args.roomSizeBreakdown.legacyBalconiesCount,
          livingRoomSize: args.livingRoomSize,
          roomSizeBreakdown: args.roomSizeBreakdown,
          cleaningType: args.cleaningType,
          addressId: int.tryParse(address.id),
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
          recurringWorkerScope: _recurringWorkerScope,
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
    final accepted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Text(pledgeMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('أوافق'),
          ),
        ],
      ),
    );
    return accepted ?? false;
  }

  void _toggleCleaningService(String name) {
    final normalized = name.trim();
    if (normalized.isEmpty) return;
    setState(() {
      if (_selectedCleaningServiceNames.contains(normalized)) {
        _selectedCleaningServiceNames.remove(normalized);
      } else {
        _selectedCleaningServiceNames.add(normalized);
      }
      _resetAppliedCoupon(
        message: 'تم تغيير بيانات الخدمة. أعد تطبيق الكوبون.',
      );
    });
  }
}
