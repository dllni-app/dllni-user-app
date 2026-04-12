import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

import '../../../profile/domain/models/address_list_item.dart';
import '../../domain/usecases/create_cleaning_order_use_case.dart';
import '../../domain/usecases/get_previous_cleaning_workers_use_case.dart';
import '../data/cl_main_route_args.dart';
import '../manager/bloc/cl_main_bloc.dart';
import '../widgets/app_pickers.dart';
import '../widgets/cl_service_address_section_widget.dart';
import '../widgets/cl_service_bottom_actions_widget.dart';
import '../widgets/cl_service_gradient_info_card_widget.dart';
import '../widgets/cl_service_order_summary_section_widget.dart';
import '../widgets/cl_service_previous_workers_section_widget.dart';
import '../widgets/cl_service_schedule_section_widget.dart';
import '../widgets/home_details_app_bar.dart';
import 'cl_worker_profile_detail_screen.dart';

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
  ClMainScheduleArgs? _routeArgs;
  bool _didReadArgs = false;
  AddressListItem? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _fromTimeController = TextEditingController(text: '09:00');
    _toTimeController = TextEditingController(text: '23:00');
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
    }
    _bloc?.add(
      GetPreviousCleaningWorkersEvent(
        params: GetPreviousCleaningWorkersParams(page: 1),
      ),
    );
  }

  @override
  void dispose() {
    _fromTimeController.dispose();
    _toTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final value = await AppPickers.showAppDatePicker(context: context);
    if (value.isEmpty) return;
    setState(() {
      _selectedDate = DateFormat('yyyy-MM-dd', 'en').parse(value);
    });
  }

  Future<void> _pickFromTime() async {
    final value = await AppPickers.showAppTimePicker(context: context);
    if (value.isEmpty) return;
    setState(() {
      _fromTimeController.text = value;
    });
  }

  Future<void> _pickToTime() async {
    final value = await AppPickers.showAppTimePicker(context: context);
    if (value.isEmpty) return;
    setState(() {
      _toTimeController.text = value;
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

  void _onSubmitPressed(ClMainState state) {
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

    final quoteId = args.estimate.quote?.quoteId;
    if (quoteId == null || quoteId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر إرسال الطلب بدون رقم عرض السعر')),
      );
      return;
    }

    final selectedAddress = _selectedAddress;

    bloc.add(
      CreateCleaningOrderEvent(
        params: CreateCleaningOrderParams(
          propertyType: args.propertyType,
          bedrooms: args.bedrooms,
          rooms: args.rooms,
          bathrooms: args.bathrooms,
          livingRoomSize: args.livingRoomSize,
          address:
              selectedAddress?.line1 ??
              'العزيزية، شارع الكتاب المقدس، جانب محل مميز 2b',
          locationName: selectedAddress?.label ?? 'المنزل',
          scheduledDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
          scheduledTime: _fromTimeController.text,
          addressLatitude: args.addressLatitude,
          addressLongitude: args.addressLongitude,
          preferredWorkerId: state.selectedWorkerId,
          quoteId: quoteId,
          termsAccepted: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayAr = DateFormat('EEEE', 'ar').format(_selectedDate);
    final dayEn = DateFormat('EEEE', 'en').format(_selectedDate);
    final estimate = _routeArgs?.estimate;
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
            previous.previousWorkersStatus != current.previousWorkersStatus,
        listener: (context, state) {
          if (state.createOrderStatus == BlocStatus.loading ||
              state.previousWorkersStatus == BlocStatus.loading) {
            Loading.show(context);
            return;
          }
          Loading.close();
          if (state.createOrderStatus == BlocStatus.success) {
            AppToast.showToast(
              context: context,
              message: 'تم إرسال الطلب بنجاح',
              type: ToastificationType.success,
            );
            context.pushRoute('/clmain');
          } else if (state.createOrderStatus == BlocStatus.failed ||
              state.previousWorkersStatus == BlocStatus.failed) {
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
                          const SizedBox(height: 10),
                          ClServiceScheduleSectionWidget(
                            dayAr: dayAr,
                            dayEn: dayEn,
                            fromTimeController: _fromTimeController,
                            toTimeController: _toTimeController,
                            onPickDate: _pickDate,
                            onPickFromTime: _pickFromTime,
                            onPickToTime: _pickToTime,
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
                          ClServicePreviousWorkersSectionWidget(
                            workers: state.previousWorkers?.data ?? const [],
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
                            },
                            onOpenWorkerProfile: (worker) async {
                              final selectedWorkerId = await context.pushRoute(
                                '/clworkerprofiledetail',
                                arguments:
                                    WorkerProfileRouteArgs.fromPreviousWorker(
                                      worker,
                                    ),
                              );
                              if (!context.mounted) return;
                              if (selectedWorkerId is int) {
                                bloc.add(
                                  SetPreferredWorkerEvent(
                                    workerId: selectedWorkerId,
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          ClServiceOrderSummarySectionWidget(
                            basePrice: estimate?.pricing?.basePrice ?? 0,
                            travelFee: estimate?.pricing?.travelFee ?? 0,
                            addonsTotal: estimate?.pricing?.addonsTotal ?? 0,
                            totalPrice: estimate?.pricing?.totalPrice ?? 0,
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
