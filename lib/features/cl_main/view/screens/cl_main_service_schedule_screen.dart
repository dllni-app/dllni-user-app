import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/cleaning_date_time_ui_format.dart';
import '../../../../core/utils/cleaning_schedule_date_time_logic.dart';
import '../../../orders/domain/usecases/check_restaurant_coupon_use_case.dart';
import '../../../profile/domain/models/address_list_item.dart';
import '../../../profile/view/manager/bloc/profile_bloc.dart';
import '../../data/models/cleaning_services_response_model.dart';
import '../../data/models/estimate_price_response_model.dart';
import '../../domain/models/cl_worker_room_assignment.dart';
import '../../domain/models/cl_worker_room_assignment_result.dart';
import '../../domain/models/cleaning_assignment_mode.dart';
import '../../domain/usecases/create_cleaning_order_use_case.dart';
import '../../domain/usecases/estimate_cleaning_price_use_case.dart';
import '../../domain/usecases/get_cleaning_services_use_case.dart';
import '../data/cl_main_route_args.dart';
import '../helpers/cl_service_schedule_time_utils.dart';
import '../manager/bloc/cl_main_bloc.dart';
import '../widgets/app_pickers.dart';
import '../widgets/cl_cleaning_services_selector_widget.dart';
import '../widgets/cl_service_address_section_widget.dart';
import '../widgets/cl_service_bottom_actions_widget.dart';
import '../widgets/cl_service_coupon_section_widget.dart';
import '../widgets/cl_service_gradient_info_card_widget.dart';
import '../widgets/cl_service_order_summary_section_widget.dart';
import '../widgets/cl_service_schedule_section_widget.dart';
import '../widgets/cl_service_worker_assignment_summary_widget.dart';
import '../widgets/home_details_app_bar.dart';
import 'cl_main_screen.dart';

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
  BlocStatus _cleaningServicesStatus = BlocStatus.init;
  String? _cleaningServicesErrorMessage;
  List<CleaningServiceModel> _availableCleaningServices =
      const <CleaningServiceModel>[];
  final Set<String> _selectedCleaningServiceNames = <String>{};

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
            AppToast.showToast(
              context: context,
              message: state.createOrderResult?.message ?? 'تم إرسال الطلب بنجاح',
              type: ToastificationType.success,
            );
            context.pushRoute(
              '/clmain',
              arguments: ClMainScreenParams(profileBloc: getIt<ProfileBloc>()),
            );
          } else if (state.createOrderStatus == BlocStatus.failed) {
            AppToast.showToast(
              context: context,
              message: state.errorMessage ?? 'فشل تنفيذ الطلب',
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
                              estimatedHours:
                                  estimate?.size?.estimatedHours ?? 0,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اسم الخدمة طويل جداً')),
      );
      return;
    }
    setState(() {
      _selectedCleaningServiceNames.add(normalized);
      _customServiceController.clear();
      _resetAppliedCoupon();
    });
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
      });
      return;
    }
    if (args == null || state == null || address == null) {
      setState(() {
        _couponStatus = ClCouponUiStatus.failed;
        _couponMessage = 'يرجى إكمال بيانات الخدمة والعنوان أولاً.';
        _appliedCouponCode = null;
      });
      return;
    }

    setState(() {
      _couponStatus = ClCouponUiStatus.loading;
      _couponMessage = null;
      _appliedCouponCode = null;
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
    setState(() {
      _selectedDate = CleaningScheduleDateTimeLogic.parseDateApi(value)!;
    });
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
      _syncToTime();
    });
  }

  void _syncToTime() {
    final estimate = _currentEstimate ?? _routeArgs?.estimate;
    final estimatedHours = estimate?.size?.estimatedHours ?? 0;
    final blocState = _bloc?.state;
    final numberOfWorkers =
        blocState == null ? 1 : _requiredWorkersCount(blocState);
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
    if (state.assignmentMode != CleaningAssignmentMode.openCount) return 1;
    final count = state.numberOfWorkers;
    return count < 1 ? 1 : count;
  }

  double _effectiveServiceHours({
    required double estimatedHours,
    required int numberOfWorkers,
  }) {
    if (numberOfWorkers <= 1 || estimatedHours <= 0) return estimatedHours;
    return double.parse(
      (estimatedHours / numberOfWorkers).toStringAsFixed(1),
    );
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

  Future<void> _onSubmitPressed(ClMainState state) async {
    final args = _routeArgs;
    final bloc = _bloc;
    if (args == null || bloc == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('بيانات الطلب غير مكتملة')),
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

    final acceptedPledge = await _showPersonalPropertyPledgeDialog();
    if (!mounted || !acceptedPledge) return;

    final estimate = _currentEstimate ?? _routeArgs?.estimate;
    final normalizedAssignments = estimate?.workerRoomAssignments ?? const [];
    final workerRoomAssignments = normalizedAssignments.isNotEmpty
        ? workerRoomAssignmentsToRequestJson(normalizedAssignments)
        : buildWorkerRoomAssignmentsJson(
            slotByRoomKey: state.workerRoomAssignments,
            units: enumerateRoomUnits(args.roomSizeBreakdown),
            preferredWorkerId: state.primarySelectedWorkerId,
            assignmentMode: state.assignmentMode,
          );
    final selectedWorkerIds = state.selectedWorkerIds;

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
          addressId: int.parse(selectedAddress.value?.id ?? '0'),
          address: selectedAddress.value?.line1,
          locationName: selectedAddress.value?.label,
          scheduledDate: CleaningScheduleDateTimeLogic.formatDateApi(
            _selectedDate,
          ),
          scheduledTime: _fromTimeHhMm,
          addressLatitude: null,
          addressLongitude: null,
          genderPreference: state.genderPreference,
          workEnvironmentConfirmation: state.safetyConfirmation,
          assignmentMode: state.assignmentMode,
          numberOfWorkers: state.numberOfWorkers,
          preferredWorkerIds: selectedWorkerIds,
          cleaningServices: _selectedCleaningServicesPayload(),
          workerRoomAssignments:
              workerRoomAssignments.isEmpty ? null : workerRoomAssignments,
          couponCode: _appliedCouponCode,
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
        _resetAppliedCoupon(
          message: 'تم تغيير العنوان. أعد تطبيق الكوبون.',
        );
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
        _resetAppliedCoupon(
          message: 'تم تحديث السعر. أعد تطبيق الكوبون.',
        );
      });
    }

    final workerIds = selectedWorkerIds ?? state.selectedWorkerIds;
    final preferredWorkerId = workerIds.isEmpty ? null : workerIds.first;
    final assignmentMode = workerIds.length > 1
        ? CleaningAssignmentMode.openCount
        : state.assignmentMode;
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
          numberOfWorkers: state.numberOfWorkers,
          preferredWorkerIds: workerIds,
          workerRoomAssignments:
              workerRoomAssignments.isEmpty ? null : workerRoomAssignments,
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
