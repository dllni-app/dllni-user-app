import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class VoteFollowupVotersList extends StatelessWidget {
  const VoteFollowupVotersList({super.key, required this.voterNames});

  final List<String> voterNames;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: voterNames.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final name = entry.value;
        return Padding(
          padding: const EdgeInsetsDirectional.only(bottom: 6),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppText.bodyMedium(
              '$index- $name',
              color: const Color(0xff374151),
            ),
          ),
        );
      }).toList(),
    );
  }
}
