import 'package:flutter/material.dart';
import '../../../../core/models/cleaning_gender_preference.dart';
import '../../../../core/themes/shared_platform_colors.dart';
import 'cl_service_section_card_widget.dart';

/// V7 single-choice rows. The original preference enum and callbacks remain.
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
    subtitle: 'اختر ما يناسبك.',
    step: step,
    showStepBadge: showStepBadge,
    child: Column(
      children: [
        for (final preference in const [
          CleaningGenderPreference.male,
          CleaningGenderPreference.female,
        ]) ...[
          Semantics(
            button: true,
            selected: selectedPreference == preference,
            child: InkWell(
              key: Key('cleaning_gender_pref_' + preference.apiValue),
              onTap: () => onChanged(preference),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                constraints: const BoxConstraints(minHeight: 60),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: selectedPreference == preference
                      ? const Color(0xFFEAF9FA)
                      : const Color(0xFFF9FAFB),
                  border: Border.all(
                    color: selectedPreference == preference
                        ? SharedPlatformColors.cleaning
                        : const Color(0xFFE5E8ED),
                    width: selectedPreference == preference ? 1.6 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      selectedPreference == preference
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: selectedPreference == preference
                          ? const Color(0xFF007D88)
                          : SharedPlatformColors.muted,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        preference.arabicLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          color: SharedPlatformColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (preference == CleaningGenderPreference.male)
            const SizedBox(height: 10),
        ],
      ],
    ),
  );
}
