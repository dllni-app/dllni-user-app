import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../data/cl_worker_profile_route_args.dart';
import '../widgets/cl_redesign_components.dart';

@AutoRoutePage()
class ClWorkerReviewsAllScreen extends StatelessWidget {
  const ClWorkerReviewsAllScreen({super.key, required this.args});

  final WorkerProfileRouteArgs args;

  double? get _averageRating =>
      args.worker?.ratings?.average ?? args.worker?.rating;

  int? get _ratingsCount => args.worker?.ratings?.count;

  String get _workerName {
    final name = args.worker?.name?.trim();
    return name == null || name.isEmpty ? 'مقدم الخدمة' : name;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.white,
          centerTitle: false,
          title: const Text(
            'تقييمات العملاء',
            style: TextStyle(
              color: Color(0xFF172033),
              fontWeight: FontWeight.w900,
            ),
          ),
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_forward, color: Color(0xFF1E2A78)),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            ClRedesignCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _workerName,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      color: Color(0xFF172033),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFB020),
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _averageRating == null
                            ? '—'
                            : _averageRating!.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Color(0xFF172033),
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _ratingsCount != null && _ratingsCount! > 0
                            ? '${_ratingsCount!} تقييم'
                            : 'عدد التقييمات غير متاح',
                        style: const TextStyle(
                          color: Color(0xFF667085),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ClRedesignCard(
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9F9FA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.rate_review_outlined,
                      color: Color(0xFF0F8E98),
                      size: 27,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'تفاصيل المراجعات غير متاحة حالياً',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF172033),
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'تتوفر بيانات التقييم الإجمالي فقط في استجابة مقدم الخدمة الحالية، لذلك لا نعرض مراجعات تجريبية أو معلومات غير قادمة من الخادم.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF667085), height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
