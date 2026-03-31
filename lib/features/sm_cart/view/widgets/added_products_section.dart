import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/app_images.dart';

class AddedProductsSection extends StatelessWidget {
  const AddedProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: AppImage.asset(
                  AppImages.products,
                  width: 88,
                  height: 70,
                  fit: BoxFit.contain,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      "هوى الشام لبنة كريمية",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        height: 32 / 11,
                      ),
                    ),
                    Text(
                      "8000 ل.س",
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        height: 17 / 10,
                      ),
                    ),
                    SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _CounterChip(onChanged: (value) {}),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(color: Color(0x0F000000), height: 1),
        ),
        SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 16),
            child: InkWell(
              onTap: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    FontAwesomeIcons.plus,
                    color: AppColors.accent,
                    size: 10,
                  ),
                  SizedBox(width: 4),
                  AppText(
                    "إضافة المزيد",
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 32 / 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CounterChip extends StatefulWidget {
  const _CounterChip({required this.onChanged, this.initialCount = 1});
  final int initialCount;
  final void Function(int value) onChanged;
  @override
  State<_CounterChip> createState() => _CounterChipState();
}

class _CounterChipState extends State<_CounterChip> {
  int counter = 0;
  @override
  void initState() {
    counter = widget.initialCount;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.all(Radius.circular(14)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 4),
            blurRadius: 7.4,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 14,
        children: [
          InkWell(
            onTap: () {
              if (counter == 1) return;
              counter--;
              setState(() {});
              widget.onChanged(counter);
            },
            customBorder: CircleBorder(),
            child: FaIcon(
              FontAwesomeIcons.minus,
              color: Colors.black,
              size: 11,
            ),
          ),
          AppText(
            counter.toString(),
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 28 / 12,
            ),
          ),
          InkWell(
            onTap: () {
              counter++;
              setState(() {});
              widget.onChanged(counter);
            },
            customBorder: CircleBorder(),
            child: FaIcon(
              FontAwesomeIcons.plus,
              color: AppColors.accent,
              size: 11,
            ),
          ),
        ],
      ),
    );
  }
}
