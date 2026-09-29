import 'package:flutter/material.dart';

import '../../../rs_discover/view/widgets/product_recommendations_section.dart';

class SupermarketProductCustomizationSection extends StatelessWidget {
  const SupermarketProductCustomizationSection({
    super.key,
    required this.groups,
    required this.selectedIds,
    required this.onModifierChanged,
    required this.noteController,
    required this.alternatives,
    required this.substituteProductId,
    required this.onSubstituteChanged,
  });

  final List<dynamic> groups;
  final Set<int> selectedIds;
  final void Function(int id, bool selected) onModifierChanged;
  final TextEditingController noteController;
  final List<ProductRecommendationItem> alternatives;
  final int? substituteProductId;
  final ValueChanged<int?> onSubstituteChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...groups.whereType<Map>().map((raw) {
            final group = Map<String, dynamic>.from(raw);
            final name = group['name']?.toString() ?? 'خيارات';
            final requiredGroup = group['isRequired'] == true;
            final minSelections =
                int.tryParse((group['minSelections'] ?? 0).toString()) ?? 0;
            final maxSelections =
                int.tryParse((group['maxSelections'] ?? 0).toString()) ?? 0;
            final effectiveMin = requiredGroup
                ? minSelections.clamp(1, 999)
                : minSelections;
            final modifiers = group['modifiers'] is List
                ? (group['modifiers'] as List).whereType<Map>().toList()
                : const <Map>[];
            final groupIds = modifiers
                .map(
                  (modifier) => int.tryParse((modifier['id'] ?? '').toString()),
                )
                .whereType<int>()
                .toSet();
            final selectedInGroup = selectedIds.intersection(groupIds);
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      requiredGroup ? name + ' *' : name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    ...modifiers.map((rawModifier) {
                      final modifier = Map<String, dynamic>.from(rawModifier);
                      final id = int.tryParse(
                        (modifier['id'] ?? '').toString(),
                      );
                      if (id == null) return const SizedBox.shrink();
                      final price =
                          num.tryParse((modifier['price'] ?? 0).toString()) ??
                          0;
                      final isSelected = selectedIds.contains(id);
                      final atMax =
                          maxSelections > 0 &&
                          selectedInGroup.length >= maxSelections;
                      final cannotDeselect =
                          isSelected &&
                          effectiveMin > 0 &&
                          selectedInGroup.length <= effectiveMin;
                      return CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        value: isSelected,
                        title: Text(modifier['name']?.toString() ?? ''),
                        subtitle: price > 0
                            ? Text('+' + price.toStringAsFixed(0) + ' ل.س')
                            : null,
                        onChanged: cannotDeselect || (!isSelected && atMax)
                            ? null
                            : (value) {
                                if (value == true && maxSelections == 1) {
                                  for (final selectedId in selectedInGroup) {
                                    if (selectedId != id) {
                                      onModifierChanged(selectedId, false);
                                    }
                                  }
                                }
                                onModifierChanged(id, value == true);
                              },
                      );
                    }),
                  ],
                ),
              ),
            );
          }),
          TextField(
            controller: noteController,
            maxLength: 1000,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'ملاحظة على المنتج (اختياري)',
              hintText: 'مثال: اختر عبوة بتاريخ صلاحية أبعد',
              border: OutlineInputBorder(),
            ),
          ),
          if (alternatives.isNotEmpty) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<int?>(
              value: substituteProductId,
              decoration: const InputDecoration(
                labelText: 'بديل في حال عدم التوفر (اختياري)',
                border: OutlineInputBorder(),
              ),
              items: <DropdownMenuItem<int?>>[
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('بدون بديل'),
                ),
                ...alternatives.map(
                  (item) => DropdownMenuItem<int?>(
                    value: item.id,
                    child: Text(item.name),
                  ),
                ),
              ],
              onChanged: onSubstituteChanged,
            ),
          ],
        ],
      ),
    );
  }
}
