import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/extensions/num_extensions.dart';
import 'package:dllni_user_app/core/models/cleaning_gender_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../cl_main/domain/usecases/create_cleaning_order_use_case.dart';
import '../../../cl_main/domain/usecases/estimate_cleaning_price_use_case.dart';
import '../../../cl_main/view/manager/bloc/cl_main_bloc.dart';
import '../../../cl_main/view/widgets/app_pickers.dart';
import '../../../cl_main/view/widgets/cl_service_gender_preference_section_widget.dart';
import '../../../cl_main/view/helpers/cl_service_schedule_time_utils.dart';
import '../../../cl_main/view/widgets/cl_service_schedule_section_widget.dart';
import '../../../profile/view/widgets/personal_details_app_bar.dart';
import '../../data/models/cleaning_orders_api_models.dart';
import '../../domain/usecases/cancel_cleaning_order_use_case.dart';
import '../helpers/cleaning_lifecycle_error_mapper.dart';
import '../helpers/cleaning_rebook_policy.dart';

class CleaningOrderRescheduleArgs {
  const CleaningOrderRescheduleArgs({required this.order});

  final CleaningOrderModel order;
}

class CleaningOrderRescheduleResult {
  const CleaningOrderRescheduleResult({
    this.newOrderId,
    this.openOrdersListFallback = false,
  });

  final int? newOrderId;
  final bool openOrdersListFallback;
}

@AutoRoutePage(path: '/cleaning-order-reschedule')
class CleaningOrderRescheduleScreen extends StatefulWidget {
  const CleaningOrderRescheduleScreen({super.key, required this.args});

  final CleaningOrderRescheduleArgs args;

  @override
  State<CleaningOrderRescheduleScreen> createState() =>
      _CleaningOrderRescheduleScreenState();
}

