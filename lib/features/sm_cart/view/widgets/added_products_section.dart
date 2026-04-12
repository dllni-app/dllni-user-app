import 'package:common_package/common_package.dart';
import 'package:dotted_border/dotted_border.dart';
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
        ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (_, _) => ProductCard(),
          separatorBuilder: (_, _) => SizedBox(height: 16),
          itemCount: 2,
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(
            onTap: () {},
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            borderRadius: BorderRadius.all(Radius.circular(16)),
            child: Container(
              decoration: BoxDecoration(color: Color(0xFFF9FAFB), borderRadius: BorderRadius.all(Radius.circular(16))),
              child: DottedBorder(
                ignoring: false,
                options: RoundedRectDottedBorderOptions(radius: Radius.circular(16), dashPattern: [12, 6], strokeWidth: 2, color: Color(0x1F2F2B3D)),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(FontAwesomeIcons.plus, color: Color(0xE52F2B3D), size: 13),
                      SizedBox(width: 4),
                      AppText(
                        "إضافة منتجات أخرى",
                        style: TextStyle(color: Color(0xE52F2B3D), fontSize: 12, fontWeight: FontWeight.w500, height: 16 / 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [BoxShadow(offset: Offset(0, 1), blurRadius: 2, color: Color(0x0D000000))],
      ),
      child: Column(
        spacing: 12,
        children: [
          Row(
            children: [
              AppImage.asset(AppImages.products, size: 96, borderRadius: BorderRadius.all(Radius.circular(12))),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    AppText(
                      "لبنة نيو بارك",
                      style: TextStyle(color: Color(0xFF1F2937), fontSize: 18, fontWeight: FontWeight.w700, height: 23 / 18),
                    ),
                    AppText(
                      "متجر النور",
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w500, height: 20 / 14),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: "الوزن :"),
                          TextSpan(
                            text: " 250 كغ",
                            style: TextStyle(color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                      style: TextStyle(color: Color(0xFF1F2937), fontSize: 12, fontWeight: FontWeight.w500, height: 16 / 12),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: "الإضافات:"),
                          TextSpan(
                            text: " جبنة إضافية، صوص خاص",
                            style: TextStyle(color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                      style: TextStyle(color: Color(0xFF1F2937), fontSize: 12, fontWeight: FontWeight.w500, height: 16 / 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  border: Border.all(color: Color(0xFFE5E7EB)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        child: Center(child: FaIcon(FontAwesomeIcons.minus, size: 12, color: Color(0xFF1A237E))),
                      ),
                    ),
                    SizedBox(
                      width: 30,
                      child: AppText(
                        "2",
                        style: TextStyle(color: Color(0xFF1F2937), fontSize: 14, fontWeight: FontWeight.w700, height: 20 / 14),
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        child: Center(child: FaIcon(FontAwesomeIcons.plus, size: 12, color: Color(0xFF1A237E))),
                      ),
                    ),
                  ],
                ),
              ),
              AppText(
                "450 ل.س",
                style: TextStyle(color: Color(0xFF1A237E), fontSize: 16, fontWeight: FontWeight.w700, height: 24 / 16),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 48,
            children: [
              _TextButtonWithIcon(label: "تعديل", icon: FontAwesomeIcons.solidPenToSquare, onTap: () {}),
              _TextButtonWithIcon(label: "حذف", icon: FontAwesomeIcons.trash, color: Color(0xFFFF4C51), onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

class _TextButtonWithIcon extends StatelessWidget {
  const _TextButtonWithIcon({super.key, required this.label, required this.icon, this.onTap, this.color = const Color(0xFF1A237E)});

  final String label;
  final FaIconData icon;
  final Color color;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.all(Radius.circular(4)),
        splashColor: color.withValues(alpha: .18),
        highlightColor: color.withValues(alpha: .08),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            FaIcon(icon, size: 10, color: color),
            AppText(
              label,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500, height: 16 / 12),
            ),
          ],
        ),
      ),
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
        boxShadow: [BoxShadow(color: Color(0x1A000000), offset: Offset(0, 4), blurRadius: 7.4)],
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
            child: FaIcon(FontAwesomeIcons.minus, color: Colors.black, size: 11),
          ),
          AppText(
            counter.toString(),
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.w500, height: 28 / 12),
          ),
          InkWell(
            onTap: () {
              counter++;
              setState(() {});
              widget.onChanged(counter);
            },
            customBorder: CircleBorder(),
            child: FaIcon(FontAwesomeIcons.plus, color: AppColors.accent, size: 11),
          ),
        ],
      ),
    );
  }
}
