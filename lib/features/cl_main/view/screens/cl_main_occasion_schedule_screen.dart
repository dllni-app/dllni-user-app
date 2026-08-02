import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/models/cleaning_gender_preference.dart';
import '../../../../core/utils/cleaning_date_time_ui_format.dart';
import '../../../../core/utils/cleaning_schedule_date_time_logic.dart';
import '../../../orders/domain/usecases/check_restaurant_coupon_use_case.dart';
import '../../../profile/domain/models/address_list_item.dart';
import '../../../profile/view/manager/bloc/profile_bloc.dart';
import '../../data/models/estimate_price_response_model.dart';
import '../../domain/models/cleaning_assignment_mode.dart';
import '../../domain/usecases/create_cleaning_order_use_case.dart';
import '../data/cl_main_route_args.dart';
import '../helpers/cl_event_assignment_helper.dart';
import '../helpers/cl_service_schedule_time_utils.dart';
import '../manager/bloc/cl_main_bloc.dart';
import '../widgets/app_pickers.dart';
import '../widgets/cl_service_bottom_actions_widget.dart';
import '../widgets/cl_service_coupon_section_widget.dart';
import '../widgets/cl_service_gradient_info_card_widget.dart';
import '../widgets/cl_service_order_summary_section_widget.dart';
import '../widgets/cl_service_schedule_section_widget.dart';
import '../widgets/cl_service_section_card_widget.dart';
import '../widgets/home_details_app_bar.dart';
import 'cl_main_screen.dart';

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
  late DateTime _selectedDate;
  late String _fromTimeHhMm;
  late String _toTimeHhMm;
  late TextEditingController _fromTimeController;
  late TextEditingController _toTimeController;
  late TextEditingController _couponController;
  ClMainOccasionScheduleArgs? _routeArgs;
  ClMainBloc? _bloc;
  bool _didReadArgs = false;
  EstimatePriceResponseModel? _currentEstimate;
  late final ValueNotifier<AddressListItem?> _selectedAddress;
  ClCouponUiStatus _couponStatus = ClCouponUiStatus.idle;
  String? _couponMessage;
  String? _appliedCouponCode;

  EstimatePriceResponseModel? get _activeEstimate =>
      _currentEstimate ?? _routeArgs?.estimate;

  double get _estimatedHours {
    final routedHours = _routeArgs?.hours;
    if (routedHours != null && routedHours > 0) return routedHours;
    final fromPricing = _activeEstimate?.pricing?.eventHours;
    if (fromPricing != null && fromPricing > 0) return fromPricing;
    final fromRecommendation = _activeEstimate?.recommendation?.hours;
    if (fromRecommendation != null && fromRecommendation > 0) {
      return fromRecommendation;
    }
    return 4;
  }

  int get _estimatedSqm => _activeEstimate?.size?.estimatedSqm ?? 0;

  int get _routeNumberOfWorkers {
    final requested = _routeArgs?.numberOfWorkers ?? 1;
    return requested < 1 ? 1 : requested;
  }

  int get _resolvedNumberOfWorkers => resolveEventWorkerCountForHours(
    hours: _estimatedHours,
    requestedWorkers: _routeNumberOfWorkers,
  );

  @override
  Widget build(BuildContext context) {
    final args = _routeArgs;
    final bloc = _bloc;
    if (args == null || bloc == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F2F2),
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    final dayAr = CleaningDateTimeUiFormat.weekday(_selectedDate);
    final dayDate = CleaningDateTimeUiFormat.date(_selectedDate);
    final estimate = _activeEstimate;
    final numberOfWorkers = _resolvedNumberOfWorkers;

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
          }

          if (state.createOrderStatus == BlocStatus.loading) {
            Loading.show(context);
            return;
          }
          Loading.close();
          if (state.createOrderStatus == BlocStatus.success) {
            AppToast.showToast(
              context: context,
              message:
                  state.createOrderResult?.message ?? 'تم إرسال الطلب بنجاح',
              type: ToastificationType.success,
            );
            context.pushRoute(
              '/clmain',
              arguments: ClMainScreenParams(profileBloc: getIt<ProfileBloc>()),
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
                            estimatedSqm: _estimatedSqm,
                            estimatedHours: _estimatedHours,
                            showEstimatedSqm: false,
                          ),
                          const SizedBox(height: 10),
                          ClServiceSectionCardWidget(
                            key: const Key('occasion_schedule_details_card'),
                            step: 0,
                            showStepBadge: false,
                            title: 'تفاصيل المناسبة',
                            child: Column(
                              children: [
                                _OccasionInfoRow(
                                  label: 'نوع المناسبة',
                                  value: args.option.title,
                                ),
                                const SizedBox(height: 8),
                                _OccasionInfoRow(
                                  label: 'عدد الضيوف',
                                  value: '${args.guestsCount}',
                                ),
                                const SizedBox(height: 8),
                                _OccasionInfoRow(
                                  label: 'طبيعة المساعدة',
                                  value: args.helpTypeLabel,
                                ),
                                const SizedBox(height: 8),
                                _OccasionInfoRow(
                                  label: 'مدة الخدمة',
                                  value:
                                      '${args.hours.toStringAsFixed(0)} ساعة',
                                ),
                                const SizedBox(height: 8),
                                _OccasionInfoRow(
                                  label: 'عدد العمال',
                                  value: '$numberOfWorkers',
                                ),
                                const SizedBox(height: 8),
                                _OccasionInfoRow(
                                  label: 'متطلبات خاصة',
                                  value: args.specialRequirementLabel,
                                ),
                                if (args.notes != null &&
                                    args.notes!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  _OccasionInfoRow(
                                    label: 'ملاحظات',
                                    value: args.notes!,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          ClServiceScheduleSectionWidget(
                            dayAr: dayAr,
                            dayDate: dayDate,
                            fromTimeController: _fromTimeController,
                            toTimeController: _toTimeController,
                            onPickDate: _pickDate,
                            onPickFromTime: _pickFromTime,
                          ),
                          const SizedBox(height: 12),
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
    if (args is ClMainOccasionScheduleArgs) {
      _routeArgs = args;
      _bloc = args.bloc;
      _currentEstimate = args.estimate;
      _selectedAddress.value = args.defaultAddress;
      _syncToTime();
    }
  }

  @override
  void dispose() {
    _fromTimeController.dispose();
    _toTimeController.dispose();
    _couponController.dispose();
    _selectedAddress.dispose();
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
    _selectedAddress = ValueNotifier(null);
  }

  void _updateTimeDisplay() {
    _fromTimeController.text = CleaningDateTimeUiFormat.time(_fromTimeHhMm);
    _toTimeController.text = CleaningDateTimeUiFormat.time(_toTimeHhMm);
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
      'hours': args.hours,
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

  void _onSubmitPressed(ClMainState state) {
    final args = _routeArgs;
    final bloc = _bloc;
    if (args == null || bloc == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذر تجهيز بيانات الطلب')));
      return;
    }

    if (state.genderPreference == CleaningGenderPreference.female &&
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
            'يرجى اختيار أو تعديل عنوان مكتمل يحتوي على المدينة والحي والتفاصيل الأخرى والموقع على الخريطة',
          ),
        ),
      );
      return;
    }

    final specialRequirement = args.specialRequirementId == 'none'
        ? null
        : args.specialRequirementLabel;
    final assignment = _resolveAssignment(state);
    bloc.add(
      CreateCleaningOrderEvent(
        params: CreateCleaningOrderParams.eventAssistance(
          addressId: addressId,
          eventType: args.eventType,
          guestCount: args.guestsCount,
          venueType: args.venueType,
          customService: args.customService,
          hours: args.hours,
          address: selectedAddress.line1,
          locationName: selectedAddress.label,
          scheduledDate: CleaningScheduleDateTimeLogic.formatDateApi(
            _selectedDate,
          ),
          scheduledTime: _fromTimeHhMm,
          genderPreference: state.genderPreference,
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
    final value = await AppPickers.showAppTimePicker(context: context);
    if (value.isEmpty) return;
    setState(() {
      _fromTimeHhMm = CleaningScheduleDateTimeLogic.normalizeTimeHhMm(value);
      _syncToTime();
    });
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

  void _syncToTime() {
    _toTimeHhMm = formatClServiceEndTime(
      startTime: _fromTimeHhMm,
      durationHours: _estimatedHours,
    );
    _updateTimeDisplay();
  }
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
