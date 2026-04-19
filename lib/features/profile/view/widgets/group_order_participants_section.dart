import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class GroupOrderParticipantsSection extends StatelessWidget {
  final List<String> names;

  const GroupOrderParticipantsSection({super.key, required this.names});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: names
          .asMap()
          .entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppText.bodyLarge(
                '${entry.key + 1}- ${entry.value}',
                fontWeight: FontWeight.w700,
              ),
            ),
          )
          .toList(),
    );
  }
}
