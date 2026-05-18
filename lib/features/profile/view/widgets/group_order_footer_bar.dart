import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class GroupOrderFooterBar extends StatelessWidget {
  final bool isCreator;
  final bool isLoading;
  final bool canSubmit;

  /// Creator: place whole group order. Member: send/unsend response ([SubmitGroupOrder]/[UnsubmitGroupOrder]).
  final String primaryButtonLabel;
  final VoidCallback onSubmitOrPlace;
  final VoidCallback? onCancel;

  const GroupOrderFooterBar({
    super.key,
    required this.isCreator,
    required this.isLoading,
    required this.canSubmit,
    this.primaryButtonLabel = 'التأكيد والإضافة إلى السلة',
    required this.onSubmitOrPlace,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: isCreator ? 2 : 1,
          child: ElevatedButton(
            onPressed: isLoading || !canSubmit ? null : onSubmitOrPlace,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primary,
              foregroundColor: context.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: AppText.labelLarge(
              primaryButtonLabel,
              color: context.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (isCreator) ...[
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : onCancel,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: context.error.withAlpha(200)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: AppText.labelLarge(
                'إلغاء',
                color: context.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
