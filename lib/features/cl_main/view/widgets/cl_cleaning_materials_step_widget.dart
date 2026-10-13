import 'package:flutter/material.dart';
import '../../../../core/models/cleaning_service_extras.dart';
import '../../../../core/themes/shared_platform_colors.dart';
import 'cl_redesign_components.dart';

/// Material needs are resolved by the backend; catalog groups are explicit
/// category keys, not guesses based on a product name or unit.
class ClCleaningMaterialsStepWidget extends StatelessWidget {
  const ClCleaningMaterialsStepWidget({
    super.key,
    required this.customerProvides,
    required this.requiredMaterials,
    required this.missingTypeIds,
    required this.onCustomerProvidesChanged,
    required this.onMissingChanged,
    required this.isLoading,
    required this.onRetry,
  });

  final bool customerProvides;
  final List<CleaningMaterialLineModel> requiredMaterials;
  final Set<int> missingTypeIds;
  final ValueChanged<bool> onCustomerProvidesChanged;
  final ValueChanged<Set<int>> onMissingChanged;
  final bool isLoading;
  final VoidCallback onRetry;

  static const _titles = <String, String>{
    'cleaners': 'منظفات الأسطح',
    'disinfectants': 'مواد التعقيم',
    'supplies': 'أدوات ومستلزمات',
    'other': 'مواد متنوعة',
  };
  static const _icons = <String, IconData>{
    'cleaners': Icons.cleaning_services_outlined,
    'disinfectants': Icons.health_and_safety_outlined,
    'supplies': Icons.inventory_2_outlined,
    'other': Icons.category_outlined,
  };

  String _quantityLabel(CleaningMaterialLineModel material) {
    final quantity = material.quantity;
    if (quantity == null) return 'الكمية تُحدّد عند التسعير';
    var unit = material.unitLabel?.trim() ?? '';
    if (unit.isEmpty || !RegExp(r'[\u0600-\u06FF]').hasMatch(unit)) {
      unit = switch (material.unit?.trim().toLowerCase()) {
        'liter' || 'l' => 'لتر',
        'piece' || 'pcs' => 'قطعة',
        'pack' || 'package' => 'رزمة',
        'bottle' => 'عبوة',
        _ => 'وحدة',
      };
    }
    final code = material.unit?.trim().toLowerCase() ?? '';
    final pieces = quantity.round();
    if (code == 'pack' || code == 'package' || code == 'bottle') {
      return pieces == 1 ? 'عبوة واحدة' : '$pieces عبوات';
    }
    if (code == 'piece' || code == 'pcs') {
      return pieces == 1 ? 'قطعة واحدة' : '$pieces قطع';
    }
    if (code == 'kg' || code == 'kilogram') {
      if (quantity == 0.25) return 'ربع كيلو';
      if (quantity == 0.5) return 'نصف كيلو';
      if (quantity == 0.75) return 'ثلاثة أرباع كيلو';
    }
    if (code == 'liter' || code == 'l') {
      if (quantity == 0.25) return 'ربع لتر';
      if (quantity == 0.5) return 'نصف لتر';
      if (quantity == 0.75) return 'ثلاثة أرباع لتر';
      if (quantity > 0 && quantity < 1) {
        return '${(quantity * 1000).round()} مل';
      }
    }
    return '${_amount(quantity)} $unit';
  }

