import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors.dart';

class OrderInfoCard extends StatelessWidget {
  const OrderInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 2),
            blurRadius: 8.4,
            color: Color(0x29000000),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 16,
        children: [
          _OrderInfoRow(
            info: "وقت إنشاء الطلب",
            value: "pm  02:31  2026.07.18 ",
          ),
          _OrderInfoRow(
            info: "رقم الطلب",
            value: "#8647786",
          ),
          _OrderInfoRow(
            info: "موعد تسليم الطلب",
            value: "pm  06:00  2026.07.18 ",
          ),
        ],
      ),
    );
  }
}

class _OrderInfoRow extends StatelessWidget {
  const _OrderInfoRow({required this.info, required this.value});
  final String info, value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          "وقت إنشاء الطلب",
          style: TextStyle(color: Colors.black, fontSize: 14, height: 28 / 14),
        ),
        AppText(
          "pm  02:31  2026.07.18 ",
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 28 / 13,
          ),
        ),
      ],
    );
  }
}
