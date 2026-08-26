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
import '../../../profile/domain/models/address_list_item.dart';
import '../../data/models/estimate_price_response_model.dart';
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
import '../widgets/cl_female_worker_safety_confirmation_sheet.dart';
import '../widgets/cl_service_bottom_actions_widget.dart';
import '../widgets/cl_service_coupon_section_widget.dart';
import '../widgets/cl_service_gender_preference_section_widget.dart';
import '../widgets/cl_service_gradient_info_card_widget.dart';
import '../widgets/cl_service_order_summary_section_widget.dart';
import '../widgets/cl_service_previous_workers_section_widget.dart';
import '../widgets/cl_service_section_card_widget.dart';
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

  double get _defaultSessionHours {
    final routedHours = _routeArgs?.hours;
    if (routedHours != null && routedHours > 0) return routedHours;
    final fromRecommendation = _activeEstimate?.recommendation?.hours;
    if (fromRecommendation != null && fromRecommendation > 0) {
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

  int get _estimatedSqm => _activeEstimate?.size?.estimatedSqm ?? 0;

  int get _routeNumberOfWorkers {
    final requested = _routeArgs?.numberOfWorkers ?? 1;
    return requested < 1 ? 1 : requested;
  }

  int get _resolvedNumberOfWorkers => resolveEventWorkerCountForHours(
    hours: _defaultSessionHours,
    requestedWorkers: _routeNumberOfWorkers,
  );

  bool get _isMultiDay => _sessions.length > 1;

  _EventSessionDraft? get _firstSession =>
      _sessions.isEmpty ? null : _sessions.first;

  _EventSessionDraft? get _lastSession =>
      _sessions.isEmpty ? null : _sessions.last;

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
    final numberOfWorkers = _resolvedNumberOfWorkers;
    final firstSession = _firstSession!;
    final lastSession = _lastSession!;
    final scheduleDayLabel = _isMultiDay
        ? '${_sessions.length} أيام'
        : CleaningDateTimeUiFormat.weekday(firstSession.date);
    final scheduleDateLabel = _isMultiDay
        ? '${CleaningDateTimeUiFormat.date(firstSession.date)} - ${CleaningDateTimeUiFormat.date(lastSession.date)}'
        : CleaningDateTimeUiFormat.date(firstSession.date);
    final scheduleTimeRange = _isMultiDay
        ? 'أوقات متعددة حسب كل يوم'
        : CleaningDateTimeUiFormat.timeRange(
            firstSession.time,
            firstSession.endTime,
          );

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
              message: _isMultiDay
                  ? 'تم إنشاء طلب المناسبة متعدد الأيام بنجاح'
                  : 'تم إنشاء الطلب بنجاح، وهو الآن قيد الانتظار',
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
                            estimatedHours: _scheduleTotalHours,
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
                                  label: 'عدد الأيام',
                                  value: '${_sessions.length}',
                                ),
                                const SizedBox(height: 8),
                                _OccasionInfoRow(
                                  label: 'إجمالي الساعات لكل عامل',
                                  value: '${_formatHours(_scheduleTotalHours)} ساعة',
                                ),
                                const SizedBox(height: 8),
                                _OccasionInfoRow(
                                  label: 'عدد العمال',
                                  value: '$numberOfWorkers',
                                ),
                                const SizedBox(height: 8),
                                _OccasionInfoRow(
                                  label: 'إجمالي ساعات العمل',
                                  value:
                                      '${_formatHours(_scheduleTotalHours * numberOfWorkers)} ساعة',
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
                          _buildMultiDayScheduleCard(),
                          const SizedBox(height: 10),
                          ClServiceGenderPreferenceSectionWidget(
                            selectedPreference: state.genderPreference,
                            onChanged: (preference) {
                              _handleGenderPreferenceChanged(
                                bloc,
                                preference,
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          ClServicePreviousWorkersSectionWidget(
                            workers: filterPreviousWorkersByGender(
                              state.previousWorkers.list,
                              state.genderPreference,
                            ),
                            selectedWorkerIds: state.selectedWorkerIds,
                            isLoading:
                                state.previousWorkersStatus ==
                                BlocStatus.loading,
                            errorMessage:
                                state.previousWorkersStatus == BlocStatus.failed
                                ? state.errorMessage
                                : null,
                            onSelectWorker: (workerId) {
                              final updatedWorkerIds = List<int>.from(
                                state.selectedWorkerIds,
                              );
                              if (updatedWorkerIds.contains(workerId)) {
                                updatedWorkerIds.remove(workerId);
                              } else {
                                updatedWorkerIds.add(workerId);
                              }
                              bloc.add(
                                SetPreferredWorkerEvent(workerId: workerId),
                              );
                              _requestUpdatedEstimate(
                                state,
                                selectedWorkerIds: updatedWorkerIds,
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
                            scheduleDayLabel: scheduleDayLabel,
                            scheduleDateLabel: scheduleDateLabel,
                            scheduleTimeRange: scheduleTimeRange,
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

  Widget _buildMultiDayScheduleCard() {
    return ClServiceSectionCardWidget(
      key: const Key('occasion_multi_day_schedule_card'),
      step: 0,
      showStepBadge: false,
      title: 'أيام ووقت المناسبة',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText.bodySmall(
                  '${_sessions.length} ${_sessions.length == 1 ? 'يوم مختار' : 'أيام مختارة'}',
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF374151),
                ),
              ),
              TextButton.icon(
                key: const Key('add_event_session_day'),
                onPressed: _addSessionDate,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('إضافة يوم'),
              ),
            ],
          ),
          if (_sessions.length > 1) ...[
            const SizedBox(height: 4),
            OutlinedButton.icon(
              key: const Key('apply_event_time_to_all'),
              onPressed: _applyFirstSessionToAll,
              icon: const Icon(Icons.copy_all_outlined, size: 18),
              label: const Text('تطبيق وقت ومدة اليوم الأول على جميع الأيام'),
            ),
          ],
          const SizedBox(height: 10),
          ...List.generate(_sessions.length, (index) {
            final session = _sessions[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == _sessions.length - 1 ? 0 : 10,
              ),
              child: _EventSessionCard(
                sequence: index + 1,
                session: session,
                canRemove: _sessions.length > 1,
                onEditTime: () => _pickSessionTime(index),
                onEditDuration: () => _editSessionDuration(index),
                onRemove: () => _removeSession(index),
              ),
            );
          }),
        ],
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
      _sessions.add(
        _EventSessionDraft(
          date: CleaningScheduleDateTimeLogic.tomorrowDate(),
          time: '09:00',
          hours: args.hours > 0 ? args.hours : 4,
        ),
      );
      _sortSessions();
      _requestPreviousWorkers();
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

  Future<void> _addSessionDate() async {
    final startDate = CleaningScheduleDateTimeLogic.tomorrowDate();
    final initialDate = _lastSession?.date.add(const Duration(days: 1)) ?? startDate;
    final value = await AppPickers.showAppDatePicker(
      context: context,
      startDate: startDate,
      initialDate: initialDate.isBefore(startDate) ? startDate : initialDate,
    );
    if (value.isEmpty) return;
    final date = CleaningScheduleDateTimeLogic.parseDateApi(value);
    if (date == null) return;
    final duplicate = _sessions.any((session) => _isSameDate(session.date, date));
    if (duplicate) {
      AppToast.showToast(
        context: context,
        message: 'هذا اليوم مضاف بالفعل إلى جدول المناسبة',
        type: ToastificationType.warning,
      );
      return;
    }
    final template = _firstSession;
    setState(() {
      _sessions.add(
        _EventSessionDraft(
          date: date,
          time: template?.time ?? '09:00',
          hours: template?.hours ?? _defaultSessionHours,
        ),
      );
      _sortSessions();
    });
    _onScheduleChanged();
  }

  Future<void> _pickSessionTime(int index) async {
    final value = await AppPickers.showAppTimePicker(context: context);
    if (value.isEmpty || index < 0 || index >= _sessions.length) return;
    setState(() {
      _sessions[index].time = CleaningScheduleDateTimeLogic.normalizeTimeHhMm(
        value,
      );
      _sortSessions();
    });
    _onScheduleChanged();
  }

  Future<void> _editSessionDuration(int index) async {
    if (index < 0 || index >= _sessions.length) return;
    final controller = TextEditingController(
      text: _formatHours(_sessions[index].hours),
    );
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}(\.\d{0,2})?')),
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
                    if (hours == null || hours <= 0 || hours > 24) {
                      setDialogState(() {
                        errorText = 'يجب أن تكون المدة أكبر من 0 وحتى 24 ساعة';
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
    controller.dispose();
    if (result == null || !mounted) return;
    setState(() {
      _sessions[index].hours = result;
    });
    _onScheduleChanged();
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
        _sessions[index]
          ..time = source.time
          ..hours = source.hours;
      }
    });
    _onScheduleChanged();
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _onScheduleChanged() {
    if (_appliedCouponCode != null) {
      setState(() {
        _appliedCouponCode = null;
        _couponStatus = ClCouponUiStatus.idle;
        _couponMessage = 'تم تعديل جدول المناسبة. أعد تطبيق الكوبون.';
      });
    }
    _requestPreviousWorkers();
    final state = _bloc?.state;
    if (state != null) _requestUpdatedEstimate(state);
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
          scheduledDate: CleaningScheduleDateTimeLogic.formatDateApi(first.date),
          scheduledTime: first.time,
          durationHours: first.hours,
          eventSessions: _eventSessionInputs,
        ),
        isReload: true,
      ),
    );
  }

  Future<void> _handleGenderPreferenceChanged(
    ClMainBloc bloc,
    CleaningGenderPreference preference,
  ) async {
    final selectedWorkerIds = _workerIdsMatchingPreference(
      bloc.state,
      preference,
    );

    if (preference != CleaningGenderPreference.female) {
      bloc.add(SetGenderPreferenceEvent(preference: preference));
      _requestUpdatedEstimate(
        bloc.state,
        selectedWorkerIds: selectedWorkerIds,
      );
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
        _requestUpdatedEstimate(
          bloc.state,
          selectedWorkerIds: selectedWorkerIds,
        );
      },
    );
  }

  List<int> _workerIdsMatchingPreference(
    ClMainState state,
    CleaningGenderPreference preference,
  ) {
    if (preference == CleaningGenderPreference.any) {
      return List<int>.from(state.selectedWorkerIds);
    }

    final allowedIds = filterPreviousWorkersByGender(
      state.previousWorkers.list,
      preference,
    ).map((worker) => worker.id).whereType<int>().toSet();

    return state.selectedWorkerIds
        .where(allowedIds.contains)
        .toList(growable: false);
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
    if (_sessions.isEmpty) return 'يرجى اختيار يوم واحد على الأقل';
    if (_sessions.length > 31) return 'الحد الأعلى لأيام المناسبة هو 31 يوماً';
    final seenDates = <String>{};
    for (var index = 0; index < _sessions.length; index++) {
      final session = _sessions[index];
      final dateKey = CleaningScheduleDateTimeLogic.formatDateApi(session.date);
      if (!seenDates.add(dateKey)) {
        return 'لا يمكن إضافة اليوم نفسه أكثر من مرة';
      }
      if (!RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(session.time)) {
        return 'وقت اليوم ${index + 1} غير صالح';
      }
      if (session.hours <= 0 || session.hours > 24) {
        return 'مدة اليوم ${index + 1} يجب أن تكون بين 0 و24 ساعة';
      }
    }
    return null;
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

    final scheduleError = _validateSchedule();
    if (scheduleError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(scheduleError)),
      );
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

    final first = _firstSession!;
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
          hours: _scheduleTotalHours,
          eventSessions: _eventSessionInputs,
          address: selectedAddress.line1,
          locationName: selectedAddress.label,
          scheduledDate: CleaningScheduleDateTimeLogic.formatDateApi(first.date),
          scheduledTime: first.time,
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
  final DateTime date;
  String time;
  double hours;

  _EventSessionDraft({
    required this.date,
    required this.time,
    required this.hours,
  });

  String get endTime => formatClServiceEndTime(
    startTime: time,
    durationHours: hours,
  );
}

