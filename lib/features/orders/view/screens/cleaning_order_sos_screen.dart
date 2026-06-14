import 'package:common_package/common_package.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/features/orders/data/models/sos_api_models.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/sos_use_cases.dart';
import 'package:dllni_user_app/features/profile/domain/services/user_location_service.dart';
import 'package:dllni_user_app/features/profile/view/widgets/personal_details_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class CleaningOrderSosArgs {
  const CleaningOrderSosArgs({required this.orderId});

  final int orderId;
}

@AutoRoutePage(path: '/cleaning-order-sos')
class CleaningOrderSosScreen extends StatefulWidget {
  const CleaningOrderSosScreen({super.key, required this.args});

  final CleaningOrderSosArgs args;

  @override
  State<CleaningOrderSosScreen> createState() => _CleaningOrderSosScreenState();
}

class _CleaningOrderSosScreenState extends State<CleaningOrderSosScreen> {
  static const List<({String type, String label})> _options =
      <({String type, String label})>[
        (type: 'safety_threat', label: 'أشعر بعدم الأمان / تهديد'),
        (type: 'medical_emergency', label: 'حدثت حالة طبية طارئة'),
        (type: 'severe_conflict', label: 'هنالك خلاف حاد'),
      ];

  final TextEditingController _messageController = TextEditingController();
  String? _selectedEmergencyType;
  String? _messageError;
  bool _submitting = false;
  CleaningSosAlertModel? _submittedAlert;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String _statusLabel(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'acknowledged':
        return 'الدعم يتعامل مع الطلب';
      case 'resolved':
        return 'تم إغلاق الطلب';
      case 'triggered':
      default:
        return 'تم الإرسال إلى الدعم';
    }
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

  Future<void> _showLocationServiceSettingsDialog() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('خدمة الموقع غير مفعّلة'),
        content: const Text(
          'يرجى تفعيل الموقع (GPS) من إعدادات الجهاز ثم إعادة إرسال SOS.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await Geolocator.openLocationSettings();
            },
            child: const Text('فتح إعدادات الموقع'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final emergencyType = _selectedEmergencyType;
    if (emergencyType == null || _submitting) {
      if (emergencyType == null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('يرجى تحديد نوع الطوارئ')));
      }
      return;
    }

    final validationError = _validateMessage();
    setState(() => _messageError = validationError);
    if (validationError != null) return;

    setState(() => _submitting = true);

    final isLocationServiceEnabled =
        await Geolocator.isLocationServiceEnabled();
    if (!mounted) return;
    if (!isLocationServiceEnabled) {
      setState(() => _submitting = false);
      await _showLocationServiceSettingsDialog();
      return;
    }

    final location = await getIt<UserLocationService>().getCurrentPosition();
    if (!mounted) return;
    if (location.latitude == null || location.longitude == null) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى تفعيل الموقع ومنح التطبيق الإذن لتحديد موقعك قبل إرسال SOS',
          ),
        ),
      );
      return;
    }

    final Either<Failure, CleaningSosAlertModel> result =
        await getIt<CreateCleaningUserSosUseCase>()(
          CreateCleaningUserSosParams(
            orderId: widget.args.orderId,
            emergencyType: emergencyType,
            message: _messageController.text,
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
      (alert) {
        setState(() {
          _submitting = false;
          _submittedAlert = alert;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final submitted = _submittedAlert;

    return Scaffold(
      backgroundColor: const Color(0xffF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            const PersonalDetailsAppBar(title: 'حالة طوارئ'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.all(24),
                child: submitted != null
                    ? _buildSubmittedState(submitted)
                    : _buildForm(context),
              ),
            ),
            if (submitted == null)
              Padding(
                padding: const EdgeInsetsDirectional.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: context.error,
                      foregroundColor: context.onError,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : AppText.labelLarge(
                            'إرسال لفريق الدعم',
                            color: context.onError,
                            fontWeight: FontWeight.bold,
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmittedState(CleaningSosAlertModel alert) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline, color: context.error, size: 56),
          const SizedBox(height: 16),
          AppText.titleMedium(
            _statusLabel(alert.status),
            textAlign: TextAlign.center,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8),
          AppText.bodyMedium(
            'تم إرسال طلب الطوارئ. سيتواصل معك فريق الدعم في أقرب وقت.',
            textAlign: TextAlign.center,
            color: Colors.grey[700],
          ),
          if (alert.id != null) ...[
            const SizedBox(height: 12),
            AppText.bodySmall(
              'رقم التنبيه: ${alert.id}',
              color: Colors.grey[600],
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('العودة إلى تفاصيل الطلب'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsetsDirectional.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning, color: context.error, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppText.titleMedium(
                      'ماهي حالة الطوارئ؟',
                      textAlign: TextAlign.start,
                      color: context.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppText.bodyMedium(
                'استخدم هذا الخيار فقط في حالات الخطر أو الحاجة العاجلة للمساعدة.',
                textAlign: TextAlign.start,
                color: Colors.grey[700],
              ),
              const SizedBox(height: 20),
              ..._options.map((option) {
                final selected = _selectedEmergencyType == option.type;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildEmergencyOption(
                    context: context,
                    title: option.label,
                    isSelected: selected,
                    onTap: _submitting
                        ? null
                        : () {
                            setState(() {
                              _selectedEmergencyType = option.type;
                            });
                          },
                  ),
                );
              }),
              const SizedBox(height: 8),
              AppText.bodyMedium(
                'رسالة الطوارئ',
                textAlign: TextAlign.start,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _messageController,
                enabled: !_submitting,
                maxLength: 1000,
                maxLines: 3,
                onChanged: (_) {
                  if (_messageError != null) {
                    setState(() => _messageError = _validateMessage());
                  }
                },
                decoration: InputDecoration(
                  hintText: 'صف الموقف باختصار',
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
      ],
    );
  }

  Widget _buildEmergencyOption({
    required BuildContext context,
    required String title,
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? context.error.withValues(alpha: 0.08)
              : const Color(0xffF3F4F6),
          border: Border.all(
            color: isSelected ? context.error : const Color(0xffD1D5DB),
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsetsDirectional.all(16),
        child: Row(
          children: [
            Expanded(
              child: AppText.bodyMedium(
                title,
                textAlign: TextAlign.start,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? context.error : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
