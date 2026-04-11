import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class RestaurantCartLoadFailedView extends StatelessWidget {
  const RestaurantCartLoadFailedView({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * .2),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AppText.labelLarge(
              errorMessage ?? 'تعذر تحميل السلة',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1E2A78),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: AppText.labelLarge(
              'إعادة المحاولة',
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