class _EventSessionCard extends StatelessWidget {
  final int sequence;
  final _EventSessionDraft session;
  final bool canRemove;
  final VoidCallback onEditTime;
  final VoidCallback onEditDuration;
  final VoidCallback onRemove;

  const _EventSessionCard({
    required this.sequence,
    required this.session,
    required this.canRemove,
    required this.onEditTime,
    required this.onEditDuration,
    required this.onRemove,
  });

  String _hours(double value) =>
      value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('event_session_card_$sequence'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText.bodyMedium(
                  'اليوم $sequence',
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
              if (canRemove)
                IconButton(
                  tooltip: 'إزالة اليوم',
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFB91C1C)),
                ),
            ],
          ),
          AppText.bodySmall(
            '${CleaningDateTimeUiFormat.weekday(session.date)}، ${CleaningDateTimeUiFormat.date(session.date)}',
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 10),
          _OccasionInfoRow(
            label: 'من',
            value: CleaningDateTimeUiFormat.time(session.time),
          ),
          const SizedBox(height: 6),
          _OccasionInfoRow(
            label: 'إلى',
            value: CleaningDateTimeUiFormat.time(session.endTime),
          ),
          const SizedBox(height: 6),
          _OccasionInfoRow(
            label: 'المدة',
            value: '${_hours(session.hours)} ساعة',
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEditTime,
                  icon: const Icon(Icons.schedule, size: 17),
                  label: const Text('تعديل الوقت'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEditDuration,
                  icon: const Icon(Icons.timelapse, size: 17),
                  label: const Text('تعديل المدة'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
