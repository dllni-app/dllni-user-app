import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../product_card_2.dart';

class RelatedProductsDialog extends StatelessWidget {
  const RelatedProductsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.fromLTRB(16, 16, 16, 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Color(0xFFF3F4F6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  "نتائج المقارنة",
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 20 / 14,
                  ),
                ),
                InkWell(
                  onTap: () {
                    context.pop();
                  },
                  customBorder: CircleBorder(),
                  child: Ink(
                    width: 24,
                    height: 24,
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.x,
                        size: 12,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 400),
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 16),
                itemCount: 5,
                itemBuilder: (_, _) => ProductCard2(),
                separatorBuilder: (_, _) => SizedBox(height: 12),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: AppText(
                "3 منتجات",
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 16 / 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
