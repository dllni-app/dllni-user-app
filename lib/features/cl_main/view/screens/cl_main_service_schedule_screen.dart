import 'package:common_package/common_package.dart';
import 'package:common_package/annotations/auto_route_page.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/app_pickers.dart';
import '../widgets/cl_service_address_section_widget.dart';
import '../widgets/cl_service_bottom_actions_widget.dart';
import '../widgets/cl_service_gradient_info_card_widget.dart';
import '../widgets/cl_service_order_summary_section_widget.dart';
import '../widgets/cl_service_previous_workers_section_widget.dart';
import '../widgets/cl_service_schedule_section_widget.dart';
import '../widgets/home_details_app_bar.dart';

@AutoRoutePage()
class ClMainServiceScheduleScreen extends StatefulWidget {
  const ClMainServiceScheduleScreen({super.key});

  @override
  State<ClMainServiceScheduleScreen> createState() => _ClMainServiceScheduleScreenState();
}

class _ClMainServiceScheduleScreenState extends State<ClMainServiceScheduleScreen> {
  late DateTime _selectedDate;
  late TextEditingController _fromTimeController;
  late TextEditingController _toTimeController;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _fromTimeController = TextEditingController(text: '09:00');
    _toTimeController = TextEditingController(text: '23:00');
  }

  @override
  void dispose() {
    _fromTimeController.dispose();
    _toTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final value = await AppPickers.showAppDatePicker(context: context);
    if (value.isEmpty) return;
    setState(() {
      _selectedDate = DateFormat('yyyy-MM-dd', 'en').parse(value);
    });
  }

  Future<void> _pickFromTime() async {
    final value = await AppPickers.showAppTimePicker(context: context);
    if (value.isEmpty) return;
    setState(() {
      _fromTimeController.text = value;
    });
  }

  Future<void> _pickToTime() async {
    final value = await AppPickers.showAppTimePicker(context: context);
    if (value.isEmpty) return;
    setState(() {
      _toTimeController.text = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dayAr = DateFormat('EEEE', 'ar').format(_selectedDate);
    final dayEn = DateFormat('EEEE', 'en').format(_selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            const HomeDetailsAppBar(),
            SizedBox(height: 20,),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.only(start: 20, end: 20),
                child: Column(
                  children: [
                    const ClServiceGradientInfoCardWidget(),
                    const SizedBox(height: 10),
                    ClServiceScheduleSectionWidget(
                      dayAr: dayAr,
                      dayEn: dayEn,
                      fromTimeController: _fromTimeController,
                      toTimeController: _toTimeController,
                      onPickDate: _pickDate,
                      onPickFromTime: _pickFromTime,
                      onPickToTime: _pickToTime,
                    ),
                    const SizedBox(height: 10),
                    const ClServiceAddressSectionWidget(),
                    const SizedBox(height: 16),
                    const ClServicePreviousWorkersSectionWidget(),
                    const SizedBox(height: 12),
                    const ClServiceOrderSummarySectionWidget(),
                  ],
                ),
              ),
            ),
            Container(
              color: const Color(0xFFF2F2F2),
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 20),
              child: ClServiceBottomActionsWidget(onBackPressed: () => context.pop(), onSubmitPressed: () {}),
            ),
          ],
        ),
      ),
    );
  }
}
