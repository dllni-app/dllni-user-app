import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class ClServiceOrderSummarySectionWidget extends StatelessWidget {
  const ClServiceOrderSummarySectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bodyLarge('ملخص الطلب', color: const Color(0xFF1E2A78), fontWeight: FontWeight.w700, textAlign: TextAlign.right),
          const SizedBox(height: 14),
          const _SummaryRowWidget(label: 'قيمة الخدمة', value: '1000 ل.س'),
          const SizedBox(height: 8),
          const _SummaryRowWidget(label: 'رسوم إضافية', value: '200 ل.س'),
          const SizedBox(height: 10),
          const Divider(color: Color(0xFFE5E7EB), thickness: 1),
          const SizedBox(height: 8),
          const _SummaryRowWidget(label: 'الإجمالي', value: '1200 ل.س', isTotal: true),
        ],
      ),
    );
  }
}

class _SummaryRowWidget extends StatelessWidget {
  const _SummaryRowWidget({required this.label, required this.value, this.isTotal = false});

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final color = isTotal ? const Color(0xFF1E2A78) : const Color(0xFF4B5563);
    return Row(
      children: [
        AppText.bodyMedium(label, color: color, fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600, textAlign: TextAlign.right),
        const Spacer(),
        AppText.bodyMedium(value, color: color, fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600, textAlign: TextAlign.right),
      ],
    );
  }
}
