import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/sm_cart/view/widgets/cart_main_button.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/app_app_bars.dart';

@AutoRoutePage(path: "/late_time")
class SmLateTimeScreen extends StatefulWidget {
  const SmLateTimeScreen({super.key});

  @override
  State<SmLateTimeScreen> createState() => _SmLateTimeScreenState();
}

class _SmLateTimeScreenState extends State<SmLateTimeScreen> {
  int selectedDay = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppSimpleAppBar2(
            title: "طلب مجدول",
            arrowBackType: ArrowBackType.cupertino,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: [
                  SizedBox(height: 19),
                  Row(
                    spacing: 12,
                    children: [
                      _DayChip(
                        day: "الخميس",
                        date: "12 مارس",
                        isSelected: selectedDay == 0,
                        onTap: () {
                          if (selectedDay == 0) return;
                          selectedDay = 0;
                          setState(() {});
                        },
                      ),
                      _DayChip(
                        day: "الجمعة",
                        date: "13 مارس",
                        isSelected: selectedDay == 1,
                        onTap: () {
                          if (selectedDay == 1) return;
                          selectedDay = 1;
                          setState(() {});
                        },
                      ),
                      _DayChip(
                        day: "السبت",
                        date: "14 مارس",
                        isSelected: selectedDay == 2,
                        onTap: () {
                          if (selectedDay == 2) return;
                          selectedDay = 2;
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: context.width,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Row(
                      children: [
                        AppText(
                          "وفقاً للتوقيت  ",
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 32 / 12,
                          ),
                        ),
                        AppText(
                          "السوري (GMT +3)",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 32 / 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  _SelectTime(
                    times: [
                      "06:00 ص _ 06:15 ص",
                      "06:15 ص _ 06:30 ص",
                      "06:30 ص _ 06:45 ص",
                      "06:45 ص _ 07:00 ص",
                      "07:00 ص _ 07:15 ص",
                      "07:15 ص _ 07:30 ص",
                      "07:30 ص _ 07:45 ص",
                      "07:45 ص _ 08:00 ص",
                      "08:00 ص _ 08:15 ص",
                    ],
                    onChanged: (time) {
                      print(time);
                    },
                  ),
                  SizedBox(height: 24),
                  Row(
                    spacing: 15,
                    children: [
                      Expanded(
                        child: CartMainButton(
                          label: "إلغاء",
                          backgroundColor: Color(0xFF9CA3AF),
                          onTap: () {},
                        ),
                      ),
                      Expanded(
                        child: CartMainButton(label: "حفظ", onTap: () {}),
                      ),
                    ],
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

class _SelectTime extends StatefulWidget {
  const _SelectTime({required this.onChanged, required this.times});
  final void Function(String time) onChanged;
  final List<String> times;

  @override
  State<_SelectTime> createState() => _SelectTimeState();
}

class _SelectTimeState extends State<_SelectTime> {
  int? selectedTime;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Column(
        spacing: 13,
        children: List.generate(
          widget.times.length,
          (index) => Row(
            children: [
              Radio(
                value: index,
                groupValue: selectedTime,
                onChanged: (value) {
                  if (selectedTime == value) return;
                  selectedTime = value;
                  setState(() {});
                  widget.onChanged(widget.times[index]);
                },
                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                fillColor: WidgetStatePropertyAll(Color(0xFF6B7280)),
                activeColor: AppColors.primary,
              ),
              SizedBox(width: 12),
              Expanded(
                child: AppText(
                  widget.times[index],
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 32 / 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.date,
    required this.onTap,
    required this.isSelected,
  });
  final String day;
  final String date;
  final bool isSelected;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        child: Container(
          padding: EdgeInsets.fromLTRB(32, 15, 31, 17),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: isSelected ? Border.all(color: AppColors.accent) : null,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                day,
                style: TextStyle(
                  color: isSelected ? AppColors.accent : Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 14 / 12,
                ),
              ),
              SizedBox(height: 9),
              AppText(
                date,
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 14 / 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
