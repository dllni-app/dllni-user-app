import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

enum OrderCardActionType { neutral, destructive }

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.statusLabel,
    required this.orderNumber,
    required this.serviceName,
    required this.priceLabel,
    required this.dateLabel,
    required this.actionLabel,
    required this.actionType,
    this.onActionTap,
  });

  final String statusLabel;
  final String orderNumber;
  final String serviceName;
  final String priceLabel;
  final String dateLabel;
  final String actionLabel;
  final OrderCardActionType actionType;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final bool isDestructive = actionType == OrderCardActionType.destructive;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: EdgeInsetsDirectional.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: AppText.labelSmall(orderNumber, color: const Color(0xff6B7280), textAlign: TextAlign.start),
                ),
                SizedBox(width: 14),
                Container(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xff0CBBC7).withAlpha(27), borderRadius: BorderRadius.circular(20)),
                  child: AppText.labelMedium(statusLabel, color: const Color(0xff0CBBC7), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Divider(color: Color(0xff9CA3AF).withAlpha(27)),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: AppText.bodyMedium(serviceName, textAlign: TextAlign.start, color: const Color(0xff2D2F36), fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 12),
                AppText.labelLarge(priceLabel, fontWeight: FontWeight.bold, color: Color(0xff1E2A7B)),
              ],
            ),
          ),
          SizedBox(height: 10),
          Divider(color: Color(0xff9CA3AF).withAlpha(27)),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: const Color(0xffF3F4FF), borderRadius: BorderRadius.circular(99)),
                  child: const Icon(Icons.calendar_month_outlined, size: 18, color: Color(0xff6672C2)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.labelMedium('الخميس', color: const Color(0xff4B5563), fontWeight: FontWeight.w500),
                      const SizedBox(height: 2),
                      AppText.labelMedium(dateLabel, color: const Color(0xff9CA3AF)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(color: const Color(0xffEEF0FF), borderRadius: BorderRadius.circular(10)),
                  child: AppText.labelLarge('تغيير موعد الخدمة', color: const Color(0xff1E2A78), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 16),
            child: InkWell(
              onTap: onActionTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsetsDirectional.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDestructive ? const Color(0xffFDECEF) : const Color(0xffF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDestructive ? const Color(0xffECA8B2) : const Color(0xffD1D5DB)),
                ),
                child: AppText.labelLarge(
                  actionLabel,
                  color: isDestructive ? const Color(0xffC14A62) : const Color(0xff6B7280),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