  String _amount(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value
        .toStringAsFixed(3)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final selectable = requiredMaterials
        .where((item) => item.materialTypeId != null)
        .toList(growable: false);
    final groups = <String, List<CleaningMaterialLineModel>>{};
    for (final material in selectable) {
      final category = _titles.containsKey(material.categoryKey)
          ? material.categoryKey!
          : 'other';
      (groups[category] ??= []).add(material);
    }
    final orderedKeys = <String>[
      for (final key in _titles.keys)
        if (groups.containsKey(key)) key,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ClRedesignCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                color: SharedPlatformColors.primary,
                size: 28,
              ),
              SizedBox(height: 8),
              Text(
                'مواد التنظيف',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 4),
              Text(
                'اختر مين رح يوفّر المواد. إذا عندك بعضها، حدّد بس اللي ناقصك.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SupplyChoice(
          key: const Key('material_platform_all'),
          selected: !customerProvides,
          title: 'الفريق يوفّر كل المواد',
          subtitle: 'بيجيب الفريق كل المواد المطلوبة للتنظيف.',
          icon: Icons.local_shipping_outlined,
          onTap: () => onCustomerProvidesChanged(false),
        ),
        const SizedBox(height: 8),
        _SupplyChoice(
          key: const Key('material_customer_supplies'),
          selected: customerProvides,
          title: 'عندي مواد التنظيف',
          subtitle: 'علّم على المواد الناقصة حتى نجيبها مع الفريق.',
          icon: Icons.home_outlined,
          onTap: () => onCustomerProvidesChanged(true),
        ),
        const SizedBox(height: 12),
        ClRedesignCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'مواد التنظيف حسب التصنيف',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                customerProvides
                    ? 'افتح التصنيف وحدد اللي ناقصك. إذا ما اخترت شي، يعني كل المواد عندك.'
                    : 'الفريق رح يجيب كل المواد التالية. اضغط على أي تصنيف لتشوف التفاصيل.',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: LinearProgressIndicator(),
                ),
              if (!isLoading && selectable.isEmpty) ...[
                const SizedBox(height: 14),
                const Text(
                  'ما قدرنا نحمّل قائمة المواد المطلوبة. حاول مرة تانية.',
                ),
                TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة تحميل المواد'),
                ),
              ],
              if (customerProvides && selectable.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    TextButton(
                      key: const Key('material_select_all_missing'),
                      onPressed: () => onMissingChanged(
                        selectable.map((e) => e.materialTypeId!).toSet(),
                      ),
                      child: const Text('كل المواد ناقصة'),
                    ),
                    TextButton(
                      key: const Key('material_clear_missing'),
                      onPressed: () => onMissingChanged(<int>{}),
                      child: const Text('كل المواد متوفرة عندي'),
                    ),
                  ],
                ),
              ],
              for (final category in orderedKeys)
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  clipBehavior: Clip.antiAlias,
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Color(0xFFE1E7F0)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    key: PageStorageKey('material_category_$category'),
                    initiallyExpanded: false,
                    leading: Icon(
                      _icons[category],
                      color: SharedPlatformColors.primary,
                    ),
                    title: Text(
                      _titles[category]!,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      '${groups[category]!.length} مواد • '
                      '${groups[category]!.where((m) => missingTypeIds.contains(m.materialTypeId)).length} ناقصة',
                      style: const TextStyle(fontSize: 12),
                    ),
                    children: [
                      for (final material in groups[category]!)
                        CheckboxListTile(
                          key: Key('material_type_${material.materialTypeId}'),
                          value: customerProvides
                              ? missingTypeIds.contains(material.materialTypeId)
                              : true,
                          onChanged: !customerProvides
                              ? null
                              : (checked) {
                                  final selected = {...missingTypeIds};
                                  if (checked == true) {
                                    selected.add(material.materialTypeId!);
                                  } else {
                                    selected.remove(material.materialTypeId);
                                  }
                                  onMissingChanged(selected);
                                },
                          title: Text(material.name ?? 'مادة تنظيف'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الكمية المطلوبة: ${_quantityLabel(material)}',
                              ),
                              if (material.totalPrice != null)
                                Text(
                                  'تكلفة المادة: ${_amount(material.totalPrice!)} ل.س',
                                ),
                            ],
                          ),
                          isThreeLine: material.totalPrice != null,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                    ],
                  ),
                ),
              if (customerProvides && selectable.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    missingTypeIds.isEmpty
                        ? 'تمام! كل المواد متوفرة عندك.'
                        : 'رح يجيب الفريق ${missingTypeIds.length} من المواد الناقصة.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: SharedPlatformColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SupplyChoice extends StatelessWidget {
  const _SupplyChoice({
    super.key,
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
  final bool selected;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: selected ? const Color(0xFFEDF3FF) : Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(
        color: selected
            ? SharedPlatformColors.primary
            : const Color(0xFFE1E7F0),
      ),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: SharedPlatformColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: SharedPlatformColors.primary,
            ),
          ],
        ),
      ),
    ),
  );
}
