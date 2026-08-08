import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/features/orders/data/models/sos_api_models.dart';
import 'package:dllni_user_app/features/orders/data/source/order_support_case_remote_data_source.dart';
import 'package:dllni_user_app/features/orders/data/source/orders_remote_data_source.dart';
import 'package:dllni_user_app/features/profile/domain/services/user_location_service.dart';
import 'package:flutter/material.dart';

class RestaurantOrderSosSheet extends StatefulWidget {
  const RestaurantOrderSosSheet({
    super.key,
    required this.orderId,
    required this.bookingType,
  });

  final int orderId;
  final String bookingType;

  static Future<void> show(
    BuildContext context, {
    required int orderId,
    required String bookingType,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RestaurantOrderSosSheet(
        orderId: orderId,
        bookingType: bookingType,
      ),
    );
  }

  @override
  State<RestaurantOrderSosSheet> createState() =>
      _RestaurantOrderSosSheetState();
}

class _RestaurantOrderSosSheetState extends State<RestaurantOrderSosSheet> {
  static const _options = <({String type, String label})>[
    (type: 'safety_threat', label: 'أشعر بعدم الأمان / تهديد'),
    (type: 'medical_emergency', label: 'حدثت حالة طبية طارئة'),
    (type: 'severe_conflict', label: 'هنالك خلاف حاد'),
  ];

  final TextEditingController _messageController = TextEditingController();
  String _selectedEmergencyType = 'safety_threat';
  String? _messageError;
  bool _submitting = false;
  CleaningSosAlertModel? _submittedCase;

  late final String _clientRequestId =
      'sos-${widget.bookingType}-${widget.orderId}-${DateTime.now().millisecondsSinceEpoch}';

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String? _validateMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      return 'يرجى وصف المشكلة قبل إرسال SOS';
    }
    if (message.length < 3) {
      return 'يرجى كتابة 3 أحرف على الأقل';
    }
    if (message.length > 1000) {
      return 'يجب ألا تتجاوز الرسالة 1000 حرف';
    }
    return null;
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

    final validationError = _validateMessage();
    setState(() => _messageError = validationError);
    if (validationError != null) return;

    setState(() => _submitting = true);

    final location = await _tryResolveLocation();
    final source = OrderSupportCaseRemoteDataSource(
      dioNetwork: getIt<OrdersRemoteDataSource>().dioNetwork,
    );

    try {
      final supportCase = await source.createEmergency(
        orderId: widget.orderId,
        bookingType: widget.bookingType,
        emergencyType: _selectedEmergencyType,
        description: _messageController.text,
        latitude: location.latitude,
        longitude: location.longitude,
        clientRequestId: _clientRequestId,
      );

      if (!mounted) return;
      setState(() {
        _submitting = false;
        _submittedCase = supportCase;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
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

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: submitted == null ? _buildForm() : _buildSubmitted(submitted),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: AppText.titleMedium(
                'طلب SOS',
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: _submitting ? null : () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AppText.bodySmall(
          'هذا الخيار للحالات العاجلة. سنحاول إرفاق موقعك، ولن يتوقف الإرسال إذا تعذر تحديده.',
          color: const Color(0xff6B7280),
        ),
        const SizedBox(height: 16),
        ..._options.map((option) {
          return RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            value: option.type,
            groupValue: _selectedEmergencyType,
            onChanged: _submitting
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _selectedEmergencyType = value);
                  },
            title: AppText.bodyMedium(
              option.label,
              textAlign: TextAlign.start,
            ),
          );
        }),
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
            hintText: 'صف المشكلة باختصار',
            errorText: _messageError,
            filled: true,
            fillColor: const Color(0xffF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : AppText.labelLarge('إرسال SOS', color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildSubmitted(CleaningSosAlertModel supportCase) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.check_circle_outline,
          color: Color(0xffDC2626),
          size: 56,
        ),
        const SizedBox(height: 14),
        Text(
          _statusLabel(supportCase.status),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'تم إنشاء حالة دعم عاجلة مرتبطة بهذا الطلب. لا تعِد الإرسال؛ سيعيد النظام نفس البلاغ النشط عند إعادة المحاولة.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xff6B7280)),
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }
}
