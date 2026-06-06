import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class ClCleaningTypeOptionCardWidget extends StatelessWidget {
  const ClCleaningTypeOptionCardWidget({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0CBBC7)
                  : const Color(0xFFE5E7EB),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected
                    ? const Color(0xFF0CBBC7)
                    : const Color(0xFF9CA3AF),
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bodyMedium(
                      title,
                      fontWeight: FontWeight.w700,
                      textAlign: TextAlign.start,
                      color: const Color(0xFF242424),
                    ),
                    const SizedBox(height: 4),
                    AppText.labelLarge(
                      subtitle,
                      textAlign: TextAlign.start,
                      color: const Color(0xFF8A8A8A),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
