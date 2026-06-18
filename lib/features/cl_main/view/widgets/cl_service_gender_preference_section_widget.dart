import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/models/cleaning_gender_preference.dart';
import 'package:flutter/material.dart';

import 'cl_service_section_card_widget.dart';

class ClServiceGenderPreferenceSectionWidget extends StatelessWidget {
  const ClServiceGenderPreferenceSectionWidget({
    required this.selectedPreference,
    required this.onChanged,
    this.step = 2,
    this.showStepBadge = false,
    super.key,
  });

  final CleaningGenderPreference selectedPreference;
  final ValueChanged<CleaningGenderPreference> onChanged;
  final int step;
  final bool showStepBadge;

  @override
  Widget build(BuildContext context) {
    return ClServiceSectionCardWidget(
      step: step,
      showStepBadge: showStepBadge,
      title: 'تفضيل مقدم الخدمة',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bodySmall(
            'اختر تفضيلك لجنس العامل المفضل',
            color: const Color(0xFF6B7280),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: CleaningGenderPreference.values
                .map(
                  (preference) => ChoiceChip(
                    key: Key('cleaning_gender_pref_${preference.apiValue}'),
                    label: Text(preference.arabicLabel),
                    selected: selectedPreference == preference,
                    onSelected: (_) => onChanged(preference),
                    selectedColor: const Color(0xFF1E2A78),
                    backgroundColor: const Color(0xFFF3F4F6),
                    labelStyle: TextStyle(
                      color: selectedPreference == preference
                          ? Colors.white
                          : const Color(0xFF1F2937),
                      fontWeight: FontWeight.w700,
                    ),
                    side: BorderSide(
                      color: selectedPreference == preference
                          ? const Color(0xFF1E2A78)
                          : const Color(0xFFD1D5DB),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}
