import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showForceUpdateDialog({
  required BuildContext context,
  required String storeUrl,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('تحديث مطلوب'),
          content: const Text(
            'يجب تحديث التطبيق إلى أحدث إصدار للمتابعة.',
          ),
          actions: [
            FilledButton(
              onPressed: () async {
                final uri = Uri.tryParse(storeUrl);
                if (uri != null) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text('تحديث الآن'),
            ),
          ],
        ),
      );
    },
  );
}
