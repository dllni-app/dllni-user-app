import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../data/models/cleaning_services_response_model.dart';
import 'cl_service_section_card_widget.dart';

class ClCleaningServicesSelectorWidget extends StatelessWidget {
  const ClCleaningServicesSelectorWidget({
    required this.availableServices,
    required this.selectedServiceNames,
    required this.customServiceController,
    required this.onToggleService,
    required this.onAddCustomService,
    required this.onRemoveService,
    required this.onRetry,
    this.isLoading = false,
    this.errorMessage,
    super.key,
  });

  final List<CleaningServiceModel> availableServices;
  final Set<String> selectedServiceNames;
  final TextEditingController customServiceController;
  final ValueChanged<String> onToggleService;
  final VoidCallback onAddCustomService;
  final ValueChanged<String> onRemoveService;
  final VoidCallback onRetry;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return ClServiceSectionCardWidget(
      step: 0,
      showStepBadge: false,
      title: 'الخدمات المطلوبة',
      subtitle: 'اختر الخدمات من القائمة أو أضف خدمة أخرى يدوياً',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isLoading) ...[
            const SizedBox(
              height: 48,
              child: Center(child: CircularProgressIndicator()),
            ),
          ] else if (errorMessage != null) ...[
            Text(
              errorMessage!,
              textAlign: TextAlign.start,
              style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ),
          ] else if (availableServices.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableServices.map((service) {
                final name = service.name?.trim() ?? '';
                if (name.isEmpty) return const SizedBox.shrink();
                final selected = selectedServiceNames.contains(name);
                return FilterChip(
                  label: Text(name),
                  selected: selected,
                  onSelected: (_) => onToggleService(name),
                  selectedColor: const Color(0xFFE2F5F4),
                  checkmarkColor: const Color(0xFF0CBBC7),
                  side: BorderSide(
                    color: selected
                        ? const Color(0xFF0CBBC7)
                        : const Color(0xFFE5E7EB),
                  ),
                );
              }).toList(growable: false),
            ),
          ] else ...[
            const Text(
              'لا توجد خدمات مفعلة حالياً. يمكنك إضافة الخدمات المطلوبة يدوياً.',
              textAlign: TextAlign.start,
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: customServiceController,
                  maxLength: 255,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => onAddCustomService(),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'اكتب خدمة أخرى',
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF0CBBC7)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: onAddCustomService,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1E2A78),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 15,
                  ),
                ),
                child: const Text('إضافة'),
              ),
            ],
          ),
          if (selectedServiceNames.isNotEmpty) ...[
            const SizedBox(height: 12),
            AppText.bodySmall(
              'الخدمات المختارة',
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w700,
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedServiceNames.map((name) {
                return InputChip(
                  label: Text(name),
                  onDeleted: () => onRemoveService(name),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  backgroundColor: const Color(0xFFF3F4F6),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                );
              }).toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}
