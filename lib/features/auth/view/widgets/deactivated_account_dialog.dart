import 'package:dllni_user_app/core/widgets/support_whatsapp_launcher.dart';
import 'package:flutter/material.dart';

class DeactivatedAccountDialog extends StatelessWidget {
  final String message;

  const DeactivatedAccountDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      icon: Container(
        width: 68,
        height: 68,
        decoration: const BoxDecoration(
          color: Color(0xFFFFF7E6),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.person_off_outlined,
          color: Color(0xFFB54708),
          size: 32,
        ),
      ),
      title: const Text(
        'تم إلغاء تفعيل الحساب',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF172033), fontWeight: FontWeight.w900),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF667085), height: 1.5),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'تواصل مع فريق الدعم لمعرفة سبب إلغاء التفعيل والخطوات المتاحة.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF7A654E),
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () async {
              await launchSupportWhatsApp(context);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF172554),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'التواصل مع الدعم',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('حسناً'),
          ),
        ),
      ],
    );
  }
}
