import 'package:common_package/common_package.dart';
import 'package:common_package/annotations/auto_route_page.dart';
import 'package:flutter/material.dart';

import '../widgets/cl_counter_row_widget.dart';
import '../widgets/cl_home_description_title_card_widget.dart';
import '../widgets/cl_main_continue_button_widget.dart';
import '../widgets/cl_option_tile_widget.dart';
import '../widgets/home_details_app_bar.dart';

@AutoRoutePage()
class ClMainHomeDescriptionScreen extends StatefulWidget {
  const ClMainHomeDescriptionScreen({super.key});

  @override
  State<ClMainHomeDescriptionScreen> createState() => _ClMainHomeDescriptionScreenState();
}

class _ClMainHomeDescriptionScreenState extends State<ClMainHomeDescriptionScreen> {
  int bedroomsCount = 1;
  int bathroomsCount = 1;

  String selectedLivingRoomOption = '';
  String selectedHeadboardOption = '';

  void _selectLivingRoomOption(String key, bool isSelected) {
    setState(() {
      selectedLivingRoomOption = isSelected ? key : '';
    });
  }

  void _selectHeadboardOption(String key, bool isSelected) {
    setState(() {
      selectedHeadboardOption = isSelected ? key : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    const livingRoomOptions = <({String key, String title, String subtitle})>[
      (key: 'small', title: 'صغيرة', subtitle: 'تجلس 5 - 6 أشخاص'),
      (key: 'medium', title: 'كبيرة', subtitle: 'تجلس 8 - 10 أشخاص'),
      (key: 'very_big', title: 'كبيرة جداً', subtitle: 'تضيف قيمة مع الديكور'),
    ];
    const headboardOptions = <({String key, String title, String subtitle})>[
      (key: 'regular', title: 'لوح رأسي', subtitle: 'مناسب للغرف اليومية'),
      (key: 'small', title: 'رأس صغير', subtitle: 'مناسب للأماكن الضيقة'),
      (key: 'big', title: 'رأس كبير', subtitle: 'لإطلالة فخمة أكبر'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            HomeDetailsAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  children: [
                    ClHomeDescriptionTitleCardWidget(
                      step: 1,
                      title: 'تحديد عدد الغرف',
                      subtitle: 'هذا سيساعدنا على تحديد المساحة التقريبية للعمل',
                      child: Column(
                        spacing: 12,
                        children: [
                          ClCounterRowWidget(
                            label: 'عدد الغرف',
                            value: bedroomsCount,
                            icon: Icons.meeting_room,
                            onIncrement: () => setState(() => bedroomsCount++),
                            onDecrement: () => setState(() => bedroomsCount = (bedroomsCount > 1) ? bedroomsCount - 1 : 1),
                          ),
                          ClCounterRowWidget(
                            label: 'عدد الحمامات',
                            value: bathroomsCount,
                            icon: Icons.bathtub_outlined,
                            onIncrement: () => setState(() => bathroomsCount++),
                            onDecrement: () => setState(() => bathroomsCount = (bathroomsCount > 1) ? bathroomsCount - 1 : 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClHomeDescriptionTitleCardWidget(
                      step: 2,
                      title: 'وصف تقريبي لحجم الغرفة',
                      subtitle: 'اختر نوع أقرب وصف لحجم الغرفة',
                      child: Column(
                        children: [
                          SizedBox(height: 12),
                          ...livingRoomOptions.map(
                            (option) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ClOptionTileWidget(
                                title: option.title,
                                subtitle: option.subtitle,
                                value: selectedLivingRoomOption == option.key,
                                onChanged: (selected) => _selectLivingRoomOption(option.key, selected),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClHomeDescriptionTitleCardWidget(
                      step: 3,
                      title: 'تحديد حجم التراس',
                      subtitle: 'حدد حجم التراس في حال وجوده',
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: headboardOptions.length,
                        itemBuilder: (context, index) {
                          final option = headboardOptions[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: index == headboardOptions.length - 1 ? 0 : 8),
                            child: ClOptionTileWidget(
                              title: option.title,
                              subtitle: option.subtitle,
                              value: selectedHeadboardOption == option.key,
                              onChanged: (selected) => _selectHeadboardOption(option.key, selected),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClMainContinueButtonWidget(
                      onPressed: () {
                        context.pushRoute('/clmainserviceschedule');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
