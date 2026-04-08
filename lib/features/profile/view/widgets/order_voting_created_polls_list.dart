import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import 'order_voting_created_poll_item.dart';

class OrderVotingCreatedPollsList extends StatelessWidget {
  const OrderVotingCreatedPollsList({
    super.key,
    required this.items,
    required this.onPollTap,
  });

  final List<OrderVotingCreatedPollItem> items;
  final void Function(OrderVotingCreatedPollItem item) onPollTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText.titleMedium(
          'المقارنات القائمة',
          color: const Color(0xff374151),
          fontWeight: FontWeight.w700,
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 10),
            child: Material(
              color: context.onPrimary,
              elevation: 2,
              shadowColor: Colors.black.withAlpha(18),
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: () => onPollTap(item),
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 12, 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: context.primaryContainer.withAlpha(40),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.how_to_vote_outlined,
                          color: context.primaryContainer,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText.bodyMedium(
                              item.title,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xff1F2937),
                            ),
                            const SizedBox(height: 4),
                            AppText.labelLarge(
                              item.detail,
                              color: const Color(0xff6B7280),
                              fontWeight: FontWeight.w400,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: context.primary),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
