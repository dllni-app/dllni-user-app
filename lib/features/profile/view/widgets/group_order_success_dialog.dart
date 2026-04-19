import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GroupOrderSuccessSheet extends StatelessWidget {
  final String? shareToken;
  final VoidCallback onShareTap;
  final VoidCallback onFollowupTap;

  const GroupOrderSuccessSheet({
    super.key,
    required this.shareToken,
    required this.onShareTap,
    required this.onFollowupTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xffD1D5DB),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 10),
            const Icon(Icons.verified_outlined, size: 86, color: Color(0xffF97316)),
            const SizedBox(height: 14),
            AppText.headlineMedium('تم إنشاء التصويت', fontWeight: FontWeight.w700),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onFollowupTap,
                    child: AppText.bodyMedium(
                      'متابعة التصويت',
                      color: context.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onShareTap,
                    style: ElevatedButton.styleFrom(backgroundColor: context.primary),
                    child: AppText.bodyMedium(
                      'مشاركة',
                      color: context.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showGroupOrderSuccessSheet(
  BuildContext context, {
  required String? shareToken,
  required VoidCallback onFollowupTap,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return GroupOrderSuccessSheet(
        shareToken: shareToken,
        onShareTap: () {
          Clipboard.setData(ClipboardData(text: shareToken ?? ''));
          ScaffoldMessenger.of(sheetContext).showSnackBar(
            const SnackBar(content: Text('تم نسخ رمز المشاركة')),
          );
        },
        onFollowupTap: () {
          Navigator.of(sheetContext).pop();
          onFollowupTap();
        },
      );
    },
  );
}
