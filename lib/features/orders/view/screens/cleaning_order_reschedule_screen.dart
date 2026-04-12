import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/extensions/num_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../cl_main/domain/usecases/estimate_cleaning_price_use_case.dart';
import '../../../cl_main/view/manager/bloc/cl_main_bloc.dart';
import '../../../cl_main/view/widgets/app_pickers.dart';
import '../../../cl_main/view/widgets/cl_service_schedule_section_widget.dart';
import '../../../profile/view/widgets/personal_details_app_bar.dart';
import '../../data/models/cleaning_orders_api_models.dart';
import '../../domain/usecases/patch_cleaning_order_use_case.dart';

class CleaningOrderRescheduleArgs {
  const CleaningOrderRescheduleArgs({required this.order});

  final CleaningOrderModel order;
}

@AutoRoutePage(path: '/cleaning-order-reschedule')
class CleaningOrderRescheduleScreen extends StatefulWidget {
  const CleaningOrderRescheduleScreen({super.key, required this.args});

  final CleaningOrderRescheduleArgs args;

  @override
  State<CleaningOrderRescheduleScreen> createState() => _CleaningOrderRescheduleScreenState();
}

class _CleaningOrderRescheduleScreenState extends State<CleaningOrderRescheduleScreen> {
  late DateTime _selectedDate;
  late TextEditingController _fromTimeController;
  late TextEditingController _toTimeController;
  late final ClMainBloc _clMainBloc;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _clMainBloc = getIt<ClMainBloc>();
    _selectedDate = _resolveInitialDate(widget.args.order.scheduledDate);
    _fromTimeController = TextEditingController(text: _resolveInitialTime(widget.args.order.scheduledTime, fallback: '09:00'));
    _toTimeController = TextEditingController(text: '23:00');
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
    return 'بيانات الطلب غير مكتملة، لا يمكن تعديل الموعد حالياً';
  }

  void _requestEstimate() {
    final missingDataMessage = _missingDataMessage;
    if (missingDataMessage != null) {
      return;
    }

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

  Future<void> _onSave() async {
    if (_isSaving || _missingDataMessage != null) return;
    final order = widget.args.order;
    final details = order.propertyDetails!;

    setState(() {
      _isSaving = true;
    });

    final response = await getIt<PatchCleaningOrderUseCase>()(
      PatchCleaningOrderParams(
        cleaningOrderId: order.id!,
        propertyType: order.propertyType!,
        scheduledDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
        scheduledTime: _fromTimeController.text,
        address: details.address ?? '',
        bedrooms: details.bedrooms!,
        rooms: details.rooms!,
        bathrooms: details.bathrooms!,
        livingRoomSize: details.livingRoomSize!,
        addressLatitude: order.addressLatitude!,
        addressLongitude: order.addressLongitude!,
      ),
    );
    if (!mounted) return;

    response.fold(
      (failure) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (_) {
        setState(() {
          _isSaving = false;
        });
        Navigator.of(context).pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayAr = DateFormat('EEEE', 'ar').format(_selectedDate);
    final dayEn = DateFormat('EEEE', 'en').format(_selectedDate);
    final isSaveDisabled = _isSaving || _missingDataMessage != null;

    return BlocProvider.value(
      value: _clMainBloc,
      child: BlocBuilder<ClMainBloc, ClMainState>(
        builder: (context, state) {
          final pricing = state.estimatePrice?.pricing;
          final subtotal = (pricing?.basePrice ?? 0) + (pricing?.travelFee ?? 0) + (pricing?.addonsTotal ?? 0);
          final total = pricing?.totalPrice ?? 0;
          final tax = math.max(0, total - subtotal).toDouble();
          final isLoadingEstimate =
              _missingDataMessage == null &&
              (state.estimatePriceStatus == BlocStatus.loading ||
                  (state.estimatePriceStatus == BlocStatus.init && state.estimatePrice == null));
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
                        padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 24),
                        child: Column(
                          children: [
                            ClServiceScheduleSectionWidget(
                              dayAr: dayAr,
                              dayEn: dayEn,
                              fromTimeController: _fromTimeController,
                              toTimeController: _toTimeController,
                              onPickDate: _pickDate,
                              onPickFromTime: _pickFromTime,
                              onPickToTime: _pickToTime,
                            ),
                            const SizedBox(height: 12),
                            if (isLoadingEstimate) ...[
                              const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: CircularProgressIndicator()),
                            ] else if (showSummary) ...[
                              _CleaningOrderRescheduleSummaryCard(subtotal: subtotal, tax: tax, total: total),
                            ] else ...[
                              const SizedBox.shrink(),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Container(
                      color: const Color(0xFFF3F4F6),
                      padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 20),
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
                                  disabledBackgroundColor: const Color(0xFF8DD8DE),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  elevation: 2,
                                  shadowColor: Colors.black.withAlpha(25),
                                ),
                                child: _isSaving
                                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Text(
                                        'حفظ التعديلات',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFA8ABC9),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: const Color(0xFFC7C9DC),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  elevation: 2,
                                  shadowColor: Colors.black.withAlpha(22),
                                ),
                                child: const Text(
                                  'تراجع',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
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
  const _CleaningOrderRescheduleSummaryCard({required this.subtotal, required this.tax, required this.total});

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
            style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w800, fontSize: 20),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2196F3), width: 1.2),
          ),
          child: Column(
            children: [
              _SummaryItemRow(label: 'المبلغ الإجمالي', value: _money(subtotal)),
              const Divider(color: Color(0xFF2196F3), thickness: 1, height: 16),
              _SummaryItemRow(label: 'الضريبة', value: _money(tax)),
              const Divider(color: Color(0xFF2196F3), thickness: 1, height: 16),
              _SummaryItemRow(label: 'المجموع النهائي', value: _money(total), isTotal: true),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryItemRow extends StatelessWidget {
  const _SummaryItemRow({required this.label, required this.value, this.isTotal = false});

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final labelColor = isTotal ? const Color(0xFF1E2A78) : const Color(0xFF6B7280);
    final valueColor = isTotal ? const Color(0xFF1E2A78) : const Color(0xFF374151);
    final fontWeight = isTotal ? FontWeight.w900 : FontWeight.w600;

    return Row(
      children: [
        Text(
          label,
          style: TextStyle(color: labelColor, fontWeight: fontWeight, fontSize: 19),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(color: valueColor, fontWeight: fontWeight, fontSize: 23),
        ),
      ],
    );
  }
}
