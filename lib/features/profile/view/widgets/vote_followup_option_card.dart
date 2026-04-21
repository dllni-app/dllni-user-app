import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import 'vote_followup_option_data.dart';

class VoteFollowupOptionCard extends StatelessWidget {
  const VoteFollowupOptionCard({
    super.key,
    required this.option,
    this.onTap,
    this.isSubmitting = false,
    this.isDisabled = false,
    this.isSelected = false,
  });

  final VoteFollowupOptionData option;
  final VoidCallback? onTap;
  final bool isSubmitting;
  final bool isDisabled;
  final bool isSelected;

  static const Color _selectedBorderColor = Color(0xffF97316);
  static const Color _selectedBgColor = Color(0xffFFF7ED);
  static const Color _unselectedBorderColor = Color(0xffE5E7EB);

  @override
  Widget build(BuildContext context) {
    final canTap = onTap != null && !isDisabled;
    return InkWell(
      onTap: canTap ? onTap : null,
      borderRadius: BorderRadius.circular(18),
      child: Opacity(
        opacity: isDisabled ? 0.6 : 1,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? _selectedBgColor : context.onPrimary,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? _selectedBorderColor : _unselectedBorderColor,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 16),
                child: isSubmitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.primaryContainer,
                        ),
                      )
                    : Icon(
                        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isSelected ? _selectedBorderColor : const Color(0xffD1D5DB),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: const Color(0xffF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.local_pizza_outlined,
                            color: Color(0xffD97706),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText.bodyLarge(
                                option.name,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xff1F2937),
                              ),
                              AppText.bodySmall(
                                'الحجم: ${option.size}',
                                color: const Color(0xff6B7280),
                              ),
                              AppText.bodySmall(
                                'السعر: ${option.price}',
                                color: const Color(0xff6B7280),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        AppText.labelLarge(
                          '(${option.votes})',
                          color: const Color(0xff6B7280),
                          fontWeight: FontWeight.w700,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: option.progress,
                              minHeight: 8,
                              backgroundColor: const Color(0xffFDEDD8),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                context.primaryContainer,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        AppText.labelLarge(
                          '${(option.progress * 100).toInt()}%',
                          color: context.primaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ],
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
