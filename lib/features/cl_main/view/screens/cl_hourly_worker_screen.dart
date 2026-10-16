import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/themes/shared_platform_colors.dart';
import '../../../../core/utils/cleaning_date_time_ui_format.dart';
import '../../../../core/utils/cleaning_schedule_date_time_logic.dart';
import '../../../orders/view/screens/cleaning_order_details_screen.dart';
import '../../../profile/domain/models/address_list_item.dart';
import '../../domain/usecases/create_cleaning_order_use_case.dart';
import '../../domain/usecases/estimate_cleaning_price_use_case.dart';
import '../helpers/cl_hourly_worker_validation.dart';
import '../widgets/app_pickers.dart';
import '../widgets/cl_booking_confirmation_sheet.dart';
import '../widgets/cl_hourly_worker_widgets.dart';
import '../widgets/cl_redesign_components.dart';
import '../widgets/cl_service_address_section_widget.dart';
import '../widgets/home_details_app_bar.dart';

class ClHourlyWorkerScreen extends StatefulWidget {
  const ClHourlyWorkerScreen({super.key});

  @override
  State<ClHourlyWorkerScreen> createState() => _ClHourlyWorkerScreenState();
}

class _ClHourlyWorkerScreenState extends State<ClHourlyWorkerScreen> {
  static const List<int> _durationOptions = <int>[60, 120, 180, 240, 360, 480];

  final ValueNotifier<AddressListItem?> _selectedAddress = ValueNotifier(null);
  final TextEditingController _notesController = TextEditingController();
  final FocusNode _notesFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _notesFieldKey =
      GlobalKey<FormFieldState<String>>();

  DateTime? _selectedDate;
  String? _selectedTime;
  int _workerCount = 1;
  int _expectedMaxMinutes = 120;
  EstimatePriceResponseModel? _estimate;
  bool _estimating = false;
  bool _submitting = false;
  bool _confirming = false;
  bool _reviewing = false;
  bool _sendingDialogOpen = false;
  bool _exitApproved = false;
  int _estimateRevision = 0;
  String? _estimateError;

  @override
  void dispose() {
    _selectedAddress.dispose();
    _notesController.dispose();
    _notesFocusNode.dispose();
    super.dispose();
  }

  Future<void> _selectAddress() async {
    final result = await context.pushRoute('/myaddresses', arguments: true);
    if (!mounted || result is! AddressListItem) return;
    _selectedAddress.value = result;
    _invalidateEstimate();
  }

