import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/cleaning_date_time_ui_format.dart';
import '../../../../core/utils/cleaning_schedule_date_time_logic.dart';
import '../../../orders/view/screens/cleaning_order_details_screen.dart';
import '../../../profile/domain/models/address_list_item.dart';
import '../../data/models/estimate_price_response_model.dart';
import '../../domain/usecases/create_cleaning_order_use_case.dart';
import '../../domain/usecases/estimate_cleaning_price_use_case.dart';
import '../widgets/app_pickers.dart';
import '../widgets/cl_service_address_section_widget.dart';
import '../widgets/home_details_app_bar.dart';

class ClHourlyWorkerScreen extends StatefulWidget {
  const ClHourlyWorkerScreen({super.key});

  @override
  State<ClHourlyWorkerScreen> createState() => _ClHourlyWorkerScreenState();
}

class _ClHourlyWorkerScreenState extends State<ClHourlyWorkerScreen> {
  static const List<int> _durationOptions = <int>[
    60,
    120,
    180,
    240,
    360,
    480,
  ];

  final ValueNotifier<AddressListItem?> _selectedAddress = ValueNotifier(null);
  final TextEditingController _notesController = TextEditingController();

  late DateTime _selectedDate;
  String _selectedTime = '09:00';
  int _workerCount = 1;
  int _expectedMaxMinutes = 120;
  EstimatePriceResponseModel? _estimate;
  bool _estimating = false;
  bool _submitting = false;
  String? _estimateError;

  @override
  void initState() {
    super.initState();
    _selectedDate = CleaningScheduleDateTimeLogic.tomorrowDate();
  }

  @override
  void dispose() {
    _selectedAddress.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectAddress() async {
    final result = await context.pushRoute('/myaddresses', arguments: true);
    if (!mounted || result is! AddressListItem) return;
    _selectedAddress.value = result;
    await _refreshEstimate();
  }

  Future<void> _pickDate() async {
    final value = await AppPickers.showAppDatePicker(
      context: context,
      startDate: CleaningScheduleDateTimeLogic.tomorrowDate(),
      initialDate: _selectedDate,
    );
    if (!mounted || value.isEmpty) return;
    final parsed = CleaningScheduleDateTimeLogic.parseDateApi(value);
    if (parsed == null) return;
    setState(() => _selectedDate = parsed);
  }

  Future<void> _pickTime() async {
    final value = await AppPickers.showAppTimePicker(context: context);
    if (!mounted || value.isEmpty) return;
    setState(() {
      _selectedTime = CleaningScheduleDateTimeLogic.normalizeTimeHhMm(value);
    });
  }

  Future<void> _refreshEstimate() async {
    final address = _selectedAddress.value;
    final addressId = int.tryParse(address?.id ?? '');
    if (addressId == null || addressId <= 0 || _estimating) return;

    setState(() {
      _estimating = true;
      _estimateError = null;
    });

    final response = await getIt<EstimateCleaningPriceUseCase>()(
      EstimateCleaningPriceParams.hourlyWorker(
        addressId: addressId,
        workerCount: _workerCount,
        expectedMaxMinutes: _expectedMaxMinutes,
      ),
    );

    if (!mounted) return;
    response.fold(
      (failure) {
        setState(() {
          _estimating = false;
          _estimateError = failure.message;
        });
      },
      (result) {
        setState(() {
          _estimating = false;
          _estimateError = null;
          _estimate = result;
        });
      },
    );
  }

  Future<void> _submit() async {
    if (_submitting) return;

    final address = _selectedAddress.value;
    final addressId = int.tryParse(address?.id ?? '');
    if (address == null || addressId == null || addressId <= 0) {
      _showMessage('يرجى اختيار عنوان الخدمة.');
      return;
    }
    if (!address.hasCompleteServiceLocation) {
      _showMessage(
        'يرجى اختيار أو تعديل عنوان مكتمل يحتوي على المدينة والحي والتفاصيل والموقع على الخريطة.',
      );
      return;
    }

    setState(() => _submitting = true);
    final response = await getIt<CreateCleaningOrderUseCase>()(
      CreateCleaningOrderParams.hourlyWorker(
        addressId: addressId,
        scheduledDate: CleaningScheduleDateTimeLogic.formatDateApi(
          _selectedDate,
        ),
        scheduledTime: _selectedTime,
        workerCount: _workerCount,
        expectedMaxMinutes: _expectedMaxMinutes,
        address: address.line1,
        locationName: address.label,
        notes: _notesController.text.trim(),
      ),
    );

    if (!mounted) return;
    response.fold(
      (failure) {
        setState(() => _submitting = false);
        _showMessage(failure.message);
      },
      (result) {
        setState(() => _submitting = false);
        final orderId = result.orderId;
        if (orderId == null) {
          _showMessage(
            'تم إنشاء الطلب، لكن تعذر فتح تفاصيله. يمكنك متابعته من الطلبات.',
          );
          context.pushRouteAndRemoveUntil('/clmain');
          return;
        }
        context.pushRouteAndRemoveUntil(
          '/cleaning-order-details',
          arguments: CleaningOrderDetailsArgs(orderId: orderId),
          predicate: (route) => route.settings.name == '/clmain',
        );
      },
    );
  }

  void _showMessage(String message) {
    final value = message.trim();
    if (value.isEmpty) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  String _durationLabel(int minutes) {
    final hours = minutes / 60;
    if (hours == hours.roundToDouble()) {
      final count = hours.toInt();
      return count == 1 ? 'ساعة واحدة' : '$count ساعات';
    }
    return '$minutes دقيقة';
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
    String? subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 5),
            Text(
              subtitle,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildCountSelector() {
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: _workerCount >= 20
              ? null
              : () {
                  setState(() => _workerCount++);
                  _refreshEstimate();
                },
          icon: const Icon(Icons.add),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                '$_workerCount',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                _workerCount == 1 ? 'عامل' : 'عمال',
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: _workerCount <= 1
              ? null
              : () {
                  setState(() => _workerCount--);
                  _refreshEstimate();
                },
          icon: const Icon(Icons.remove),
        ),
      ],
    );
  }

