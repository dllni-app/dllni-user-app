import '../../../../core/themes/shared_platform_colors.dart';
import 'package:flutter/material.dart';
import '../../data/models/cleaning_services_response_model.dart';
import '../../../../core/models/cleaning_service_extras.dart';
import 'cl_redesign_components.dart';

IconData _iconForSpecialService(String rawName) {
  final name = rawName.trim().toLowerCase();
  if (name.contains('زجاج') || name.contains('نافذ') || name.contains('شباك')) {
    return Icons.window_outlined;
  }
  if (name.contains('أرض') ||
      name.contains('بلاط') ||
      name.contains('سيراميك')) {
    return Icons.grid_on_outlined;
  }
  if (name.contains('سجاد') || name.contains('موكيت')) {
    return Icons.layers_outlined;
  }
  if (name.contains('كنب') ||
      name.contains('أريكة') ||
      name.contains('مفروش')) {
    return Icons.weekend_outlined;
  }
  if (name.contains('مطبخ') || name.contains('دهون') || name.contains('فرن')) {
    return Icons.kitchen_outlined;
  }
  if (name.contains('حمام') || name.contains('تعقيم')) {
    return Icons.bathtub_outlined;
  }
  if (name.contains('ستار')) return Icons.curtains_outlined;
  return Icons.auto_awesome_outlined;
}

/// Selection is only from the server catalog. Editing quantity, item details,
/// dirtiness and schedule is handled by the detailed form below this selector.
class ClSpecialServicesStepWidget extends StatelessWidget {
  const ClSpecialServicesStepWidget({
    super.key,
    required this.catalog,
    required this.selectedIds,
    required this.onToggle,
    required this.isLoading,
    required this.editor,
    this.selectedServices,
    this.onServiceChanged,
  });
  final List<CleaningServiceModel> catalog;
  final Set<int> selectedIds;
  final ValueChanged<int> onToggle;
  final bool isLoading;
  final Widget editor;
  final List<CleaningSpecialServiceRequest>? selectedServices;
  final ValueChanged<CleaningSpecialServiceRequest>? onServiceChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              color: SharedPlatformColors.primary,
            ),
            SizedBox(width: 9),
            Expanded(
              child: Text(
                'الخدمات المتخصصة',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
      if (isLoading) const LinearProgressIndicator(),
      if (catalog.isEmpty && !isLoading)
        const ClRedesignCard(
          child: Text(
            'لا تتوفر خدمات متخصصة حالياً. يمكنك المتابعة دون إضافتها.',
          ),
        ),
      for (final service in catalog.where((s) => s.id != null))
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: selectedIds.contains(service.id)
                ? const Color(0xFFEDF3FF)
                : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: selectedIds.contains(service.id)
                    ? SharedPlatformColors.primary
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              children: [
                InkWell(
                  key: Key('special_catalog_${service.id}'),
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onToggle(service.id!),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDF3FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _iconForSpecialService(service.name ?? ''),
                            color: SharedPlatformColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.name ?? 'خدمة متخصصة',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if ((service.description ?? '').trim().isNotEmpty)
                                Text(
                                  service.description!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Icon(
                          selectedIds.contains(service.id)
                              ? Icons.check_circle
                              : Icons.add_circle_outline,
                          color: SharedPlatformColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                if (selectedIds.contains(service.id) &&
                    selectedServices != null &&
                    onServiceChanged != null)
                  for (final chosen in selectedServices!.where(
                    (selected) => selected.specialServiceId == service.id,
                  ))
                    Padding(
                      key: Key('special_config_${service.id}'),
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        14,
                        0,
                        14,
                        12,
                      ),
                      child: _CompactSelectedService(
                        catalog: service,
                        selected: chosen,
                        onChanged: onServiceChanged!,
                      ),
                    ),
              ],
            ),
          ),
        ),
      if (selectedIds.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'لم تختر أي خدمة متخصصة. يمكنك المتابعة مباشرة.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ),
      if (selectedIds.isNotEmpty && selectedServices == null) ...[
        const SizedBox(height: 8),
        const Text(
          'تخصيص الخدمات المحددة',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        editor,
      ],
    ],
  );
}

