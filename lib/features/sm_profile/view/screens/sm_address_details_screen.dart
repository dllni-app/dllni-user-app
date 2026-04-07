import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/app_app_bars.dart';

@AutoRoutePage(path: "/sm_address_details")
class SmAddressDetailsScreen extends StatelessWidget {
  const SmAddressDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppSimpleAppBar2(
            title: "المنزل",
            arrowBackType: ArrowBackType.cupertino,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MapCard(),
                  SizedBox(height: 20),
                  _AddressField(
                    title: "اسم العنوان",
                    hintText: "مثل: المنزل , العمل , الجيم , الجامعة , الخ",
                  ),
                  SizedBox(height: 20),
                  _AddressField(title: "المنطقة"),
                  SizedBox(height: 20),
                  _AddressField(title: "الشارع"),
                  SizedBox(height: 20),
                  _AddressField(title: "موبايل"),
                  SizedBox(height: 20),
                  _AddressField(
                    title: "تفاصيل العنوان",
                    hintText:
                        "مثال : المبنى الأول , الطابق 1 , ثم اضغط على الجرس \nأو اترك الطرد بجانب البيت \n\nلا تثم بإضافة تغييرات او طلبات على الطلب هنا",
                    maxLines: 4,
                  ),
                  SizedBox(height: 32),
                  Row(
                    spacing: 20,
                    children: [
                      Expanded(
                        child: _AddressButton(
                          color: AppColors.accent,
                          title: "تعديل عنوان التوصيل",
                        ),
                      ),
                      Expanded(
                        child: _AddressButton(
                          color: Color(0xFFDC2626),
                          title: "حذف العنوان",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressButton extends StatelessWidget {
  const _AddressButton({super.key, required this.color, required this.title});
  final Color color;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .11),
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: AppText(
        title,
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 30 / 16,
        ),
      ),
    );
  }
}

class _AddressField extends StatelessWidget {
  const _AddressField({
    super.key,
    required this.title,
    this.hintText,
    this.maxLines = 1,
    this.readOnly = false,
  });
  final String title;
  final String? hintText;
  final bool readOnly;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          textAlign: TextAlign.start,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 30 / 16,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          style: TextStyle(color: Colors.black, fontSize: 14, height: 26 / 14),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(12),
            hintText: hintText,
            hintStyle: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
              height: 26 / 14,
            ),
            filled: true,
            fillColor: readOnly ? Color(0x2E6B7280) : AppColors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: readOnly
                  ? BorderSide(width: .5, color: Color(0xCF6B7280))
                  : BorderSide.none,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: readOnly
                  ? BorderSide(width: .5, color: Color(0xCF6B7280))
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: readOnly
                  ? BorderSide(width: .5, color: Color(0xCF6B7280))
                  : BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: context.width, height: 145, color: Colors.grey),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                Row(
                  children: [
                    AppText(
                      "حلب",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 30 / 16,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        context.pushRoute("/sm_address_map");
                      },
                      child: AppText(
                        "تعديل",
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                          height: 21 / 14,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
                AppText(
                  "المارتيني , شارع القصور  بناية محضر 12",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    height: 22 / 12,
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
