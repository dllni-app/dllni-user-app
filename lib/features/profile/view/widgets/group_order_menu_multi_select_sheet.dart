import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../data/models/group_order_api_models.dart';

class GroupOrderMenuMultiSelectSheet {
  static Future<List<GroupOrderMenuSectionItemModel>?> show(
    BuildContext context, {
    required List<GroupOrderMenuSectionItemModel> products,
    required Set<int> selectedIds,
  }) {
    return showModalBottomSheet<List<GroupOrderMenuSectionItemModel>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.onPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText.titleMedium(
                      'خيارات التصويت',
                      color: context.primary,
                      fontWeight: FontWeight.w700,
                    ),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.sizeOf(context).height * 0.52,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final id = product.id ?? -1;
                          final checked = selectedIds.contains(id);
                          return CheckboxListTile(
                            value: checked,
                            onChanged: (value) {
                              setModalState(() {
                                if (value == true) {
                                  selectedIds.add(id);
                                } else {
                                  selectedIds.remove(id);
                                }
                              });
                            },
                            title: AppText.bodyMedium(
                              product.name.isEmpty ? '-' : product.name,
                            ),
                            subtitle: AppText.bodySmall(product.sectionName),
                            secondary: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: AppImage.network(
                                product.primaryImageUrl ?? '',
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemCount: products.length,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final picked = products
                              .where((e) => selectedIds.contains(e.id))
                              .toList();
                          Navigator.of(context).pop(picked);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primary,
                        ),
                        child: AppText.bodyMedium(
                          'التأكيد والإضافة إلى السلة',
                          color: context.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
