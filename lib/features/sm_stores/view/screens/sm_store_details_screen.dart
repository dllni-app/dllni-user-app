import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../widgets/products_section.dart';
import '../widgets/special_offers_section.dart';
import '../widgets/store_cover_section.dart';
import '../widgets/store_address_section.dart';
import '../widgets/store_info_section.dart';
import '../widgets/store_status_section.dart';

@AutoRoutePage(path: "/store")
class SmStoreDetailsScreen extends StatelessWidget {
  const SmStoreDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            StoreCoverSection(),
            StoreStatusSection(),
            StoreAddressSection(),
            SizedBox(height: 16),
            SpecialOffersSection(),
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: Text(
                      "منتجات المتجر",
                      style: TextStyle(
                        color: const Color(0xFF111827),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 28 / 18,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    child: Text(
                      " عرض الكل ",
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 20 / 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            ProductsSection(title: "مخبوزات"),
            SizedBox(height: 40),
            StoreInfoSection(),
            SizedBox(height: 155),
          ],
        ),
      ),
    );
  }
}
