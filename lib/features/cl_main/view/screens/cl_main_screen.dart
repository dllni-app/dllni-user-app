import 'package:common_package/annotations/auto_route_page.dart';
import 'package:flutter/material.dart';

import '../../../../generated/assets.dart';
import '../widgets/cl_home_app_bar.dart';
import '../widgets/cl_property_type_card_widget.dart';

@AutoRoutePage()
class ClMainScreen extends StatelessWidget {
  const ClMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final propertyTypes = <({String title, String icon})>[
      (title: 'فيلا دوبلكس', icon: Assets.images.villaImage.path),
      (title: 'مكتب', icon: Assets.images.officeImage.path),
      (title: 'شقة', icon: Assets.images.homeImage.path),
      (title: 'استديو', icon: Assets.images.studioImage.path),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            ClHomeAppBar(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
                itemCount: propertyTypes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = propertyTypes[index];
                  return ClPropertyTypeCardWidget(title: item.title, icon: item.icon);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
