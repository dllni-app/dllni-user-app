import 'package:flutter/material.dart';
import '../../../../core/models/cleaning_gender_preference.dart';
import '../../../../core/widgets/design_system/design_system.dart';
import 'cl_service_section_card_widget.dart';

/// V6 selection surface, preserving the existing gender preference enum.
class ClServiceGenderPreferenceSectionWidget extends StatelessWidget {
  const ClServiceGenderPreferenceSectionWidget({
    required this.selectedPreference,
    required this.onChanged,
    this.step = 2,
    this.showStepBadge = false,
    super.key,
  });
  final CleaningGenderPreference? selectedPreference;
  final ValueChanged<CleaningGenderPreference> onChanged;
  final int step;
  final bool showStepBadge;

  @override
  Widget build(BuildContext context) => ClServiceSectionCardWidget(
    title: 'تفضيل مقدم الخدمة',
    subtitle: 'اختر ما يناسبك. يخضع توفر مقدم الخدمة وقبوله لحالة الطلب.',
    step: step,
    showStepBadge: showStepBadge,
    child: Column(
      children: [
        for (final preference in const [
          CleaningGenderPreference.male,
          CleaningGenderPreference.female,
        ]) ...[
          AppChoiceTile(
            key: Key('cleaning_gender_pref_${preference.apiValue}'),
            title: preference.arabicLabel,
            selected: selectedPreference == preference,
            section: AppSection.cleaning,
            onTap: () => onChanged(preference),
          ),
          if (preference == CleaningGenderPreference.male)
            const SizedBox(height: 10),
        ],
      ],
    ),
  );
}
