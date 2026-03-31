import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';
import '../widgets/cart_main_button.dart';
import '../widgets/cart_simple_app_bar.dart';
import '../widgets/coupon_section.dart';
import '../widgets/summary_request.dart';

@AutoRoutePage(path: "/cart_details")
class SmCartDetailsScreen extends StatelessWidget {
  const SmCartDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CartSimpleAppBar(title: "سلتك"),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 32),
                  SelectDeliverySection(),
                  SizedBox(height: 16),
                  CouponSection(),
                  SizedBox(height: 16),
                  SummaryRequest(),
                  SizedBox(height: 24),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: CartMainButton(label: "أرسل الطلب", onTap: () {}),
                  ),
                  SizedBox(height: 47),
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: AppText(
              "اختر الطريقة المناسبة لاستلام طلبك",
              style: TextStyle(
                color: AppColors.primary,
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
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: AppText(
                        "بأسرع وقت",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 32 / 12,
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
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: AppText(
                          "طلب لاحق",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 32 / 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          if (selectedWay == 1) InStoreSection(),
          if (selectedWay == 0) DeliverySection(),
        ],
      ),
    );
  }
}

class InStoreSection extends StatelessWidget {
  const InStoreSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          "عنوان المتجر",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 32 / 16,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FaIcon(FontAwesomeIcons.store, size: 22, color: AppColors.accent),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    AppText(
                      "الفرقان دوار الصخرة",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        height: 20 / 14,
                      ),
                    ),
                    AppText(
                      "الفرقان دوار الصخرة",
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 10,
                        fontWeight: FontWeight.w300,
                        height: 19 / 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DeliverySection extends StatelessWidget {
  const DeliverySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          "عنوان التوصيل",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 32 / 16,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FaIcon(
                FontAwesomeIcons.building,
                size: 22,
                color: AppColors.accent,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    AppText(
                      "المنزل",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        height: 20 / 14,
                      ),
                    ),
                    AppText(
                      "الحمدانية دوار الإطفائية",
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 10,
                        fontWeight: FontWeight.w300,
                        height: 19 / 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        AppText(
          "تعليمات التوصيل",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 32 / 16,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: Row(
            children: [
              Container(
                width: 112,
                height: 31,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: AppText(
                  "اتصل بي عندما تصل",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 14 / 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
              ? AppColors.accent.withValues(alpha: .04)
              : AppColors.white,
          borderRadius: BorderRadius.all(Radius.circular(16)),
          border: Border.all(
            width: isSelected ? 2 : 1,
            color: isSelected ? AppColors.accent : Color(0xFFE2E8F0),
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
                color: isSelected ? Color(0xFFF3D4B8) : Color(0x142F2B3D),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: FaIcon(
                icon,
                size: 24,
                color: isSelected ? AppColors.accent : Color(0x8C2F2B3D),
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
                      color: isSelected ? AppColors.accent : Color(0xE52F2B3D),
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
                      color: isSelected ? AppColors.accent : Color(0xB22F2B3D),
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
                color: AppColors.accent,
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
