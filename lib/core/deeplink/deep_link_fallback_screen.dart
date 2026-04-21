import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shown when a deep link cannot be opened in-app (not found, expired, etc.).
class DeepLinkFallbackScreen extends StatelessWidget {
  const DeepLinkFallbackScreen({
    super.key,
    this.message,
    this.fallbackUrl,
  });

  final String? message;
  final String? fallbackUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('رابط غير متاح')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppText.bodyLarge(
              message ?? 'تعذر فتح هذا الرابط.',
              textAlign: TextAlign.center,
            ),
            if ((fallbackUrl ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  final uri = Uri.tryParse(fallbackUrl!.trim());
                  if (uri != null) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: const Text('فتح في المتصفح'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
