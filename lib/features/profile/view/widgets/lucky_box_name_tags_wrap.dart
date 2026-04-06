import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class LuckyBoxNameTagsWrap extends StatelessWidget {
  const LuckyBoxNameTagsWrap({
    super.key,
    required this.names,
    required this.onRemoveTap,
  });

  final List<String> names;
  final ValueChanged<String> onRemoveTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: names.map((name) {
          return Container(
            padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 8, 4),
            decoration: BoxDecoration(
              color: const Color(0xffF3F4F6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xffE5E7EB)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => onRemoveTap(name),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: Color(0xff6B7280),
                  ),
                ),
                const SizedBox(width: 6),
                AppText.labelLarge(
                  name,
                  color: const Color(0xff374151),
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
