import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../generated/assets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.labelLarge('مرحباً بعودتك 👋', color: Color(0xff6B7280), textAlign: TextAlign.start),
                    AppText.titleMedium('أحمد محمد', color: Color(0xff1E2A78), textAlign: TextAlign.start, fontWeight: FontWeight.bold),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xffF9FAFB),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: Color(0xffF3F4F6), width: 1),
                ),
                padding: EdgeInsetsDirectional.all(10),
                child: Icon(Icons.notifications_outlined, color: Color(0xff1A1A1A)),
              ),
            ],
          ),
          SizedBox(height: 8),
          Divider(color: Colors.black.withAlpha(51), thickness: 1),
          SizedBox(height: 70),
          AppText.titleLarge('ما الذي يمكننا مساعدتك به اليوم ؟', color: Color(0xff1E2A7B), fontWeight: FontWeight.w600),
          SizedBox(height: 8),
          AppText.bodyMedium('حدد نوع الخدمة التي تريدها', fontWeight: FontWeight.w500),
          Divider(color: Colors.black.withAlpha(51), thickness: 1),
          SizedBox(height: 16),
          Column(
            spacing: 20,
            children: List.generate(
              2,
              (i) => InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: (){
                  context.pushRoute('/rsmain');
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(image: AssetImage(Assets.images.cleaningBanner.path)),
                  ),
                  width: context.width,
                  height: 200,
                  padding: EdgeInsetsDirectional.symmetric(vertical: 12, horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsetsDirectional.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [AppText.labelLarge(i == 0 ? 'تنظيف' : 'مطاعم', fontWeight: FontWeight.w600)],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
