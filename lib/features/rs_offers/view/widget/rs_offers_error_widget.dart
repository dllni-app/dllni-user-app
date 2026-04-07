import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class RsOffersErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const RsOffersErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message.isEmpty ? 'حدث خطأ غير متوقع' : message),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: AppText('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
