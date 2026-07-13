import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/themes/app_colors.dart';
import 'package:dllni_user_app/features/orders/data/models/sos_api_models.dart';
import 'package:dllni_user_app/features/orders/domain/repository/orders_repo.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/sos_use_cases.dart';
import 'package:dllni_user_app/features/profile/domain/services/user_location_service.dart';
import 'package:dllni_user_app/features/profile/view/widgets/personal_details_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CleaningOrderSosArgs {
  const CleaningOrderSosArgs({required this.orderId});

  final int orderId;
}

@AutoRoutePage(path: '/cleaning-order-sos')
class CleaningOrderSosScreen extends StatefulWidget {
  const CleaningOrderSosScreen({super.key, required this.args});

  final CleaningOrderSosArgs args;

  @override
  State<CleaningOrderSosScreen> createState() =>
      _CleaningOrderSosScreenState();
}

class _CleaningOrderSosScreenState extends State<CleaningOrderSosScreen> {
  static const _emergencyOptions = <({String value, String label})>[
    (value: 'safety_threat', label: 'أشعر بعدم الأمان أو بوجود تهديد'),
    (value: 'medical_emergency', label: 'حدثت حالة طبية طارئة'),
    (value: 'severe_conflict', label: 'يوجد خلاف حاد يحتاج تدخلاً عاجلاً'),
  ];

  static const _complaintOptions = <({String value, String label})>[
    (value: 'poor_quality', label: 'جودة الخدمة غير مرضية'),
    (value: 'property_damage', label: 'حدث ضرر في الممتلكات'),
    (value: 'unprofessional', label: 'سلوك العامل غير لائق'),
    (value: 'billing_issue', label: 'مشكلة في الفاتورة أو المبلغ'),
    (value: 'other', label: 'مشكلة أخرى'),
  ];

  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _attachments = <XFile>[];

  String _kind = 'emergency';
  String? _selectedCategory;
  String? _messageError;
  bool _submitting = false;
  CleaningSosAlertModel? _submittedCase;

  bool get _isEmergency => _kind == 'emergency';

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _selectKind(String kind) {
    if (_submitting || kind == _kind) return;
    setState(() {
      _kind = kind;
      _selectedCategory = null;
      _messageError = null;
      _attachments.clear();
    });
  }

