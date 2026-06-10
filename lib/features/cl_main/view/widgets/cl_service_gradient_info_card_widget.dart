import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class ClServiceGradientInfoCardWidget extends StatelessWidget {
  const ClServiceGradientInfoCardWidget({
    required this.estimatedSqm,
    required this.estimatedHours,
    this.showEstimatedSqm = true,
    super.key,
  });

  final int estimatedSqm;
  final double estimatedHours;
  final bool showEstimatedSqm;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      padding: const EdgeInsetsDirectional.fromSTEB(18, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: [Color(0xFF1E2A78), Color(0xFF0CBBC7)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(color: Color(0x21000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          if (showEstimatedSqm) ...[
            _InfoRowWidget(
              title: 'المساحة التقريبية لمنزلك',
              value: '$estimatedSqm م2',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),
          ],
          _InfoRowWidget(
            title: 'عدد ساعات العمل المتوقعة',
            value: '${estimatedHours.toStringAsFixed(1)} ساعات عمل',
            icon: Icons.access_time,
          ),
        ],
      ),
    );
  }
}

class _InfoRowWidget extends StatelessWidget {
  const _InfoRowWidget({required this.title, required this.value, required this.icon});

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: AppText.labelLarge(title, color: Colors.white, fontWeight: FontWeight.w400, textAlign: TextAlign.start),
        ),
        const SizedBox(height: 8),
        AppText.bodySmall(value, color: Colors.white, fontWeight: FontWeight.w500),
      ],
    );
  }
}
