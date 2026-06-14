import 'package:common_package/common_package.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/features/orders/data/models/sos_api_models.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/sos_use_cases.dart';
import 'package:dllni_user_app/features/profile/domain/services/user_location_service.dart';
import 'package:flutter/material.dart';

class RestaurantOrderSosSheet extends StatefulWidget {
  const RestaurantOrderSosSheet({super.key, required this.orderId});

  final int orderId;

  static Future<void> show(BuildContext context, {required int orderId}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RestaurantOrderSosSheet(orderId: orderId),
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

  Future<void> _submit() async {
    if (_submitting) return;
    final validationError = _validateMessage();
    setState(() => _messageError = validationError);
    if (validationError != null) return;

    setState(() => _submitting = true);

    final location = await getIt<UserLocationService>().getCurrentPosition();
    final Either<Failure, UserSosResponseModel> result =
        await getIt<CreateUserSosUseCase>()(
          CreateUserSosParams(
            orderId: widget.orderId,
            message: _messageController.text,
            emergencyType: _selectedEmergencyType,
            latitude: location.latitude,
            longitude: location.longitude,
          ),
        );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (response) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message.isNotEmpty
                  ? response.message
                  : 'تم إرسال طلب SOS بنجاح. تم إبلاغ فريق الدعم.',
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppText.titleMedium('طلب SOS', fontWeight: FontWeight.bold),
            const SizedBox(height: 8),
            AppText.bodySmall(
              'صف المشكلة وسيتم إرسال تنبيه فوري لفريق الدعم.',
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
        ),
      ),
    );
  }
}