  String? _validateMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      return _isEmergency
          ? 'يرجى وصف حالة الطوارئ'
          : 'يرجى وصف المشكلة';
    }
    if (message.length < 3) return 'يرجى كتابة 3 أحرف على الأقل';
    if (message.length > 1000) return 'يجب ألا تتجاوز الرسالة 1000 حرف';
    return null;
  }

  Future<void> _pickAttachment() async {
    if (_submitting || _attachments.length >= 4) return;

    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1800,
    );
    if (file == null) return;

    final size = await file.length();
    if (!mounted) return;
    if (size > 2 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب ألا يتجاوز حجم الصورة 2 ميجابايت')),
      );
      return;
    }

    setState(() => _attachments.add(file));
  }

  Future<({double? latitude, double? longitude})> _tryResolveLocation() async {
    try {
      final location = await getIt<UserLocationService>().getCurrentPosition();
      return (
        latitude: location.latitude,
        longitude: location.longitude,
      );
    } catch (_) {
      return (latitude: null, longitude: null);
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEmergency
                ? 'يرجى تحديد نوع حالة الطوارئ'
                : 'يرجى تحديد نوع المشكلة',
          ),
        ),
      );
      return;
    }

    final validationError = _validateMessage();
    setState(() => _messageError = validationError);
    if (validationError != null) return;

    setState(() => _submitting = true);

    final requestId =
        '$_kind-${widget.args.orderId}-${DateTime.now().millisecondsSinceEpoch}';

    if (_isEmergency) {
      final location = await _tryResolveLocation();
      final result = await getIt<CreateCleaningUserSosUseCase>()(
        CreateCleaningUserSosParams(
          orderId: widget.args.orderId,
          emergencyType: _selectedCategory!,
          message: _messageController.text,
          latitude: location.latitude,
          longitude: location.longitude,
          clientRequestId: requestId,
        ),
      );

      if (!mounted) return;
      result.fold(_handleFailure, _handleSuccess);
      return;
    }

    final result = await CreateCleaningComplaintUseCase(
      ordersRepo: getIt<OrdersRepo>(),
    )(
      CreateCleaningComplaintParams(
        orderId: widget.args.orderId,
        category: _selectedCategory!,
        description: _messageController.text,
        attachmentPaths: _attachments.map((file) => file.path).toList(),
        clientRequestId: requestId,
      ),
    );

    if (!mounted) return;
    result.fold(_handleFailure, _handleSuccess);
  }

  void _handleFailure(Failure failure) {
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(failure.message)),
    );
  }

  void _handleSuccess(CleaningSosAlertModel supportCase) {
    setState(() {
      _submitting = false;
      _submittedCase = supportCase;
    });
  }

  String _statusLabel(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'acknowledged':
        return 'تم استلام البلاغ من فريق الدعم';
      case 'under_review':
        return 'البلاغ قيد المراجعة';
      case 'waiting_party':
        return 'بانتظار معلومات إضافية';
      case 'resolved':
        return 'تم حل البلاغ';
      case 'closed':
        return 'تم إغلاق البلاغ';
      default:
        return 'تم إرسال البلاغ إلى فريق الدعم';
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitted = _submittedCase;

    return Scaffold(
      backgroundColor: const Color(0xffF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            const PersonalDetailsAppBar(title: 'الدعم والبلاغات'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.all(20),
                child: submitted == null
                    ? _buildForm(context)
                    : _buildSubmittedState(submitted),
              ),
            ),
            if (submitted == null)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: _isEmergency
                          ? context.error
                          : const Color(0xff20BFC8),
                      foregroundColor: Colors.white,
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
                        : Text(
                            _isEmergency
                                ? 'إرسال بلاغ الطوارئ'
                                : 'إرسال الشكوى',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final options = _isEmergency ? _emergencyOptions : _complaintOptions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: _kindButton(
                  value: 'emergency',
                  label: 'حالة طوارئ',
                  icon: Icons.warning_amber_rounded,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _kindButton(
                  value: 'complaint',
                  label: 'شكوى أو نزاع',
                  icon: Icons.support_agent_rounded,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _isEmergency
                        ? Icons.warning_rounded
                        : Icons.report_problem_outlined,
                    color: _isEmergency
                        ? context.error
                        : const Color(0xff20BFC8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isEmergency
                          ? 'ما حالة الطوارئ؟'
                          : 'ما نوع المشكلة؟',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _isEmergency
                    ? 'استخدم هذا الخيار للحالات العاجلة. سنحاول إرفاق موقعك، ولن يتوقف الإرسال إذا تعذر تحديده.'
                    : 'سيتم فتح حالة متابعة رسمية مرتبطة بالحجز وتظهر لفريق الدعم.',
                style: const TextStyle(
                  color: Color(0xff6B7280),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              ...options.map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _optionTile(
                    label: option.label,
                    selected: _selectedCategory == option.value,
                    onTap: _submitting
                        ? null
                        : () => setState(
                              () => _selectedCategory = option.value,
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEmergency ? 'وصف الحالة' : 'تفاصيل المشكلة',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _messageController,
                enabled: !_submitting,
                maxLength: 1000,
                maxLines: 4,
                onChanged: (_) {
                  if (_messageError != null) {
                    setState(() => _messageError = _validateMessage());
                  }
                },
                decoration: InputDecoration(
                  hintText: _isEmergency
                      ? 'صف الموقف باختصار'
                      : 'اكتب كل التفاصيل التي تساعد في مراجعة الشكوى',
                  hintStyle: const TextStyle(
                    color: AppColors.hintText,
                    fontSize: 14,
                  ),
                  errorText: _messageError,
                  filled: true,
                  fillColor: const Color(0xffF3F4F6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!_isEmergency) ...[
          const SizedBox(height: 14),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الصور والأدلة',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'حتى 4 صور، وبحد أقصى 2 ميجابايت للصورة.',
                  style: TextStyle(color: Color(0xff6B7280), fontSize: 12),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._attachments.asMap().entries.map(
                      (entry) => InputChip(
                        label: SizedBox(
                          width: 120,
                          child: Text(
                            entry.value.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        onDeleted: _submitting
                            ? null
                            : () => setState(
                                  () => _attachments.removeAt(entry.key),
                                ),
                      ),
                    ),
                    if (_attachments.length < 4)
                      ActionChip(
                        avatar: const Icon(Icons.add_photo_alternate_outlined),
                        label: const Text('إضافة صورة'),
                        onPressed: _submitting ? null : _pickAttachment,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmittedState(CleaningSosAlertModel supportCase) {
    return _card(
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: _isEmergency ? context.error : const Color(0xff20BFC8),
            size: 56,
          ),
          const SizedBox(height: 16),
          Text(
            _statusLabel(supportCase.status),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isEmergency
                ? 'سيتم التعامل مع البلاغ بشكل عاجل، وسيتواصل معك فريق الدعم عند الحاجة.'
                : 'تم تسجيل الشكوى وربطها بالحجز. يمكنك متابعة حالتها مع فريق الدعم.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xff6B7280)),
          ),
          if (supportCase.id != null) ...[
            const SizedBox(height: 12),
            Text(
              'رقم البلاغ: ${supportCase.id}',
              style: const TextStyle(color: Color(0xff6B7280)),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('العودة إلى تفاصيل الحجز'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kindButton({
    required String value,
    required String label,
    required IconData icon,
  }) {
    final selected = _kind == value;
    final color = value == 'emergency' ? context.error : const Color(0xff20BFC8);

    return InkWell(
      onTap: () => _selectKind(value),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? color : const Color(0xff6B7280)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? color : const Color(0xff6B7280),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionTile({
    required String label,
    required bool selected,
    required VoidCallback? onTap,
  }) {
    final color = _isEmergency ? context.error : const Color(0xff20BFC8);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.08)
              : const Color(0xffF3F4F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : const Color(0xffD1D5DB),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? color : const Color(0xff9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
