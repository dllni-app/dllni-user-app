import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_gradients.dart';
import '../../../../core/themes/app_shadows.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.title,
    this.hintText,
    this.onChanged,
    this.controller,
    this.readOnly = false,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.isRequired = false,
  });
  final bool isRequired;
  final String title;
  final String? hintText;
  final int? maxLines;
  final bool readOnly;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final void Function(String value)? onChanged;
  final TextEditingController? controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            text: title,
            children: [
              if (isRequired)
                TextSpan(
                  text: "*",
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.42,
                  ),
                ),
            ],
          ),

          style: TextStyle(
            color: Color(0xFF374151),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.42,
          ),
        ),
        TextField(
          maxLines: maxLines,
          readOnly: readOnly,
          onChanged: onChanged,
          controller: controller,
          keyboardType: keyboardType,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          style: TextStyle(color: Color(0xB22F2B3D), fontSize: 14),
          decoration: InputDecoration(
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Color(0xFFF9FAFB),
            hintText: hintText,
            hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }
}

class ProductMenuField<T> extends StatelessWidget {
  const ProductMenuField({
    super.key,
    required this.title,
    this.hintText,
    this.onChanged,
    required this.items,
    this.isRequired = false,
  });
  final String title;
  final bool isRequired;
  final String? hintText;
  final void Function(T? value)? onChanged;
  final List<DropdownMenuItem<T>> items;
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: title,
            children: [
              if (isRequired)
                TextSpan(
                  text: "*",
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.42,
                  ),
                ),
            ],
          ),

          style: TextStyle(
            color: Color(0xFF374151),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.42,
          ),
        ),
        DropdownButtonFormField<T>(
          items: items,
          onChanged: onChanged,
          style: TextStyle(color: Color(0xB22F2B3D), fontSize: 14),
          hint: AppText(
            hintText ?? "",
            style: TextStyle(
              fontFamily: "Cairo",
              color: Color(0xFF111827),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }
}

class AppDatePicker extends StatefulWidget {
  const AppDatePicker({
    super.key,
    required this.title,
    this.isRequired = false,
    required this.onDateChanged,
  });
  final String title;
  final bool isRequired;
  final void Function(DateTime expiredDate) onDateChanged;
  @override
  State<AppDatePicker> createState() => _AppDatePickerState();
}

class _AppDatePickerState extends State<AppDatePicker> {
  DateTime? expiredDate;
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: widget.title,
            children: [
              if (widget.isRequired)
                TextSpan(
                  text: "*",
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.42,
                  ),
                ),
            ],
          ),
          style: TextStyle(
            color: Color(0xFF374151),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.42,
          ),
        ),
        TextField(
          controller: expiredDate == null
              ? null
              : TextEditingController(text: expiredDate!.toString()),
          readOnly: true,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          style: TextStyle(color: Color(0xB22F2B3D), fontSize: 14),
          decoration: InputDecoration(
            suffixIcon: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                onTap: () async {
                  DateTime? date = await showDatePicker(
                    context: context,
                    locale: const Locale('en'),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: ColorScheme.light(
                            primary: AppColors.primary,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (date == null) return;
                  expiredDate = date;
                  widget.onDateChanged(date);
                  setState(() {});
                },
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Icon(
                    Icons.date_range_rounded,
                    size: 18,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ),
            filled: true,
            fillColor: Color(0xFFF9FAFB),
            hintText: "01 - 01 - 2030",
            hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }
}

class ProductUnit extends StatefulWidget {
  const ProductUnit({super.key, required this.onChanged});
  final void Function(String unit) onChanged;
  @override
  State<ProductUnit> createState() => _ProductUnitState();
}

class _ProductUnitState extends State<ProductUnit> {
  String? unit;
  late TextEditingController controller;
  @override
  void initState() {
    controller = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: "وحدة القياس",
            children: [
              TextSpan(
                text: "*",
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.42,
                ),
              ),
            ],
          ),
          style: TextStyle(
            color: Color(0xFF374151),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.42,
          ),
        ),
        SizedBox(height: 8),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (unit == "كغ") return;
                  unit = "كغ";
                  controller.clear();
                  setState(() {});
                  widget.onChanged(unit!);
                },
                child: _ProductUnitChip(unit: unit, value: "كغ"),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (unit == "لتر") return;
                  unit = "لتر";
                  controller.clear();
                  setState(() {});
                  widget.onChanged(unit!);
                },
                child: _ProductUnitChip(unit: unit, value: "لتر"),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (unit == "قطعة") return;
                  unit = "قطعة";
                  controller.clear();
                  setState(() {});
                  widget.onChanged(unit!);
                },
                child: _ProductUnitChip(unit: unit, value: "قطعة"),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: (value) {
            if (unit == "كغ" || unit == "لتر" || unit == "قطعة") {
              unit = value;
              setState(() {});
            } else {
              unit = value;
            }
            widget.onChanged(unit!);
          },
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          style: TextStyle(color: Color(0xB22F2B3D), fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: Color(0xFFF9FAFB),
            hintText: "أو اكتب وحدة مخصصة",
            hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductUnitChip extends StatelessWidget {
  const _ProductUnitChip({required this.unit, required this.value});
  final String? unit;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 9, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(100)),
        color: unit == value ? null : AppColors.white,
        gradient: unit == value ? AppGradients.gradient : null,
        border: unit != value ? Border.all(color: Color(0xFFE5E7EB)) : null,
        boxShadow: [AppShadows.shadow],
      ),
      child: AppText(
        value,
        style: TextStyle(
          color: unit == value ? AppColors.white : Color(0xFF4B5563),
          fontSize: 14,
          fontWeight: unit == value ? FontWeight.w700 : FontWeight.w500,
          height: 1.42,
        ),
      ),
    );
  }
}
