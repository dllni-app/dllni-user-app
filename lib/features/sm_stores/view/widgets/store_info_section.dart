import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../data/models/get_supermarket_store_details_model.dart';

class StoreInfoSection extends StatelessWidget {
  const StoreInfoSection({super.key, this.description, this.hours = const []});

  final String? description;
  final List<SupermarketStoreDetailsHour> hours;

  @override
  Widget build(BuildContext context) {
    final desc = description?.trim();
    final hourRows = supermarketStoreDetailsGroupedHourUiRows(hours);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            "معلومات المتجر",
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 28 / 20,
            ),
          ),
          SizedBox(height: 20),
          AppText(
            "عن المتجر",
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 24 / 16,
            ),
          ),
          SizedBox(height: 8),
          AppText(
            desc != null && desc.isNotEmpty ? desc : "لا يوجد وصف لهذا المتجر.",
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 23 / 14,
            ),
          ),
          SizedBox(height: 20),
          AppText(
            "ساعات العمل",
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 28 / 20,
            ),
          ),
          SizedBox(height: 8),
          if (hourRows.isEmpty)
            AppText(
              "—",
              style: TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 14,
                height: 20 / 14,
              ),
            )
          else
            ...hourRows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppText(
                        row.dayLabel,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Color(0xFF4B5563),
                          fontSize: 14,
                          height: 20 / 14,
                        ),
                      ),
                    ),
                    AppText(
                      row.timeText.isEmpty ? '—' : row.timeText,
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 20 / 14,
                      ),
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
