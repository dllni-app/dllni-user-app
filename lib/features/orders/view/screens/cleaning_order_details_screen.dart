import 'package:common_package/common_package.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/extensions/num_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../cl_main/view/widgets/cl_service_address_section_widget.dart';
import '../../../cl_main/view/widgets/cl_service_day_preview_card_widget.dart';
import '../../../cl_main/view/widgets/cl_service_section_card_widget.dart';
import '../../../cl_main/view/widgets/cl_service_time_picker_field_widget.dart';
import '../../data/models/cleaning_orders_api_models.dart';
import '../../domain/usecases/fetch_cleaning_order_details_use_case.dart';
import '../../../profile/view/widgets/personal_details_app_bar.dart';
import '../manager/bloc/orders_bloc.dart';
import '../widgets/cleaning_cancel_reason_dialog.dart';
import 'cleaning_order_problem_report_screen.dart';
import 'cleaning_order_reschedule_screen.dart';

class CleaningOrderDetailsArgs {
  const CleaningOrderDetailsArgs({required this.orderId});

  final int orderId;
}

@AutoRoutePage(path: '/cleaning-order-details')
class CleaningOrderDetailsScreen extends StatefulWidget {
  const CleaningOrderDetailsScreen({super.key, required this.args});

  final CleaningOrderDetailsArgs args;

  @override
  State<CleaningOrderDetailsScreen> createState() => _CleaningOrderDetailsScreenState();
}

class _CleaningOrderDetailsScreenState extends State<CleaningOrderDetailsScreen> {
  CleaningOrderDetailModel? _order;
  bool _isLoading = true;
  String? _loadError;
  late TextEditingController _fromTimeController;
  late TextEditingController _toTimeController;

  @override
  void initState() {
    super.initState();
    _fromTimeController = TextEditingController();
    _toTimeController = TextEditingController();
    _fetchDetails();
  }

  @override
  void dispose() {
    _fromTimeController.dispose();
    _toTimeController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    final Either<Failure, FetchCleaningOrderDetailsModel> response = await getIt<FetchCleaningOrderDetailsUseCase>()(
      FetchCleaningOrderDetailsParams(orderId: widget.args.orderId),
    );
    if (!mounted) return;
    response.fold(
      (failure) => setState(() {
        _isLoading = false;
        _loadError = failure.message;
      }),
      (result) => setState(() {
        _order = result.data;
        _isLoading = false;
        _loadError = result.data == null ? 'تعذر تحميل تفاصيل الطلب' : null;
      }),
    );
  }

