import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/utils/app_date_time_locale.dart';
import '../../../profile/domain/models/address_list_item.dart';
import '../../data/models/estimate_price_response_model.dart';
import '../../domain/models/cleaning_assignment_mode.dart';
import '../../domain/models/cl_worker_room_assignment.dart';
import '../../domain/models/cl_worker_room_assignment_result.dart';
import '../../domain/usecases/create_cleaning_order_use_case.dart';
import '../data/cl_main_route_args.dart';
import '../manager/bloc/cl_main_bloc.dart';
import '../widgets/app_pickers.dart';
import '../widgets/cl_service_address_section_widget.dart';
import '../widgets/cl_service_bottom_actions_widget.dart';
import '../widgets/cl_service_coupon_section_widget.dart';
import '../widgets/cl_service_gradient_info_card_widget.dart';
import '../widgets/cl_service_order_summary_section_widget.dart';
import '../helpers/cl_service_schedule_time_utils.dart';
import '../widgets/cl_service_schedule_section_widget.dart';
import '../widgets/cl_service_worker_assignment_summary_widget.dart';
import '../widgets/home_details_app_bar.dart';

@AutoRoutePage()
class ClMainServiceScheduleScreen extends StatefulWidget {
  const ClMainServiceScheduleScreen({super.key});

  @override
  State<ClMainServiceScheduleScreen> createState() =>
      _ClMainServiceScheduleScreenState();
}

class _ClMainServiceScheduleScreenState
    extends State<ClMainServiceScheduleScreen> {
  ClMainBloc? _bloc;
  late DateTime _selectedDate;
  late TextEditingController _fromTimeController;
  late TextEditingController _toTimeController;
  late TextEditingController _couponController;
  ClMainScheduleArgs? _routeArgs;
  bool _didReadArgs = false;
  EstimatePriceResponseModel? _currentEstimate;
  AddressListItem? _selectedAddress;
  ClCouponUiStatus _couponStatus = ClCouponUiStatus.idle;
  String? _couponMessage;
  String? _appliedCouponCode;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(Duration(days: 1));
    _fromTimeController = TextEditingController(text: '09:00');
    _toTimeController = TextEditingController();
    _couponController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didReadArgs) return;
    _didReadArgs = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ClMainScheduleArgs) {
      _routeArgs = args;
      _bloc = args.bloc;
      _currentEstimate = args.estimate;
      _syncToTime();
    }
  }

  @override
  void dispose() {
    _fromTimeController.dispose();
    _toTimeController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final value = await AppPickers.showAppDatePicker(
      context: context,
      startDate: DateTime.now().add(Duration(days: 1)),
    );
    if (value.isEmpty) return;
    setState(() {
      _selectedDate = AppDateTimeLocale.dateFormat('yyyy-MM-dd').parse(value);
    });
  }

  void _syncToTime() {
    final estimatedHours =
        _currentEstimate?.size?.estimatedHours ??
        _routeArgs?.estimate.size?.estimatedHours ??
        0;
    _toTimeController.text = formatClServiceEndTime(
      startTime: _fromTimeController.text,
      durationHours: estimatedHours,
    );
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
    }
  }

  Future<void> _applyCoupon(String code) async {
    if (code.isEmpty) {
      setState(() {
        _couponStatus = ClCouponUiStatus.failed;
        _couponMessage = 'يرجى إدخال كود الحسم أولاً.';
      });
      return;
    }

    setState(() {
      _couponStatus = ClCouponUiStatus.loading;
      _couponMessage = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;

    final normalized = code.trim().toLowerCase();
    if (normalized == 'invalid' || normalized == 'expired') {
      setState(() {
        _couponStatus = ClCouponUiStatus.failed;
        _couponMessage = 'الكوبون غير صالح حالياً.';
        _appliedCouponCode = null;
      });
      return;
    }

    final discountText = normalized.contains('20') ? '20%' : '10%';
    setState(() {
      _couponStatus = ClCouponUiStatus.success;
      _couponMessage = 'تم تطبيق الكوبون بنجاح: خصم $discountText (تجريبي)';
      _appliedCouponCode = code;
    });
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

  Future<void> _onSubmitPressed(ClMainState state) async {
    final args = _routeArgs;
    final bloc = _bloc;
    if (args == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('بيانات الطلب غير مكتملة')));
      return;
    }
    if (bloc == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذر تهيئة حالة الطلب')));
      return;
    }

    final acceptedPledge = await _showPersonalPropertyPledgeDialog();
    if (!mounted || !acceptedPledge) return;

    final selectedAddress = _selectedAddress;
    final estimate = _currentEstimate ?? _routeArgs?.estimate;
    final normalizedAssignments = estimate?.workerRoomAssignments ?? const [];
    final workerRoomAssignments = normalizedAssignments.isNotEmpty
        ? workerRoomAssignmentsToRequestJson(normalizedAssignments)
        : buildWorkerRoomAssignmentsJson(
            slotByRoomKey: state.workerRoomAssignments,
            units: enumerateRoomUnits(args.roomSizeBreakdown),
            preferredWorkerId: state.selectedWorkerId,
            assignmentMode: state.assignmentMode,
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
          address:
              selectedAddress?.line1 ??
              'العزيزية، شارع الكتاب المقدس، جانب محل مميز 2b',
          locationName: selectedAddress?.label ?? 'المنزل',
          scheduledDate: AppDateTimeLocale.dateFormat(
            'yyyy-MM-dd',
          ).format(_selectedDate),
          scheduledTime: _fromTimeController.text,
          addressLatitude: args.addressLatitude,
          addressLongitude: args.addressLongitude,
          genderPreference: state.genderPreference,
          assignmentMode: state.assignmentMode,
          numberOfWorkers:
              state.assignmentMode == CleaningAssignmentMode.openCount
              ? state.numberOfWorkers
              : 1,
          preferredWorkerId:
              state.assignmentMode == CleaningAssignmentMode.preferredWorker
              ? state.selectedWorkerId
              : null,
          workerRoomAssignments: workerRoomAssignments.isEmpty
              ? null
              : workerRoomAssignments,
          termsAccepted: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayAr = AppDateTimeLocale.dateFormat('EEEE').format(_selectedDate);
    final dayDate = AppDateTimeLocale.dateFormat(
      'd MMM yyyy',
    ).format(_selectedDate);
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
            previous.createOrderStatus != current.createOrderStatus,
        listener: (context, state) {
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
                            estimatedHours: estimate?.size?.estimatedHours ?? 0,
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
                          ClServiceAddressSectionWidget(
                            locationName: _selectedAddress?.label ?? 'المنزل',
                            address:
                                _selectedAddress?.line1 ??
                                'العزيزية، شارع الكتاب المقدس، جانب محل مميز 2b',
                            onChangeTap: _selectAddress,
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
