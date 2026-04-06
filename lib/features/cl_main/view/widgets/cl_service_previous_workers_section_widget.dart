import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../data/cl_worker_profile_mock_data.dart';

class ClServicePreviousWorkersSectionWidget extends StatelessWidget {
  const ClServicePreviousWorkersSectionWidget({super.key});

  static const _workers = <({String id, String name, Color bgColor})>[
    (id: 'aysar_mohamed', name: 'أيسار محمد', bgColor: Color(0xFFF4D9E2)),
    (id: 'bana_salama', name: 'بنى سلامة', bgColor: Color(0xFFD8F3F2)),
    (id: 'mohamed_ahmed', name: 'محمد أحمد', bgColor: Color(0xFFD4EDEA)),
    (id: 'maher_ahmed', name: 'ماهر أحمد', bgColor: Color(0xFFF6E8DE)),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bodyMedium(
            'هل تفضل العمل مجدداً مع عماليين قد تعاملت معهم مسبقاً ؟',
            color: const Color(0xFF111827),
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _workers
                .map(
                  (worker) => Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        context.pushRoute(
                          '/clworkerprofiledetail',
                          arguments: WorkerProfileRouteArgs(workerId: worker.id),
                        );
                      },
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: worker.bgColor,
                            child: const Icon(Icons.person, size: 24, color: Color(0xFF4B5563)),
                          ),
                          const SizedBox(height: 6),
                          AppText.bodySmall(
                            worker.name,
                            color: const Color(0xFF111827),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
