import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/app_app_bars.dart';
import '../widgets/cart_main_button.dart';
import '../widgets/summary_request_with_time.dart';

@AutoRoutePage(path: "/cart_details")
class SmCartDetailsScreen extends StatelessWidget {
  const SmCartDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppSimpleAppBar2(title: "الطلبية الحالية"),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 32),
                  SelectDeliverySection(),
                  SizedBox(height: 20),
                  SummaryRequestWithTime(),
                  SizedBox(height: 24),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: CartMainButton(label: "أرسل الطلب", onTap: () {}),
                  ),
                  SizedBox(height: 67),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SelectDeliverySection extends StatefulWidget {
  const SelectDeliverySection({super.key});

  @override
  State<SelectDeliverySection> createState() => _SelectDeliverySectionState();
}

class _SelectDeliverySectionState extends State<SelectDeliverySection> {
  int selectedWay = -1;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: AppText(
              "اختر الطريقة المناسبة لاستلام طلبك",
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 20 / 14,
              ),
            ),
          ),
          SizedBox(height: 16),
          Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              _DeliveryWay(
                title: "توصيل إلى العنوان",
                description: "سيتم توصيل طلبك إلى موقعك",
                icon: FontAwesomeIcons.motorcycle,
                isSelected: selectedWay == 0,
                onTap: () {
                  if (selectedWay == 0) return;
                  selectedWay = 0;
                  setState(() {});
                },
              ),
              _DeliveryWay(
                title: "استلام من المتجر",
                description: "يمكنك استلام طلبك بنفسك",
                icon: FontAwesomeIcons.store,
                isSelected: selectedWay == 1,
                onTap: () {
                  if (selectedWay == 1) return;
                  selectedWay = 1;
                  setState(() {});
                },
              ),
            ],
          ),
          SizedBox(height: 20),
          AppText(
            "وقت الاستلام",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 32 / 16,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: AppText(
                        "بأسرع وقت",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 32 / 14,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      context.pushRoute("/late_time");
                    },
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: AppText(
                          "طلب مجدول",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 32 / 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          _AddressCard(),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 2,
            color: Color(0x0D000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.locationDot,
                size: 16,
                color: AppColors.accent,
              ),
              SizedBox(width: 8),
              AppText(
                "عنوان التوصيل",
                style: TextStyle(
                  color: Color(0xFF1E2B5E),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 24 / 16,
                ),
              ),
              Spacer(),
              InkWell(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: .05),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Text(
                    "تغيير",
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 16 / 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                AppText(
                  "المنزل",
                  style: TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 20 / 14,
                  ),
                ),
                AppText(
                  " العزيزية, شارع الكتاب المقدس، جانب محل مهند، ط 2",
                  style: TextStyle(
                    color: Color(0xFF718096),
                    fontSize: 12,
                    height: 16 / 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryWay extends StatelessWidget {
  const _DeliveryWay({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });
  final String title;
  final String description;
  final FaIconData icon;
  final bool isSelected;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.all(Radius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: .03)
              : AppColors.white,
          borderRadius: BorderRadius.all(Radius.circular(16)),
          border: Border.all(
            width: isSelected ? 2 : 1,
            color: isSelected
                ? AppColors.primary.withValues(alpha: .82)
                : Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 1),
              blurRadius: 2,
              color: Color(0x0D000000),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: .13)
                    : Color(0x142F2B3D),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: FaIcon(
                icon,
                size: 24,
                color: isSelected ? AppColors.primary : Color(0x8C2F2B3D),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : Color(0xE52F2B3D),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 28 / 18,
                    ),
                  ),
                  SizedBox(height: 4),
                  AppText(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : Color(0xB22F2B3D),
                      fontSize: 14,
                      height: 20 / 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              FaIcon(
                FontAwesomeIcons.solidCircleCheck,
                size: 24,
                color: AppColors.primary,
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 2, color: Color(0xFFD1D5DB)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