  Future<void> _pickDate() async {
    final value = await AppPickers.showAppDatePicker(
      context: context,
      startDate: CleaningScheduleDateTimeLogic.tomorrowDate(),
      initialDate:
          _selectedDate ?? CleaningScheduleDateTimeLogic.tomorrowDate(),
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

  void _invalidateEstimate() {
    ++_estimateRevision;
    if (!mounted) return;
    setState(() {
      _estimate = null;
      _estimateError = null;
      _estimating = false;
    });
  }

  Future<void> _refreshEstimate() async {
    if (!_reviewing || _estimating) return;
    final addressId = int.tryParse(_selectedAddress.value?.id ?? '');
    if (addressId == null || addressId <= 0) return;
    final revision = ++_estimateRevision;
    setState(() {
      _estimating = true;
      _estimate = null;
      _estimateError = null;
    });
    final response = await getIt<EstimateCleaningPriceUseCase>()(
      EstimateCleaningPriceParams.hourlyWorker(
        addressId: addressId,
        workerCount: _workerCount,
        expectedMaxMinutes: _expectedMaxMinutes,
      ),
    );
    if (!mounted || !_reviewing || revision != _estimateRevision) return;
    response.fold(
      (failure) => setState(() {
        _estimating = false;
        _estimateError = failure.message;
      }),
      (result) => setState(() {
        _estimating = false;
        _estimateError = null;
        _estimate = result;
      }),
    );
  }

  double? get _currentQuote =>
      _estimate?.openTime?.totalPrice ?? _estimate?.pricing?.totalPrice;

  void _editBooking() {
    ++_estimateRevision;
    setState(() {
      _reviewing = false;
      _estimate = null;
      _estimateError = null;
      _estimating = false;
    });
  }

  Future<void> _confirmExit() async {
    if (_reviewing) {
      _editBooking();
      return;
    }
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('هل تريد مغادرة طلب العامل بالساعة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('متابعة الطلب'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('مغادرة'),
          ),
        ],
      ),
    );
    if (!mounted || approved != true) return;
    setState(() => _exitApproved = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  void _showSendingDialog() {
    if (_sendingDialogOpen || !mounted) return;
    _sendingDialogOpen = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 26, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    color: Color(0xFF172554),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'عم نرسل طلبك',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19),
                ),
                SizedBox(height: 8),
                Text(
                  'ثواني وبنوصل طلبك للفريق... خلّي الباقي علينا!',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _hideSendingDialog() {
    if (!_sendingDialogOpen || !mounted) return;
    _sendingDialogOpen = false;
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> _submit() async {
    if (_submitting || _confirming) return;
    FocusManager.instance.primaryFocus?.unfocus();

    final form = _formKey.currentState;
    if (form != null && !form.validate()) {
      FocusManager.instance.primaryFocus?.unfocus();
      final fieldContext = _notesFieldKey.currentContext;
      if (fieldContext != null) {
        await Scrollable.ensureVisible(
          fieldContext,
          alignment: 0.35,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
      return;
    }

    if (_selectedDate == null) {
      _showMessage('يرجى اختيار تاريخ الخدمة.');
      return;
    }
    if (_selectedTime == null) {
      _showMessage('يرجى اختيار وقت بدء الخدمة.');
      return;
    }

    final address = _selectedAddress.value;
    final addressId = int.tryParse(address?.id ?? '');
    if (address == null || addressId == null || addressId <= 0) {
      _showMessage('يرجى اختيار عنوان الخدمة.');
      return;
    }
    if (!address.hasCompleteServiceLocation) {
      _showMessage(
        'يرجى اختيار عنوان يحتوي على موقع محدد على الخريطة وعنوان واضح.',
      );
      return;
    }

    if (!_reviewing) {
      setState(() => _reviewing = true);
      await _refreshEstimate();
      return;
    }
    final quote = _currentQuote;
    if (_estimating || _estimateError != null || quote == null) {
      _showMessage('يرجى مراجعة السعر قبل إرسال الطلب.');
      return;
    }
    setState(() => _confirming = true);
    final accepted = await showClBookingConfirmationSheet(
      context: context,
      title: 'تأكيد طلب عامل بالساعة',
      total: quote,
      currency:
          _estimate?.openTime?.currency ??
          _estimate?.pricing?.currency ??
          'SYP',
      icon: Icons.schedule_outlined,
      priceLabel: 'الإجمالي المتوقع',
      paymentNote: 'الدفع نقداً عند إتمام الخدمة، حسب مدة العمل الفعلية.',
    );
    if (!mounted) return;
    setState(() => _confirming = false);
    if (!accepted || _currentQuote != quote || _estimating) return;
    setState(() => _submitting = true);
    _showSendingDialog();
    final response = await getIt<CreateCleaningOrderUseCase>()(
      CreateCleaningOrderParams.hourlyWorker(
        addressId: addressId,
        scheduledDate: CleaningScheduleDateTimeLogic.formatDateApi(
          _selectedDate!,
        ),
        scheduledTime: _selectedTime!,
        workerCount: _workerCount,
        expectedMaxMinutes: _expectedMaxMinutes,
        address: address.line1,
        locationName: address.label,
        notes: _notesController.text.trim(),
      ),
    );

    if (!mounted) return;
    _hideSendingDialog();
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

  String? _validateDescription(String? value) {
    return ClHourlyWorkerValidation.description(value);
  }

  InputDecoration _fieldDecoration({
    required String hintText,
    String? helperText,
  }) {
    return InputDecoration(
      hintText: hintText,
      helperText: helperText,
      alignLabelWithHint: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: SharedPlatformColors.cleaning,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: SharedPlatformColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: SharedPlatformColors.danger,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
    String? subtitle,
    IconData icon = Icons.tune_rounded,
  }) {
    return ClRedesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: SharedPlatformColors.cleaningSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: SharedPlatformColors.cleaning),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: SharedPlatformColors.ink,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.45,
                          color: SharedPlatformColors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildCountSelector() {
    return Row(
      children: [
        _counterButton(
          icon: Icons.remove,
          enabled: _workerCount > 1,
          onPressed: () {
            setState(() => _workerCount--);
            _invalidateEstimate();
          },
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                '$_workerCount',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: SharedPlatformColors.ink,
                ),
              ),
              Text(
                _workerCount == 1 ? 'عامل' : 'عمال',
                style: const TextStyle(color: SharedPlatformColors.muted),
              ),
            ],
          ),
        ),
        _counterButton(
          icon: Icons.add,
          enabled: _workerCount < 20,
          onPressed: () {
            setState(() => _workerCount++);
            _invalidateEstimate();
          },
        ),
      ],
    );
  }

  Widget _counterButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon, size: 20),
        tooltip: icon == Icons.add ? 'زيادة عدد العمال' : 'تقليل عدد العمال',
        style: IconButton.styleFrom(
          backgroundColor: enabled
              ? SharedPlatformColors.cleaning
              : const Color(0xFFF2F4F7),
          foregroundColor: enabled ? Colors.white : SharedPlatformColors.subtle,
        ),
      ),
    );
  }

  Widget _buildEstimateCard() {
    if (_estimating) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 22),
        child: Center(
          child: CircularProgressIndicator(
            color: SharedPlatformColors.cleaning,
          ),
        ),
      );
    }

    if (_estimateError != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFECdd3)),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: SharedPlatformColors.danger),
            const SizedBox(height: 6),
            Text(
              _estimateError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: SharedPlatformColors.danger),
            ),
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: _refreshEstimate,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    final openTime = _estimate?.openTime;
    if (openTime == null) {
      return const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: SharedPlatformColors.cleaning),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'سيظهر السعر بعد اكتمال حساب الطلب.',
              textAlign: TextAlign.start,
              style: TextStyle(color: SharedPlatformColors.muted, height: 1.45),
            ),
          ),
        ],
      );
    }

    final currency = openTime.currency ?? _estimate?.pricing?.currency ?? 'SYP';
    final rate = openTime.hourlyRate ?? 0;
    final total = openTime.totalPrice ?? _estimate?.pricing?.totalPrice ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClHourlyWorkerPriceRow(
          label: 'سعر الساعة للعامل',
          amount: rate,
          currency: currency,
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SharedPlatformColors.cleaningSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: ClHourlyWorkerPriceRow(
            label: 'الإجمالي المتوقع',
            amount: total,
            currency: currency,
            emphasize: true,
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 18,
              color: SharedPlatformColors.muted,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'الفاتورة النهائية بحسب مدة العمل الفعلية.',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.45,
                  color: SharedPlatformColors.muted,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewCard() {
    final address = _selectedAddress.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionCard(
          title: 'تفاصيل العمل بالساعة',
          icon: Icons.fact_check_outlined,
          child: Column(
            children: [
              _summaryLine(
                'الموعد',
                _selectedDate == null || _selectedTime == null
                    ? 'غير محدد'
                    : '${CleaningDateTimeUiFormat.scheduleLabel(_selectedDate!)} - ${CleaningDateTimeUiFormat.time(_selectedTime!)}',
              ),
              const SizedBox(height: 12),
              _summaryLine('عدد العمال', '$_workerCount'),
              _summaryLine('المدة القصوى', _durationLabel(_expectedMaxMinutes)),
              _summaryLine(
                'عنوان الخدمة',
                address?.label ?? address?.line1 ?? 'غير محدد',
              ),
              _summaryLine('المهام المطلوبة', _notesController.text.trim()),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _sectionCard(
          title: 'ملخص السعر',
          icon: Icons.receipt_long_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildEstimateCard(),
              if (_estimate == null && !_estimating) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  key: const Key('hourly_retry_price'),
                  onPressed: _refreshEstimate,
                  icon: const Icon(Icons.refresh_outlined),
                  label: const Text('إعادة محاولة جلب السعر'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryLine(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 112,
          child: Text(
            label,
            style: const TextStyle(
              color: SharedPlatformColors.muted,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: SharedPlatformColors.ink,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final dateLabel = _selectedDate == null
        ? 'اختر التاريخ'
        : CleaningDateTimeUiFormat.scheduleLabel(_selectedDate!);
    final timeLabel = _selectedTime == null
        ? 'اختر الوقت'
        : CleaningDateTimeUiFormat.time(_selectedTime!);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: _exitApproved,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && !_submitting && !_confirming) _confirmExit();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: SharedPlatformColors.background,
          body: SafeArea(
            child: Column(
              children: [
                HomeDetailsAppBar(
                  title: 'طلب عامل بالساعة',
                  subtitle: 'أكمل بيانات الخدمة ثم راجع السعر',
                  onBack: _confirmExit,
                ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsetsDirectional.fromSTEB(
                        16,
                        16,
                        16,
                        28 + MediaQuery.viewInsetsOf(context).bottom,
                      ),
                      children: [
                        ClRedesignStepHeader(
                          currentStep: _reviewing ? 2 : 1,
                          totalSteps: 2,
                          title: _reviewing ? 'مراجعة طلبك' : 'تفاصيل الخدمة',
                          subtitle: _reviewing
                              ? 'راجع التفاصيل والتكلفة قبل الإرسال.'
                              : 'حدد الموعد والمدة والمهام المطلوبة.',
                        ),
                        const SizedBox(height: 14),
                        if (!_reviewing) ...[
                          _sectionCard(
                            title: 'عدد العمال',
                            subtitle: 'يمكنك طلب أكثر من عامل في نفس الحجز.',
                            icon: Icons.groups_2_outlined,
                            child: _buildCountSelector(),
                          ),
                          const SizedBox(height: 12),
                          _sectionCard(
                            title: 'الموعد',
                            subtitle:
                                'اختر اليوم والوقت المناسبين لبدء الخدمة.',
                            icon: Icons.event_available_outlined,
                            child: Column(
                              children: [
                                ClHourlyWorkerAppointmentTile(
                                  label: 'التاريخ',
                                  value: dateLabel,
                                  icon: Icons.calendar_month_outlined,
                                  onTap: _pickDate,
                                ),
                                const SizedBox(height: 10),
                                ClHourlyWorkerAppointmentTile(
                                  label: 'الوقت',
                                  value: timeLabel,
                                  icon: Icons.schedule_outlined,
                                  onTap: _pickTime,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _sectionCard(
                            title: 'المدة القصوى المتوقعة',
                            subtitle:
                                'هي حد الحجز المتوقع، بينما الحساب النهائي حسب الوقت الفعلي.',
                            icon: Icons.timelapse_outlined,
                            child: DropdownButtonFormField<int>(
                              initialValue: _expectedMaxMinutes,
                              isExpanded: true,
                              decoration: _fieldDecoration(
                                hintText: 'اختر المدة القصوى',
                              ),
                              items: _durationOptions
                                  .map(
                                    (minutes) => DropdownMenuItem<int>(
                                      value: minutes,
                                      child: Text(
                                        _durationLabel(minutes),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                  )
                                  .toList(growable: false),
                              onChanged: (minutes) {
                                if (minutes == null) return;
                                setState(() => _expectedMaxMinutes = minutes);
                                _invalidateEstimate();
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          CleaningAddressSelectWidget(
                            selectedAddress: _selectedAddress,
                            onChangeTap: _selectAddress,
                            afterBringDefault: _invalidateEstimate,
                          ),
                          const SizedBox(height: 12),
                          _sectionCard(
                            title: 'وصف العمل *',
                            subtitle: 'صف المهام التي تريد من العامل تنفيذها.',
                            icon: Icons.description_outlined,
                            child: ValueListenableBuilder<TextEditingValue>(
                              valueListenable: _notesController,
                              builder: (context, value, _) {
                                final length = value.text.trim().length;
                                final helper =
                                    length <
                                        ClHourlyWorkerValidation
                                            .minimumDescriptionLength
                                    ? 'الحد الأدنى للوصف 20 حرفاً'
                                    : null;
                                return TextFormField(
                                  key: _notesFieldKey,
                                  controller: _notesController,
                                  focusNode: _notesFocusNode,
                                  minLines: 4,
                                  maxLines: 6,
                                  maxLength: ClHourlyWorkerValidation
                                      .maximumDescriptionLength,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  textAlign: TextAlign.start,
                                  validator: _validateDescription,
                                  decoration: _fieldDecoration(
                                    hintText:
                                        'مثال: مساعدة في ترتيب المنزل أو نقل أغراض خفيفة...',
                                    helperText: helper,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                        ] else ...[
                          _buildReviewCard(),
                        ],
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
                ClRedesignStickyActions(
                  primaryLabel: _submitting
                      ? 'جارٍ إرسال الطلب…'
                      : _reviewing
                      ? 'تأكيد الطلب'
                      : 'مراجعة السعر',
                  onPrimary: _submit,
                  secondaryLabel: _reviewing ? 'السابق' : null,
                  onSecondary: _reviewing ? _editBooking : null,
                  primaryEnabled:
                      !_submitting &&
                      !_confirming &&
                      (!_reviewing ||
                          (!_estimating &&
                              _currentQuote != null &&
                              _estimateError == null)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
