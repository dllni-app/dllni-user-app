import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../data/models/group_order_api_models.dart';
import 'group_order_selected_products_formatter.dart';

class GroupOrderCreatorSubmitSheet extends StatelessWidget {
  final GroupOrderDetailsModel details;
  final bool isPlacing;
  final Set<int> syncingProductIds;
  final Future<void> Function(
    GroupOrderParticipantModel participant,
    GroupOrderItemModel item,
  )
  onDeleteItem;
  final VoidCallback onSubmit;

  const GroupOrderCreatorSubmitSheet({
    super.key,
    required this.details,
    required this.isPlacing,
    required this.syncingProductIds,
    required this.onDeleteItem,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final participantsWithItems = details.participants
        .where((participant) => participant.items.isNotEmpty)
        .toList(growable: false);
    final hasItems = participantsWithItems.isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText.titleMedium(
              'الأطعمة المختارة',
              color: context.primary,
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.56,
              ),
              child: !hasItems
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: AppText.bodyMedium(
                          'لا توجد عناصر مختارة بعد',
                          color: const Color(0xff6B7280),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: participantsWithItems.length,
                      itemBuilder: (context, index) {
                        final participant = participantsWithItems[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText.titleSmall(
                                '${index + 1}- ${participant.name ?? '-'}',
                                fontWeight: FontWeight.w700,
                              ),
                              const SizedBox(height: 8),
                              AppText.bodyMedium(
                                GroupOrderSelectedProductsFormatter.formatFromItems(
                                  participant.items,
                                ),
                                color: const Color(0xff4B5563),
                              ),
                              const SizedBox(height: 8),
                              ...participant.items.map((item) {
                                final pid = item.productId;
                                final isSyncing =
                                    pid != null &&
                                    syncingProductIds.contains(pid);
                                final canDelete =
                                    item.itemId != null &&
                                    !isSyncing &&
                                    !isPlacing;
                                final quantity = item.quantity <= 0
                                    ? 1
                                    : item.quantity;
                                final itemName =
                                    (item.name ?? '').trim().isEmpty
                                    ? '-'
                                    : item.name!.trim();
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: AppText.bodySmall(
                                          '$quantity× $itemName',
                                          color: const Color(0xff6B7280),
                                        ),
                                      ),
                                      if (isSyncing)
                                        const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      else if (canDelete)
                                        IconButton(
                                          onPressed: () =>
                                              onDeleteItem(participant, item),
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Color(0xffEF4444),
                                            size: 20,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isPlacing || !hasItems ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primary,
                ),
                child: isPlacing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : AppText.bodyMedium(
                        'تأكيد وإضافة إلى السلة',
                        color: context.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
