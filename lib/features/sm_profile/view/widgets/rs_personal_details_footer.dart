import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class RsPersonalDetailsFooter extends StatelessWidget {
  const RsPersonalDetailsFooter({
    super.key,
    required this.onSave,
    required this.onCancel,
    this.isSaving = false,
  });

  final VoidCallback onSave;
  final VoidCallback onCancel;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: ElevatedButton(
            onPressed: isSaving ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primary,
              foregroundColor: context.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: isSaving
                ? SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: context.onPrimary),
                  )
                : AppText.labelLarge('حفظ التغييرات', color: context.onPrimary, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: isSaving ? null : onCancel,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: context.error.withAlpha(200)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: AppText.labelLarge('إلغاء', color: context.error, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