/// Show only the controls that change the actual booking request.
/// The backend remains authoritative for pricing and active dirtiness rules.
class _CompactSelectedService extends StatelessWidget {
  const _CompactSelectedService({
    required this.catalog,
    required this.selected,
    required this.onChanged,
  });

  final CleaningServiceModel catalog;
  final CleaningSpecialServiceRequest selected;
  final ValueChanged<CleaningSpecialServiceRequest> onChanged;

  @override
  Widget build(BuildContext context) {
    final allRules = catalog.dirtinessRules
        .where((rule) => rule.id != null && rule.isActive != false)
        .toList(growable: false);
    final basic =
        allRules
            .where(
              (r) =>
                  r.level == 'low' ||
                  r.level == 'light' ||
                  r.level == 'medium' ||
                  r.level == 'normal',
            )
            .firstOrNull ??
        allRules.firstOrNull;
    final strong =
        allRules
            .where(
              (r) =>
                  r.level == 'high' ||
                  r.level == 'heavy' ||
                  r.level == 'very_high',
            )
            .lastOrNull ??
        (allRules.length > 1 ? allRules.last : null);
    final firstItem =
        selected.items.firstOrNull ??
        CleaningSpecialServiceItemRequest(
          quantity: selected.quantity.toDouble(),
          dirtinessLevelId: basic?.id,
        );
    final currentQuantity = selected.items.isEmpty
        ? selected.quantity.toDouble()
        : selected.items.fold<double>(0, (a, b) => a + b.quantity);

    void updateQuantity(double quantity) {
      if (quantity <= 0 || quantity > 50) return;
      onChanged(
        selected.copyWith(
          quantity: quantity.ceil(),
          items: <CleaningSpecialServiceItemRequest>[
            firstItem.copyWith(quantity: quantity),
          ],
        ),
      );
    }

    void updateDirtiness(CleaningServiceDirtinessRuleModel rule) {
      onChanged(
        selected.copyWith(
          dirtinessLevel: rule.level ?? selected.dirtinessLevel,
          items: selected.items.isEmpty
              ? [firstItem.copyWith(dirtinessLevelId: rule.id)]
              : [
                  for (final item in selected.items)
                    item.copyWith(dirtinessLevelId: rule.id),
                ],
        ),
      );
    }

    final hasSeverity =
        catalog.supportsDirtiness &&
        basic != null &&
        strong != null &&
        basic.id != strong.id;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 16, color: Color(0xFFE2E8F0)),
        Row(
          children: [
            const Expanded(
              child: Text(
                'الكمية',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              key: Key('special_decrease_${catalog.id}'),
              onPressed: currentQuantity > 1
                  ? () => updateQuantity(currentQuantity - 1)
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
              tooltip: 'تقليل الكمية',
            ),
            SizedBox(
              width: 48,
              child: Text(
                currentQuantity == currentQuantity.roundToDouble()
                    ? currentQuantity.toStringAsFixed(0)
                    : currentQuantity.toStringAsFixed(1),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
            IconButton(
              key: Key('special_increase_${catalog.id}'),
              onPressed: currentQuantity < 50
                  ? () => updateQuantity(currentQuantity + 1)
                  : null,
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'زيادة الكمية',
            ),
          ],
        ),
        if (hasSeverity) ...[
          const SizedBox(height: 6),
          const Text(
            'مستوى الاتساخ',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _DirtOption(
                  key: Key('special_light_${catalog.id}'),
                  label: 'اتساخ بسيط',
                  selected: selected.items.isNotEmpty
                      ? selected.items.first.dirtinessLevelId != strong.id
                      : selected.dirtinessLevel != strong.level,
                  onTap: () => updateDirtiness(basic),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DirtOption(
                  key: Key('special_heavy_${catalog.id}'),
                  label: 'اتساخ شديد',
                  selected: selected.items.isNotEmpty
                      ? selected.items.first.dirtinessLevelId == strong.id
                      : selected.dirtinessLevel == strong.level,
                  onTap: () => updateDirtiness(strong),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _DirtOption extends StatelessWidget {
  const _DirtOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? const Color(0xFFEDF3FF) : Colors.white,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        alignment: Alignment.center,
        constraints: const BoxConstraints(minHeight: 46),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? SharedPlatformColors.primary
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            color: selected
                ? SharedPlatformColors.primary
                : const Color(0xFF334155),
          ),
        ),
      ),
    ),
  );
}
