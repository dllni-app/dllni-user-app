import 'package:flutter/material.dart';

class RestaurantCartSummaryRow extends StatelessWidget {
  const RestaurantCartSummaryRow({
    super.key,
    required this.title,
    required this.value,
    this.valueColor,
    this.titleStyle,
    this.valueStyle,
  });

  final String title;
  final String value;
  final Color? valueColor;
  final TextStyle? titleStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: titleStyle ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xff6B7280)),
          ),
        ),
        Text(
          value,
          style: valueStyle ?? TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor ?? const Color(0xff111827)),
        ),
      ],
    );
  }
}
