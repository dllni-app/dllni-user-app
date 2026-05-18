import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class CleaningCompletionSuccessDialog {
  static Future<void> show(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) {
        return AlertDialog(
          icon: const Icon(
            Icons.check_circle_rounded,
            color: Color(0xff20B7C4),
            size: 46,
          ),
          title: AppText.titleMedium(
            'تم تأكيد إنهاء العمل',
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w700,
          ),
          content: AppText.bodyMedium(
            'تم اعتماد إنهاء المهمة بنجاح.',
            textAlign: TextAlign.center,
            color: const Color(0xff6B7280),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(),
                child: const Text('متابعة'),
              ),
            ),
          ],
        );
      },
    );
  }
}
