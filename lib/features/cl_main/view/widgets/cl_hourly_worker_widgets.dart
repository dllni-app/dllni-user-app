import 'package:flutter/material.dart';

import '../../../../core/themes/shared_platform_colors.dart';

class ClHourlyWorkerAppointmentTile extends StatelessWidget {
  const ClHourlyWorkerAppointmentTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label $value',
      child: Material(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 14, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: SharedPlatformColors.border),
            ),
            child: Row(
              children: [
                Icon(icon, color: SharedPlatformColors.cleaning, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          color: SharedPlatformColors.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: SharedPlatformColors.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: SharedPlatformColors.subtle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ClHourlyWorkerPriceRow extends StatelessWidget {
  const ClHourlyWorkerPriceRow({
    required this.label,
    required this.amount,
    required this.currency,
    this.emphasize = false,
    super.key,
  });

  final String label;
  final double amount;
  final String currency;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final amountText =
        '${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)} $currency';
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
                color: SharedPlatformColors.ink,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              amountText,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: emphasize ? 18 : 15,
                color: emphasize
                    ? const Color(0xFF0B7480)
                    : SharedPlatformColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