  String _statusLabel(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'pending':
        return 'في مرحلة الاستعداد';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      case 'in_progress':
        return 'قيد التنفيذ';
      default:
        return 'قيد المعالجة';
    }
  }

  String _serviceLabel(String? propertyType) {
    switch ((propertyType ?? '').toLowerCase()) {
      case 'studio':
        return 'تنظيف ستوديو';
      case 'apartment':
        return 'تنظيف شقة';
      case 'house':
        return 'تنظيف منزل';
      case 'villa':
        return 'تنظيف فيلا';
      default:
        return 'تنظيف منزل';
    }
  }

  String _bookingLabel(CleaningOrderDetailModel order) {
    final bookingNumber = order.bookingNumber;
    if (bookingNumber == null || bookingNumber.isEmpty) {
      return '#${order.id ?? '-'}';
    }
    return '#$bookingNumber';
  }

  DateTime? _resolveStartDateTime(CleaningOrderDetailModel order) {
    final date = order.scheduledDate;
    final time = order.scheduledTime;
    if (date == null || date.isEmpty || time == null || time.isEmpty) {
      return null;
    }
    final raw = '$date ${time.split('.').first}';
    return DateTime.tryParse(raw);
  }

  double _resolveHours(CleaningOrderDetailModel order) {
    final total = order.totalHours;
    if (total != null && total > 0) return total;
    return double.tryParse(order.estimatedHours ?? '') ?? 0;
  }

  String _timeLabel(DateTime? value) {
    if (value == null) return '-';
    final hour = value.hour;
    final minute = value.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final normalizedHour = hour % 12 == 0 ? 12 : hour % 12;
    return '${normalizedHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  String _dayLabel(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '-';
    final date = DateTime.tryParse(rawDate);
    if (date == null) return '-';
    const arabicDays = <String>['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
    return arabicDays[date.weekday - 1];
  }

  String _dayEnLabel(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '-';
    final date = DateTime.tryParse(rawDate);
    if (date == null) return '-';
    const englishDays = <String>['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return englishDays[date.weekday - 1];
  }

  Widget _card({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }

  Future<void> _callWorker(String? phone) async {
    final value = phone?.trim();
    if (value == null || value.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('رقم الهاتف غير متوفر')));
      return;
    }
    final uri = Uri(scheme: 'tel', path: value);
    final launched = await launchUrl(uri);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر فتح تطبيق الاتصال')));
    }
  }

  Future<void> _goToReschedule(CleaningOrderDetailModel order) async {
    final result = await context.pushRoute('/cleaning-order-reschedule', arguments: CleaningOrderRescheduleArgs(order: order.toCleaningOrderModel()));
    if (result == true && mounted) {
      _fetchDetails();
    }
  }

  void _reportIssue(CleaningOrderDetailModel order) {
    context.pushRoute('/cleaning-order-problem', arguments: CleaningOrderProblemReportArgs(order: order.toCleaningOrderModel()));
  }

  Future<void> _cancelOrder(CleaningOrderDetailModel order) async {
    final orderId = order.id;
    if (orderId == null) return;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CleaningCancelReasonDialog(orderId: orderId, bloc: context.read<OrdersBloc>()),
    );
    if (result == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xffF3F4F6),
        appBar: AppBar(title: const Text('تفاصيل الطلب'), centerTitle: true, backgroundColor: const Color(0xffF3F4F6), elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadError != null) {
      return Scaffold(
        backgroundColor: const Color(0xffF3F4F6),
        appBar: AppBar(title: const Text('تفاصيل الطلب'), centerTitle: true, backgroundColor: const Color(0xffF3F4F6), elevation: 0),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_loadError!, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                TextButton(onPressed: _fetchDetails, child: const Text('إعادة المحاولة')),
              ],
            ),
          ),
        ),
      );
    }
    if (order == null) {
      return Scaffold(
        backgroundColor: const Color(0xffF3F4F6),
        body: const SafeArea(
          child: Column(
            children: [
              PersonalDetailsAppBar(title: 'تفاصيل الطلب'),
              Expanded(child: Center(child: Text('تعذر تحميل تفاصيل الطلب'))),
            ],
          ),
        ),
      );
    }
    final startDateTime = _resolveStartDateTime(order);
    final endDateTime = startDateTime?.add(Duration(minutes: (_resolveHours(order) * 60).round()));
    _fromTimeController.text = _timeLabel(startDateTime);
    _toTimeController.text = _timeLabel(endDateTime);
    final isCompleted = (order.status ?? '').toLowerCase() == 'completed';
    return Scaffold(
      backgroundColor: const Color(0xffF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            const PersonalDetailsAppBar(title: 'تفاصيل الطلب'),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchDetails,
                child: ListView(
                  padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 24),
                  children: [
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'معلومات الخدمة',
                            style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xff1F2937)),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _bookingLabel(order),
                                  style: const TextStyle(color: Color(0xff9CA3AF), fontWeight: FontWeight.w600),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(color: const Color(0xFFE2F5F4), borderRadius: BorderRadius.circular(16)),
                                child: Text(
                                  _statusLabel(order.status),
                                  style: const TextStyle(color: Color(0xff0CBBC7), fontWeight: FontWeight.w700, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _serviceLabel(order.propertyType),
                            style: const TextStyle(color: Color(0xff111827), fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClServiceSectionCardWidget(
                      step: 1,
                      showStepBadge: false,
                      title: 'وقت و تاريخ الخدمة',
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ClServiceDayPreviewCardWidget(dayAr: _dayLabel(order.scheduledDate), dayEn: _dayEnLabel(order.scheduledDate)),
                              ),
                              const SizedBox(width: 10),
                              FilledButton(
                                onPressed: () => _goToReschedule(order),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E2A78),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: AppText.bodyMedium('تغيير اليوم', color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsetsDirectional.all(12),
                            decoration: BoxDecoration(color: const Color(0xFFF7F7F9), borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText.bodyMedium('مدة الخدمة', color: const Color(0xFF656B78), fontWeight: FontWeight.w700),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClServiceTimePickerFieldWidget(
                                        title: 'من',
                                        controller: _fromTimeController,
                                        onTap: () => _goToReschedule(order),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ClServiceTimePickerFieldWidget(
                                        title: 'إلى',
                                        controller: _toTimeController,
                                        onTap: () => _goToReschedule(order),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _goToReschedule(order),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: const Color(0xffE5E7EB),
                                foregroundColor: const Color(0xff1E2A78),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('تغيير موعد الخدمة', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClServiceAddressSectionWidget(locationName: order.locationName ?? 'المنزل', address: order.propertyDetails?.address ?? '-'),
                    const SizedBox(height: 12),
                    _card(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: order.worker?.avatarUrl == null ? null : NetworkImage(order.worker!.avatarUrl!),
                            child: order.worker?.avatarUrl == null ? const Icon(Icons.person, size: 20) : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.worker?.name ?? 'مقدم الخدمة',
                                  style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xff1F2937)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '⭐ ${order.worker?.averageRating?.toStringAsFixed(1) ?? '-'} • مقدم الخدمة',
                                  style: const TextStyle(color: Color(0xff6B7280), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () => _callWorker(order.worker?.phone),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(color: const Color(0xffF3F4F6), borderRadius: BorderRadius.circular(19)),
                              child: const Icon(Icons.call, color: Color(0xff111827), size: 19),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ملخص الطلب',
                            style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xff1F2937)),
                          ),
                          const SizedBox(height: 10),
                          _SummaryRow(title: 'تكلفة الخدمة', value: '${(order.basePrice ?? 0).formatWithComma()} ل.س'),
                          const SizedBox(height: 6),
                          _SummaryRow(title: 'رسوم التنقل', value: '${(order.travelFee ?? 0).formatWithComma()} ل.س'),
                          if ((order.addonsTotal ?? 0) > 0) ...[
                            const SizedBox(height: 6),
                            _SummaryRow(title: 'إضافات', value: '${(order.addonsTotal ?? 0).formatWithComma()} ل.س'),
                          ],
                          const SizedBox(height: 10),
                          const Divider(color: Color(0xffE5E7EB)),
                          const SizedBox(height: 10),
                          _SummaryRow(title: 'الإجمالي النهائي', value: '${(order.totalPrice ?? 0).formatWithComma()} ل.س', isTotal: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => isCompleted ? _reportIssue(order) : _cancelOrder(order),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: isCompleted ? const Color(0xff9CA3AF).withAlpha(35) : const Color(0xffFEE2E2),
                          foregroundColor: isCompleted ? const Color(0xff6B7280) : const Color(0xffDC2626),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: isCompleted ? const Color(0xff9CA3AF) : const Color(0xffEF4444)),
                          ),
                        ),
                        child: Text(isCompleted ? 'إبلاغ عن مشكلة' : 'إلغاء الطلب', style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.title, required this.value, this.isTotal = false});

  final String title;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final color = isTotal ? const Color(0xff1E2A78) : const Color(0xff374151);
    final weight = isTotal ? FontWeight.w900 : FontWeight.w600;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(color: color, fontWeight: weight),
        ),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: weight),
        ),
      ],
    );
  }
}
