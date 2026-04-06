import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class ClServiceBottomActionsWidget extends StatelessWidget {
  const ClServiceBottomActionsWidget({
    required this.onBackPressed,
    required this.onSubmitPressed,
    super.key,
  });

  final VoidCallback onBackPressed;
  final VoidCallback onSubmitPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: onSubmitPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF11B9C8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: AppText.headlineSmall(
                'أرسل الطلب',
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: onBackPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA8ABC9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: AppText.headlineSmall(
                'تراجع',
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
