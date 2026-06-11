import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/models/cleaning_gender_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/utils/app_date_time_locale.dart';
import '../../../profile/domain/models/address_list_item.dart';
import '../../data/models/estimate_price_response_model.dart';
import '../../domain/usecases/create_cleaning_order_use_case.dart';
import '../../domain/usecases/estimate_cleaning_price_use_case.dart';
import '../../domain/usecases/get_previous_cleaning_workers_use_case.dart';
import '../data/cl_main_route_args.dart';
import '../helpers/cl_event_assignment_helper.dart';
import '../helpers/cl_service_schedule_time_utils.dart';
import '../manager/bloc/cl_main_bloc.dart';
import '../widgets/app_pickers.dart';
import '../widgets/cl_service_address_section_widget.dart';
import '../widgets/cl_service_bottom_actions_widget.dart';
import '../widgets/cl_service_coupon_section_widget.dart';
import '../widgets/cl_service_gender_preference_section_widget.dart';
import '../widgets/cl_service_gradient_info_card_widget.dart';
import '../widgets/cl_service_order_summary_section_widget.dart';
import '../widgets/cl_service_previous_workers_section_widget.dart';
import '../widgets/cl_service_schedule_section_widget.dart';
import '../widgets/cl_service_section_card_widget.dart';
import '../widgets/home_details_app_bar.dart';
import 'cl_worker_profile_detail_screen.dart';

@AutoRoutePage()
class ClMainOccasionScheduleScreen extends StatefulWidget {
  const ClMainOccasionScheduleScreen({this.args, super.key});

  final ClMainOccasionScheduleArgs? args;

  @override
  State<ClMainOccasionScheduleScreen> createState() =>
      _ClMainOccasionScheduleScreenState();
}

