import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../orders/data/models/orders_api_models.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/app_images.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, required this.onTap});
  final OrderResourceModel order;

  final void Function() onTap;

  bool get _isScheduled => (order.fulfillment?.receiveMode ?? '').toLowerCase() == 'scheduled';

  String _money(double value) => '${value.toStringAsFixed(0)} ل.س';

  String _scheduledLabel() {
    final value = order.fulfillment?.scheduledAt;
    if (value == null || value.isEmpty) return 'طلب مجدول';
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.all(Radius.circular(8)),
      child: Container(
        padding: EdgeInsets.only(top: 14, bottom: _isScheduled ? 12 : 22),
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
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    order.orderNumber ?? '#${order.id ?? '—'}',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      height: 28 / 10,
                    ),
                  ),
                  Container(
                    width: 70,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: .12),
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: AppText(
                      order.statusLabel ?? 'قيد المعالجة',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Divider(color: Color(0x669CA3AF), height: 1, thickness: 1),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage(AppImages.store),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          order.merchant?.name ?? '—',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            height: 23 / 10,
                          ),
                        ),
                        Row(
                          spacing: 4,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.locationDot,
                              size: 10,
                              color: Color(0xFF9CA3AF),
                            ),
                            AppText(
                              '—',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                height: 17 / 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AppText(
                    _money(order.amounts?.total ?? 0),
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 28 / 12,
                    ),
                  ),
                ],
              ),
            ),
            if (_isScheduled) ...[
              SizedBox(height: 12),
              Divider(color: Color(0x669CA3AF), height: 1, thickness: 1),
              SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  spacing: 6,
                  children: [
                    CircleAvatar(
                      radius: 19,
                      backgroundColor: Color(0x142F40AD),
                      child: FaIcon(
                        FontAwesomeIcons.calendar,
                        size: 20,
                        color: Color(0xFF2F40AD),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          AppText(
                            'موعد الاستلام',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              height: 17 / 10,
                            ),
                          ),
                          AppText(
                            _scheduledLabel(),
                            style: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              height: 17 / 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: .12),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Text(
                        "مجدول",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 16 / 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