class _CleaningOrderRescheduleScreenState
    extends State<CleaningOrderRescheduleScreen> {
  late DateTime _selectedDate;
  late TextEditingController _fromTimeController;
  late TextEditingController _toTimeController;
  late final ClMainBloc _clMainBloc;
  CleaningGenderPreference _selectedGenderPreference =
      CleaningGenderPreference.any;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _clMainBloc = getIt<ClMainBloc>();
    _selectedDate = _resolveInitialDate(widget.args.order.scheduledDate);
    _fromTimeController = TextEditingController(
      text: _resolveInitialTime(
        widget.args.order.scheduledTime,
        fallback: '09:00',
      ),
    );
    _toTimeController = TextEditingController();
    _selectedGenderPreference = widget.args.order.genderPreference;
    _syncToTime(_parseOrderEstimatedHours());
    _requestEstimate();
  }

  @override
  void dispose() {
    _fromTimeController.dispose();
    _toTimeController.dispose();
    _clMainBloc.close();
    super.dispose();
  }

  DateTime _resolveInitialDate(String? value) {
    if (value == null || value.isEmpty) return DateTime.now();
    return DateTime.tryParse(value) ?? DateTime.now();
  }

  String _resolveInitialTime(String? value, {required String fallback}) {
    if (value == null || value.isEmpty) return fallback;
    final parts = value.split(':');
    if (parts.length < 2) return fallback;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return fallback;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  bool get _hasRequiredOrderData {
    final order = widget.args.order;
    final details = order.propertyDetails;
    return order.id != null &&
        (order.propertyType?.isNotEmpty ?? false) &&
        details != null &&
        details.bedrooms != null &&
        details.rooms != null &&
        details.bathrooms != null &&
        (details.livingRoomSize?.isNotEmpty ?? false) &&
        order.addressLatitude != null &&
        order.addressLongitude != null;
  }

  String? get _missingDataMessage {
    if (_hasRequiredOrderData) return null;
    return 'بيانات الطلب غير مكتملة، لا يمكن تعديل الموعد حاليًا';
  }

  void _requestEstimate() {
    final missingDataMessage = _missingDataMessage;
    if (missingDataMessage != null) return;

    final order = widget.args.order;
    final details = order.propertyDetails!;
    _clMainBloc.add(
      EstimateCleaningPriceEvent(
        params: EstimateCleaningPriceParams(
          propertyType: order.propertyType!,
          bedrooms: details.bedrooms!,
          rooms: details.rooms!,
          bathrooms: details.bathrooms!,
          livingRoomSize: details.livingRoomSize!,
          addressLatitude: order.addressLatitude!,
          addressLongitude: order.addressLongitude!,
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final value = await AppPickers.showAppDatePicker(context: context);
    if (value.isEmpty) return;
    setState(() {
      _selectedDate = DateFormat('yyyy-MM-dd', 'en').parse(value);
    });
  }

  double _parseOrderEstimatedHours() {
    return double.tryParse((widget.args.order.estimatedHours ?? '').trim()) ??
        0;
  }

  void _syncToTime(double estimatedHours) {
    if (estimatedHours <= 0) return;
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
      _syncToTime(_resolveEstimatedHours(_clMainBloc.state));
    });
  }

  double _resolveEstimatedHours(ClMainState state) {
    final fromEstimate = state.estimatePrice?.size?.estimatedHours;
    if (fromEstimate != null && fromEstimate > 0) return fromEstimate;
    return _parseOrderEstimatedHours();
  }

  String _leadTimeBlockMessage(Duration? remaining) {
    if (remaining == null) {
      return 'لا يمكن تعديل العنوان أو الموعد قبل أقل من 24 ساعة من وقت الخدمة.';
    }
    final hours = remaining.inHours;
    if (hours <= 0) {
      return 'موعد الخدمة قريب جدًا، لا يمكن تعديل العنوان أو الموعد.';
    }
    return 'لا يمكن تعديل العنوان أو الموعد عندما يتبقى أقل من 24 ساعة. المتبقي: $hours ساعة.';
  }

  Future<void> _onSave() async {
    if (_isSaving || _missingDataMessage != null) return;
    final order = widget.args.order;
    final details = order.propertyDetails!;

    final leadTimeCheck = CleaningRebookPolicy.evaluateLeadTime(
      scheduledDate: order.scheduledDate,
      scheduledTime: order.scheduledTime,
    );
    if (!leadTimeCheck.allowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_leadTimeBlockMessage(leadTimeCheck.remaining))),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final policy = CleaningRebookPolicy(
      cancelOrder: (params) => getIt<CancelCleaningOrderUseCase>()(params),
      createOrder: (params) => getIt<CreateCleaningOrderUseCase>()(params),
    );
    final result = await policy.execute(
      request: CleaningRebookRequest(
        existingOrderId: order.id!,
        propertyType: order.propertyType!,
        bedrooms: details.bedrooms!,
        rooms: details.rooms!,
        bathrooms: details.bathrooms!,
        livingRoomSize: details.livingRoomSize!,
        address: details.address ?? '',
        locationName: order.locationName ?? 'المنزل',
        scheduledDate: DateFormat('yyyy-MM-dd', 'en').format(_selectedDate),
        scheduledTime: _fromTimeController.text,
        addressLatitude: order.addressLatitude!,
        addressLongitude: order.addressLongitude!,
        genderPreference: _selectedGenderPreference,
        preferredWorkerId: order.workerId,
      ),
    );
    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    result.fold(
      (failure) {
        final message = CleaningLifecycleErrorMapper.mapLifecycleActionFailure(
          failure,
          invalidStateMessage:
              'لا يمكن إعادة حجز الطلب في حالته الحالية. تحقق من بيانات الطلب وحاول لاحقًا.',
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      },
      (outcome) {
        if (outcome.newOrderId == null) {
          Navigator.of(context).pop(
            const CleaningOrderRescheduleResult(openOrdersListFallback: true),
          );
          return;
        }
        Navigator.of(context).pop(
          CleaningOrderRescheduleResult(
            newOrderId: outcome.newOrderId,
            openOrdersListFallback: false,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayAr = DateFormat('EEEE', 'en').format(_selectedDate);
    final dayDate = DateFormat('d MMM yyyy', 'en').format(_selectedDate);
    final isSaveDisabled = _isSaving || _missingDataMessage != null;

    return BlocProvider.value(
      value: _clMainBloc,
      child: BlocConsumer<ClMainBloc, ClMainState>(
        listenWhen: (previous, current) =>
            previous.estimatePrice?.size?.estimatedHours !=
            current.estimatePrice?.size?.estimatedHours,
        listener: (context, state) {
          _syncToTime(_resolveEstimatedHours(state));
        },
        builder: (context, state) {
          final pricing = state.estimatePrice?.pricing;
          final subtotal =
              (pricing?.basePrice ?? 0) +
              (pricing?.travelFee ?? 0) +
              (pricing?.addonsTotal ?? 0);
          final total = pricing?.totalPrice ?? 0;
          final tax = math.max(0, total - subtotal).toDouble();
          final isLoadingEstimate =
              _missingDataMessage == null &&
              (state.estimatePriceStatus == BlocStatus.loading ||
                  (state.estimatePriceStatus == BlocStatus.init &&
                      state.estimatePrice == null));
          final showSummary = pricing != null;

          return Directionality(
            textDirection: ui.TextDirection.rtl,
            child: Scaffold(
              backgroundColor: const Color(0xFFF3F4F6),
              body: SafeArea(
                child: Column(
                  children: [
                    const PersonalDetailsAppBar(title: 'تعديل معلومات الحجز'),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          20,
                          10,
                          20,
                          24,
                        ),
                        child: Column(
                          children: [
                            ClServiceScheduleSectionWidget(
                              dayAr: dayAr,
                              dayDate: dayDate,
                              fromTimeController: _fromTimeController,
                              toTimeController: _toTimeController,
                              onPickDate: _pickDate,
                              onPickFromTime: _pickFromTime,
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
                            if (isLoadingEstimate) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: CircularProgressIndicator(),
                              ),
                            ] else if (showSummary) ...[
                              _CleaningOrderRescheduleSummaryCard(
                                subtotal: subtotal,
                                tax: tax,
                                total: total,
                              ),
                            ] else ...[
                              const SizedBox.shrink(),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Container(
                      color: const Color(0xFFF3F4F6),
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        20,
                        8,
                        20,
                        20,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: isSaveDisabled ? null : _onSave,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF11B9C8),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: const Color(
                                    0xFF8DD8DE,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 2,
                                  shadowColor: Colors.black.withAlpha(25),
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'حفظ التعديلات',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isSaving
                                    ? null
                                    : () => Navigator.of(context).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFA8ABC9),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: const Color(
                                    0xFFC7C9DC,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 2,
                                  shadowColor: Colors.black.withAlpha(22),
                                ),
                                child: const Text(
                                  'تراجع',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CleaningOrderRescheduleSummaryCard extends StatelessWidget {
  const _CleaningOrderRescheduleSummaryCard({
    required this.subtotal,
    required this.tax,
    required this.total,
  });

  final double subtotal;
  final double tax;
  final double total;

  String _money(double value) => '${value.formatWithComma()} ل.س';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'ملخص الطلب',
            style: TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEEEEE), width: 1.2),
          ),
          child: Column(
            children: [
              _SummaryItemRow(
                label: 'المبلغ الإجمالي',
                value: _money(subtotal),
              ),
              const Divider(color: Color(0xFFEEEEEE), thickness: 1, height: 16),
              _SummaryItemRow(label: 'الضريبة', value: _money(tax)),
              const Divider(color: Color(0xFFEEEEEE), thickness: 1, height: 16),
              _SummaryItemRow(
                label: 'المجموع النهائي',
                value: _money(total),
                isTotal: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryItemRow extends StatelessWidget {
  const _SummaryItemRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final labelColor = isTotal
        ? const Color(0xFF1E2A78)
        : const Color(0xFF6B7280);
    final valueColor = isTotal
        ? const Color(0xFF1E2A78)
        : const Color(0xFF374151);
    final fontWeight = isTotal ? FontWeight.w900 : FontWeight.w600;

    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontWeight: fontWeight,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: fontWeight,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
