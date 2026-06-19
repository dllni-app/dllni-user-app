import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../data/models/cleaning_booking_status.dart';
import '../../data/models/cleaning_orders_api_models.dart';

class CleaningTeamSearchBannerWidget extends StatelessWidget {
  const CleaningTeamSearchBannerWidget({
    required this.acceptance,
    required this.numberOfWorkers,
    this.workerOrderStatus,
    this.workerOrderStatusLabel,
    this.requiredWorkersCount,
    this.acceptedWorkersCount,
    this.pendingWorkersCount,
    super.key,
  });

  final CleaningWorkerAcceptanceModel? acceptance;
  final int? numberOfWorkers;
  final String? workerOrderStatus;
  final String? workerOrderStatusLabel;
  final int? requiredWorkersCount;
  final int? acceptedWorkersCount;
  final int? pendingWorkersCount;

  @override
  Widget build(BuildContext context) {
    final normalizedWorkerStatus = (workerOrderStatus ?? '').trim().toLowerCase();
    final isAcceptedWaitingState =
        normalizedWorkerStatus == CleaningBookingStatus.acceptedWaitingTeam ||
        normalizedWorkerStatus ==
            CleaningBookingStatus.acceptedWaitingForOrderStart;
    final required =
        requiredWorkersCount ?? acceptance?.required ?? numberOfWorkers ?? 0;
    final accepted =
        acceptedWorkersCount ?? acceptance?.accepted ?? 0;
    final remaining =
        pendingWorkersCount ?? acceptance?.remaining ?? (required - accepted);
    final title = workerOrderStatusLabel?.trim().isNotEmpty == true
        ? workerOrderStatusLabel!.trim()
        : isAcceptedWaitingState
            ? 'تم قبول الطلب بانتظار اكتمال الفريق'
            : 'جاري البحث عن عمال';
    final message = isAcceptedWaitingState
        ? (remaining > 0
            ? 'تم قبول $accepted عامل من أصل $required. بانتظار $remaining عامل إضافي.'
            : 'تم قبول الطلب. بانتظار تحديث الحالة من النظام.')
        : (remaining > 0
            ? 'تم قبول $accepted عامل. بانتظار $remaining عامل إضافي.'
            : 'يتم تجميع الفريق المطلوب للخدمة.');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E2A78), Color(0xFF0CBBC7)],
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.groups_outlined, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: AppText.bodyMedium(
                  title,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (required > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: AppText.bodySmall(
                    '$accepted / $required',
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AppText.bodySmall(
            message,
            color: Colors.white.withValues(alpha: 0.92),
            textAlign: TextAlign.right,
          ),
          if (required > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: required > 0 ? (accepted / required).clamp(0.0, 1.0) : 0,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
