import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class OrderVotingTagWrap extends StatelessWidget {
  const OrderVotingTagWrap({
    super.key,
    required this.values,
    required this.onRemoveTap,
  });

  final List<String> values;
  final ValueChanged<String> onRemoveTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: values.map((value) {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xffFFEDD5),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 8, 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => onRemoveTap(value),
                  child: const CircleAvatar(
                    radius: 7,
                    backgroundColor: Color(0xff92400E),
                    child: Icon(Icons.close, size: 10, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 6),
                AppText.labelLarge(
                  value,
                  color: const Color(0xffB45309),
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
