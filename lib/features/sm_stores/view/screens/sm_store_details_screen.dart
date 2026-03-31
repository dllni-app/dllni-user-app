import 'dart:ui';

import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';
import '../widgets/products_section.dart';
import '../widgets/special_offers_section.dart';
import '../widgets/store_cover_section.dart';
import '../widgets/store_info_section.dart';
import '../widgets/store_status_section.dart';

@AutoRoutePage(path: "/store")
class SmStoreDetailsScreen extends StatelessWidget {
  const SmStoreDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            StoreCoverSection(),
            SizedBox(height: 16),
            StoreStatusSection(),
            SizedBox(height: 20),
            Divider(height: 1, color: Color(0xFFF3F4F6)),
            SizedBox(height: 28),
            StoreInfoSection(),
            SizedBox(height: 16),
            Divider(height: 1, color: Color(0xFFF3F4F6)),
            SizedBox(height: 44),
            SpecialOffersSection(),
            SizedBox(height: 20),
            Divider(height: 1, color: Color(0xFFF3F4F6)),
            ProductsSection(title: "مخبوزات"),
            SizedBox(height: 350),
          ],
        ),
      ),
    );
  }
}
