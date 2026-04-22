import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import 'group_order_food_card.dart';
import 'group_order_food_row.dart';

class GroupOrderOptionsSection extends StatefulWidget {
  final List<GroupOrderFoodRow> foods;
  final List<String> availableTypes;
  final VoidCallback? onAddMultiTap;
  final void Function(GroupOrderFoodRow row)? onMenuProductTap;

  const GroupOrderOptionsSection({
    super.key,
    required this.foods,
    required this.availableTypes,
    this.onAddMultiTap,
    this.onMenuProductTap,
  });

  @override
  State<GroupOrderOptionsSection> createState() => _GroupOrderOptionsSectionState();
}

class _GroupOrderOptionsSectionState extends State<GroupOrderOptionsSection> {
  final Set<String> _expandedTypes = <String>{};
  bool _didApplyDefaultExpansion = false;

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

  void _applyDefaultExpansionOnce() {
    if (!mounted || _didApplyDefaultExpansion) return;
    final types = _orderedTypes();
    if (types.isEmpty) return;
    setState(() {
      _expandedTypes.add(types.first);
      _didApplyDefaultExpansion = true;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyDefaultExpansionOnce());
  }

  @override
  void didUpdateWidget(GroupOrderOptionsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyDefaultExpansionOnce());
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

    if (widget.foods.isEmpty && types.isEmpty) {
      return AppText.bodyMedium('لا توجد منتجات في القائمة', color: const Color(0xff6B7280));
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
                      Expanded(
                        child: AppText.titleSmall(type, fontWeight: FontWeight.w700, textAlign: TextAlign.start),
                      ),
                      Icon(expanded ? Icons.expand_less : Icons.expand_more, color: const Color(0xff9CA3AF)),
                    ],
                  ),
                ),
                if (expanded) ...[
                  const SizedBox(height: 8),
                  if (rows.isEmpty)
                    AppText.bodySmall('لا توجد منتجات ضمن هذا القسم', color: const Color(0xff9CA3AF))
                  else
                    SizedBox(
                      height: 175,
                      child: ListView.separated(
                        itemBuilder: (context, index) {
                          final row = rows[index];
                          final pid = row.productId;
                          final isMenuRow = row.itemId == null && pid != null && pid > 0;
                          return GroupOrderFoodCard(
                            row: row,
                            onTap: widget.onMenuProductTap != null && isMenuRow ? () => widget.onMenuProductTap!(row) : null,
                          );
                        },
                        separatorBuilder: (context, index) => SizedBox(width: 10),
                        itemCount: rows.length,
                        scrollDirection: Axis.horizontal,
                      ),
                    ),
                ],
              ],
            ),
          );
        }),
        if (widget.onAddMultiTap != null) ...[
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
