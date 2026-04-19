import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import 'group_order_food_card.dart';
import 'group_order_food_row.dart';

class GroupOrderOptionsSection extends StatefulWidget {
  final List<GroupOrderFoodRow> foods;
  final List<String> availableTypes;
  final bool isCreator;
  final VoidCallback? onAddMultiTap;

  const GroupOrderOptionsSection({super.key, required this.foods, required this.availableTypes, required this.isCreator, this.onAddMultiTap});

  @override
  State<GroupOrderOptionsSection> createState() => _GroupOrderOptionsSectionState();
}

class _GroupOrderOptionsSectionState extends State<GroupOrderOptionsSection> {
  final Set<String> _expandedTypes = <String>{};

  String _sanitizeType(String? value) {
    final type = (value ?? '').trim();
    return type.isEmpty ? 'غير مصنف' : type;
  }

  List<String> _orderedTypes() {
    final types = <String>[...widget.availableTypes.map(_sanitizeType), ...widget.foods.map((e) => _sanitizeType(e.type))];
    final seen = <String>{};
    final ordered = <String>[];
    for (final type in types) {
      if (seen.add(type)) {
        ordered.add(type);
      }
    }
    return ordered;
  }

  @override
  Widget build(BuildContext context) {
    final types = _orderedTypes();
    final grouped = <String, List<GroupOrderFoodRow>>{};
    for (final type in types) {
      grouped[type] = <GroupOrderFoodRow>[];
    }
    for (final row in widget.foods) {
      final type = _sanitizeType(row.type);
      grouped.putIfAbsent(type, () => <GroupOrderFoodRow>[]);
      grouped[type]!.add(row);
    }

    if (_expandedTypes.isEmpty && types.isNotEmpty) {
      _expandedTypes.add(types.first);
    }

    if (widget.foods.isEmpty && types.isEmpty) {
      return AppText.bodyMedium('لا توجد خيارات مضافة حتى الآن', color: const Color(0xff6B7280));
    }

    return Column(
      children: [
        ...types.map((type) {
          final rows = grouped[type] ?? const <GroupOrderFoodRow>[];
          final expanded = _expandedTypes.contains(type);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xffFFFFFF),
              border: Border.all(color: const Color(0xffECEFF3)),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      if (expanded) {
                        _expandedTypes.remove(type);
                      } else {
                        _expandedTypes.add(type);
                      }
                    });
                  },
                  child: Row(
                    children: [
                      Expanded(child: AppText.titleSmall(type, fontWeight: FontWeight.w700)),
                      Icon(expanded ? Icons.expand_less : Icons.expand_more, color: const Color(0xff9CA3AF)),
                    ],
                  ),
                ),
                if (expanded) ...[
                  const SizedBox(height: 8),
                  if (rows.isEmpty)
                    AppText.bodySmall('لا توجد خيارات ضمن هذا النوع', color: const Color(0xff9CA3AF))
                  else
                    ...rows.map(
                      (row) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GroupOrderFoodCard(row: row),
                      ),
                    ),
                ],
              ],
            ),
          );
        }),
        if (!widget.isCreator) ...[
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onAddMultiTap,
              style: ElevatedButton.styleFrom(backgroundColor: context.primary),
              child: AppText.bodyMedium('إضافة خيارات متعددة', color: context.onPrimary, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ],
    );
  }
}