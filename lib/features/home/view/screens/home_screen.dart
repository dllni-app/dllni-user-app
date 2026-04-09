import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/home/view/widgets/home_app_bar.dart';
import 'package:flutter/material.dart';

import '../../../../generated/assets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> titles = ['مطاعم', 'تنظيف', 'تسوق'];
    List<String> screens = ['restaurants', 'cleaning', 'shopping'];

    return Column(
      children: [
        HomeAppBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24),
                Row(
                  children: [
                    SizedBox(
                      height: 20,
                      child: VerticalDivider(color: context.primaryContainer, thickness: 4, radius: BorderRadius.circular(9999)),
                    ),
                    SizedBox(width: 8),
                    AppText.titleMedium('الخدمات', fontWeight: FontWeight.bold, color: Color(0xff212C7E)),
                  ],
                ),
                SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 14,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: .8,
                  ),
                  itemBuilder: (context, index) => Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: context.onPrimary,
                          borderRadius: BorderRadius.circular(24),
                          image: DecorationImage(image: AssetImage(Assets.images.test.path), fit: BoxFit.cover),
                        ),
                      ),
                      SizedBox(height: 8),
                      AppText.labelLarge(titles[index % 3], color: Color(0xff6B7280), fontWeight: FontWeight.w500),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                Row(
                  children: [
                    SizedBox(
                      height: 20,
                      child: VerticalDivider(color: context.primaryContainer, thickness: 4, radius: BorderRadius.circular(9999)),
                    ),
                    SizedBox(width: 8),
                    AppText.titleMedium('عروض مميزة لك', fontWeight: FontWeight.bold, color: Color(0xff212C7E)),
                  ],
                ),
                SizedBox(height: 4),
                AppText.bodyMedium(
                  'اكتشف أفضل العروض والخدمات المختارة \nخصيصا لك، بتجربة سريعة وسهلة بضغطة واحدة',
                  color: Color(0xff6B7280),
                  textAlign: TextAlign.start,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