  Widget _buildEstimateCard() {
    if (_estimating) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_estimateError != null) {
      return Column(
        children: [
          Text(
            _estimateError!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _refreshEstimate,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      );
    }

    final pricing = _estimate?.pricing;
    if (pricing == null) {
      return const Text(
        'اختر العنوان لعرض السعر التقديري.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF6B7280)),
      );
    }

    final currency = pricing.currency ?? 'SYP';
    final total = pricing.totalPrice ?? 0;
    return Column(
      children: [
        _priceRow('القيمة التقديرية حتى الحد المختار', total, currency),
        const SizedBox(height: 10),
        const Text(
          'الفوترة النهائية تعتمد على مدة العمل الفعلية المسجلة في النظام، ولا يتوقف العداد عند مغادرة شاشة الطلب.',
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _priceRow(String label, double amount, String currency) {
    return Row(
      children: [
        Text(
          '${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)} $currency',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const Spacer(),
        Text(
          label,
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = CleaningDateTimeUiFormat.date(_selectedDate);
    final timeLabel = CleaningDateTimeUiFormat.time(_selectedTime);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            const HomeDetailsAppBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 18, 20, 24),
                children: [
                  const Text(
                    'عامل بالساعة',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'اطلب عاملًا أو أكثر للعمل بالساعة. يتم احتساب الوقت الفعلي من الباك اند منذ بدء العمل وحتى إنهائه.',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 18),
                  _sectionCard(
                    title: 'عدد العمال',
                    subtitle: 'يمكنك طلب أكثر من عامل في نفس الحجز.',
                    child: _buildCountSelector(),
                  ),
                  const SizedBox(height: 12),
                  _sectionCard(
                    title: 'الموعد',
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickTime,
                            icon: const Icon(Icons.schedule),
                            label: Text(timeLabel),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickDate,
                            icon: const Icon(Icons.calendar_month),
                            label: Text(dateLabel),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _sectionCard(
                    title: 'المدة القصوى المتوقعة',
                    subtitle:
                        'هي حد الحجز المتوقع، بينما الحساب النهائي حسب الوقت الفعلي.',
                    child: DropdownButtonFormField<int>(
                      initialValue: _expectedMaxMinutes,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: _durationOptions
                          .map(
                            (minutes) => DropdownMenuItem<int>(
                              value: minutes,
                              child: Text(_durationLabel(minutes)),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (minutes) {
                        if (minutes == null) return;
                        setState(() => _expectedMaxMinutes = minutes);
                        _refreshEstimate();
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  CleaningAddressSelectWidget(
                    selectedAddress: _selectedAddress,
                    onChangeTap: _selectAddress,
                    afterBringDefault: _refreshEstimate,
                  ),
                  const SizedBox(height: 12),
                  _sectionCard(
                    title: 'وصف العمل',
                    subtitle: 'اختياري — اكتب ما تريد من العامل تنفيذه.',
                    child: TextField(
                      controller: _notesController,
                      minLines: 3,
                      maxLines: 5,
                      maxLength: 2000,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        hintText: 'مثال: مساعدة في ترتيب المنزل أو نقل أغراض خفيفة...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _sectionCard(
                    title: 'التكلفة التقديرية',
                    child: _buildEstimateCard(),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'تأكيد طلب عامل بالساعة',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