class _ClMainOccasionScheduleScreenState
    extends State<ClMainOccasionScheduleScreen> {
  late DateTime _selectedDate;
  late TextEditingController _fromTimeController;
  late TextEditingController _toTimeController;
  late TextEditingController _couponController;
  ClMainOccasionScheduleArgs? _routeArgs;
  ClMainBloc? _bloc;
  bool _didReadArgs = false;
  EstimatePriceResponseModel? _currentEstimate;
  AddressListItem? _selectedAddress;
  CleaningGenderPreference _selectedGenderPreference =
      CleaningGenderPreference.any;
  ClCouponUiStatus _couponStatus = ClCouponUiStatus.idle;
  String? _couponMessage;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    _fromTimeController = TextEditingController(text: '09:00');
    _toTimeController = TextEditingController();
    _couponController = TextEditingController();
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
      _syncToTime();
    }
    _bloc?.add(
      GetPreviousCleaningWorkersEvent(
        params: GetPreviousCleaningWorkersParams(page: 1),
        isReload: true,
      ),
    );
  }

  @override
  void dispose() {
    _fromTimeController.dispose();
    _toTimeController.dispose();
    _couponController.dispose();
    super.dispose();
  }

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

  int get _estimatedSqm {
    return _activeEstimate?.size?.estimatedSqm ?? 0;
  }

  void _syncToTime() {
    _toTimeController.text = formatClServiceEndTime(
      startTime: _fromTimeController.text,
      durationHours: _estimatedHours,
    );
  }

  EventAssignmentFields _resolveAssignment(ClMainState state) {
    final estimate = _activeEstimate;
    return resolveEventAssignmentFields(
      selectedWorkerId: state.selectedWorkerId,
      suggestedTeamSize:
          _routeArgs?.numberOfWorkers ?? estimate?.suggestedTeamSize,
      workerAcceptance: estimate?.workerAcceptance,
    );
  }

  void _requestEventEstimate(ClMainState state, {int? selectedWorkerId}) {
    final args = _routeArgs;
    final bloc = _bloc;
    if (args == null || bloc == null) return;

    final specialRequirement = args.specialRequirementId == 'none'
        ? null
        : args.specialRequirementLabel;
    final estimate = _activeEstimate;
    final assignment = resolveEventAssignmentFields(
      selectedWorkerId: selectedWorkerId ?? state.selectedWorkerId,
      suggestedTeamSize: args.numberOfWorkers,
      workerAcceptance: estimate?.workerAcceptance,
    );
    final address = _selectedAddress;

    bloc.add(
      EstimateCleaningPriceEvent(
        params: EstimateCleaningPriceParams.eventAssistance(
          eventType: args.eventType,
          guestCount: args.guestsCount,
          venueType: args.venueType,
          customService: args.customService,
          hours: args.hours,
          addressLatitude: address?.latitude,
          addressLongitude: address?.longitude,
          preferredWorkerId: assignment.preferredWorkerId,
          specialRequirement: specialRequirement,
          notes: args.notes,
          numberOfWorkers: assignment.numberOfWorkers,
          assignmentMode: assignment.assignmentMode,
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final value = await AppPickers.showAppDatePicker(
      context: context,
      startDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (value.isEmpty) return;
    setState(() {
      _selectedDate = AppDateTimeLocale.dateFormat('yyyy-MM-dd').parse(value);
    });
  }

  Future<void> _pickFromTime() async {
    final value = await AppPickers.showAppTimePicker(context: context);
    if (value.isEmpty) return;
    setState(() {
      _fromTimeController.text = value;
      _syncToTime();
    });
  }

  Future<void> _selectAddress() async {
    final selectedAddress = await context.pushRoute(
      '/myaddresses',
      arguments: true,
    );
    if (!mounted) return;
    if (selectedAddress is AddressListItem) {
      setState(() {
        _selectedAddress = selectedAddress;
      });
      final bloc = _bloc;
      if (bloc != null) {
        _requestEventEstimate(bloc.state);
      }
    }
  }

  void _onApplyCoupon(String code) {
    setState(() {
      _couponStatus = ClCouponUiStatus.failed;
      _couponMessage = 'الكوبونات غير متاحة لطلبات المناسبات حالياً.';
    });
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

    final selectedAddress = _selectedAddress;
    if (selectedAddress == null ||
        selectedAddress.latitude == null ||
        selectedAddress.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار عنوان الخدمة أولاً')),
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
          eventType: args.eventType,
          guestCount: args.guestsCount,
          venueType: args.venueType,
          customService: args.customService,
          hours: args.hours,
          address: selectedAddress.line1,
          locationName: selectedAddress.label,
          scheduledDate: AppDateTimeLocale.dateFormat(
            'yyyy-MM-dd',
          ).format(_selectedDate),
          scheduledTime: _fromTimeController.text,
          addressLatitude: selectedAddress.latitude,
          addressLongitude: selectedAddress.longitude,
          genderPreference: _selectedGenderPreference,
          assignmentMode: assignment.assignmentMode,
          preferredWorkerId: assignment.preferredWorkerId,
          specialRequirement: specialRequirement,
          notes: args.notes,
          numberOfWorkers: assignment.numberOfWorkers,
          termsAccepted: true,
        ),
      ),
    );
  }

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
    final dayAr = AppDateTimeLocale.dateFormat('EEEE').format(_selectedDate);
    final dayDate = AppDateTimeLocale.dateFormat(
      'd MMM yyyy',
    ).format(_selectedDate);
    final estimate = _activeEstimate;

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
            context.pushRoute('/clmain');
          } else if (state.createOrderStatus == BlocStatus.failed) {
            AppToast.showToast(
              context: context,
              message: state.errorMessage ?? 'فشل إرسال طلب المناسبة',
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
                                  value: '${args.numberOfWorkers}',
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
                          const SizedBox(height: 10),
                          ClServiceAddressSectionWidget(
                            locationName:
                                _selectedAddress?.label ?? 'اختر عنوان الخدمة',
                            address:
                                _selectedAddress?.line1 ??
                                'اضغط لتغيير العنوان',
                            onChangeTap: _selectAddress,
                          ),
                          const SizedBox(height: 16),
                          ClServicePreviousWorkersSectionWidget(
                            workers: state.previousWorkers.list,
                            selectedWorkerId: state.selectedWorkerId,
                            isLoading:
                                state.previousWorkersStatus ==
                                BlocStatus.loading,
                            errorMessage:
                                state.previousWorkersStatus == BlocStatus.failed
                                ? state.errorMessage
                                : null,
                            onSelectWorker: (workerId) {
                              bloc.add(
                                SetPreferredWorkerEvent(workerId: workerId),
                              );
                              _requestEventEstimate(
                                state,
                                selectedWorkerId: workerId,
                              );
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
                          const SizedBox(height: 12),
                          ClServiceGenderPreferenceSectionWidget(
                            selectedPreference: _selectedGenderPreference,
                            onChanged: (value) {
                              setState(() {
                                _selectedGenderPreference = value;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          ClServiceCouponSectionWidget(
                            couponController: _couponController,
                            status: _couponStatus,
                            message: _couponMessage,
                            onApply: _onApplyCoupon,
                          ),
                          const SizedBox(height: 12),
                          ClServiceOrderSummarySectionWidget(
                            basePrice: estimate?.pricing?.basePrice ?? 0,
                            travelFee: estimate?.pricing?.travelFee ?? 0,
                            addonsTotal: estimate?.pricing?.addonsTotal ?? 0,
                            totalPrice: estimate?.pricing?.totalPrice ?? 0,
                            adminMargin: estimate?.pricing?.adminMargin,
                            isPricingFinal: estimate?.pricing?.isPricingFinal,
                            currency: estimate?.pricing?.currency ?? 'SYP',
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
}

class _OccasionInfoRow extends StatelessWidget {
  const _OccasionInfoRow({required this.label, required this.value});

  final String label;
  final String value;

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
