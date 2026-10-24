import 'package:flutter/material.dart';
import '../../../../core/themes/shared_platform_colors.dart';
import '../../../../core/themes/v7_artwork.dart';
import '../../data/models/cleaning_orders_api_models.dart';
import 'v7_order_detail_components.dart';

class CleaningAcceptedWorkersSectionWidget extends StatelessWidget {
  const CleaningAcceptedWorkersSectionWidget({
    super.key,
    required this.assignments,
    this.onCallWorker,
  });
  final List<CleaningWorkerAssignmentModel> assignments;
  final ValueChanged<String?>? onCallWorker;

  @override
  Widget build(BuildContext context) {
    if (assignments.isEmpty) return const SizedBox.shrink();
    return V7OrderPanel(
      title: 'فريق الخدمة',
      subtitle: 'العمال الذين قبلوا طلبك.',
      child: Column(
        children: [
          for (var i = 0; i < assignments.length; i++) ...[
            if (i > 0) const Divider(height: 20, color: Color(0xFFE7EBF0)),
            _AcceptedWorkerRow(
              assignment: assignments[i],
              onCallWorker: onCallWorker,
            ),
          ],
        ],
      ),
    );
  }
}

class _AcceptedWorkerRow extends StatelessWidget {
  const _AcceptedWorkerRow({required this.assignment, this.onCallWorker});
  final CleaningWorkerAssignmentModel assignment;
  final ValueChanged<String?>? onCallWorker;
  @override
  Widget build(BuildContext context) {
    final worker = assignment.worker;
    final name = (worker?.name ?? '').trim();
    final image = (worker?.avatarUrl ?? '').trim();
    final phone = (worker?.phone ?? '').trim();
    final rating = worker?.averageRating;
    final count = assignment.roomCount ?? 0;
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: image.isNotEmpty
              ? Image.network(
                  image,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      Image.asset(V7Artwork.worker, width: 48, height: 48),
                )
              : Image.asset(V7Artwork.worker, width: 48, height: 48),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isEmpty ? 'مقدم الخدمة' : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: SharedPlatformColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (rating != null || count > 0) ...[
                const SizedBox(height: 4),
                Text(
                  [
                    if (rating != null) 'التقييم ${rating.toStringAsFixed(1)}',
                    if (count > 0) '$count غرف',
                  ].join(' • '),
                  style: const TextStyle(
                    fontSize: 12,
                    color: SharedPlatformColors.muted,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (phone.isNotEmpty && onCallWorker != null)
          IconButton(
            onPressed: () => onCallWorker!(phone),
            icon: const Icon(
              Icons.call_outlined,
              size: 21,
              color: SharedPlatformColors.primary,
            ),
            tooltip: 'الاتصال بمقدم الخدمة',
          ),
      ],
    );
  }
}
