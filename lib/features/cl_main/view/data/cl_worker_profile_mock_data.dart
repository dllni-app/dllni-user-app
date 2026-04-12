import 'package:flutter/material.dart';

import '../../data/models/previous_workers_response_model.dart';

class WorkerProfileRouteArgs {
  const WorkerProfileRouteArgs({
    required this.workerId,
    this.worker,
  });

  final String workerId;
  final PreviousWorkerModel? worker;

  factory WorkerProfileRouteArgs.fromPreviousWorker(PreviousWorkerModel worker) {
    return WorkerProfileRouteArgs(
      workerId: worker.id?.toString() ?? '',
      worker: worker,
    );
  }
}

class WorkerReview {
  const WorkerReview({
    required this.reviewerName,
    required this.reviewerAvatarColor,
    required this.rating,
    required this.comment,
    required this.timeAgo,
  });

  final String reviewerName;
  final Color reviewerAvatarColor;
  final int rating;
  final String comment;
  final String timeAgo;
}

class WorkerRatingSummary {
  const WorkerRatingSummary({
    required this.average,
    required this.totalReviews,
    required this.starCounts,
  });

  final double average;
  final int totalReviews;
  final Map<int, int> starCounts;
}

class WorkerProfileData {
  const WorkerProfileData({
    required this.id,
    required this.name,
    required this.verified,
    required this.avatarColor,
    required this.badgeValue,
    required this.completedTasksText,
    required this.aboutText,
    required this.ratingSummary,
    required this.reviews,
  });

  final String id;
  final String name;
  final bool verified;
  final Color avatarColor;
  final String badgeValue;
  final String completedTasksText;
  final String aboutText;
  final WorkerRatingSummary ratingSummary;
  final List<WorkerReview> reviews;
}

class WorkerProfileMockData {
  const WorkerProfileMockData._();

  static WorkerProfileData getById(String workerId) {
    return _profiles[workerId] ?? _profiles.values.first;
  }

  static final _baseReviews = <WorkerReview>[
    const WorkerReview(
      reviewerName: 'أحمد محمد',
      reviewerAvatarColor: Color(0xFFD7E9FF),
      rating: 5,
      comment: 'العامل راقي ومتقن لعمله، أشكره على إتقانه ووصوله على الموعد 👍',
      timeAgo: 'منذ يومين',
    ),
    const WorkerReview(
      reviewerName: 'نورة العتيبي',
      reviewerAvatarColor: Color(0xFFF7DBDF),
      rating: 5,
      comment: 'العامل راقي ومتقن لعمله، أشكره على إتقانه ووصوله على الموعد 👍',
      timeAgo: 'منذ 3 أيام',
    ),
    const WorkerReview(
      reviewerName: 'خالد السعيد',
      reviewerAvatarColor: Color(0xFFE0EFD8),
      rating: 4,
      comment: 'من أفضل العمال الذين تعاملت معهم، ملتزم ومحترم جدا.',
      timeAgo: 'منذ أسبوع',
    ),
    const WorkerReview(
      reviewerName: 'سارة القحطاني',
      reviewerAvatarColor: Color(0xFFE7E3FF),
      rating: 5,
      comment: 'شغل مرتب واهتمام بالتفاصيل، أكيد سأطلبه مرة ثانية.',
      timeAgo: 'منذ أسبوع',
    ),
    const WorkerReview(
      reviewerName: 'محمد الحربي',
      reviewerAvatarColor: Color(0xFFFFE5CF),
      rating: 5,
      comment: 'محترف جدًا، أنجز المهمة بسرعة وجودة ممتازة.',
      timeAgo: 'منذ أسبوعين',
    ),
    const WorkerReview(
      reviewerName: 'ريما الدوسري',
      reviewerAvatarColor: Color(0xFFDDF0F6),
      rating: 4,
      comment: 'الخدمة جيدة جدًا، فقط تأخر بسيط عند الوصول.',
      timeAgo: 'منذ أسبوعين',
    ),
    const WorkerReview(
      reviewerName: 'عبدالله المطيري',
      reviewerAvatarColor: Color(0xFFFDE9C9),
      rating: 5,
      comment: 'تعامل ممتاز والتزام كامل، أنصح به.',
      timeAgo: 'منذ 3 أسابيع',
    ),
    const WorkerReview(
      reviewerName: 'أميرة الشمري',
      reviewerAvatarColor: Color(0xFFDDE7FF),
      rating: 3,
      comment: 'مقبول بشكل عام، يحتاج اهتمام أكثر في بعض التفاصيل.',
      timeAgo: 'منذ 3 أسابيع',
    ),
    const WorkerReview(
      reviewerName: 'فيصل العمري',
      reviewerAvatarColor: Color(0xFFE6F5D8),
      rating: 5,
      comment: 'الأداء ممتاز جدًا، والالتزام رائع.',
      timeAgo: 'منذ شهر',
    ),
    const WorkerReview(
      reviewerName: 'تهاني السبيعي',
      reviewerAvatarColor: Color(0xFFF4DDE8),
      rating: 4,
      comment: 'النتيجة جميلة والتعامل لطيف.',
      timeAgo: 'منذ شهر',
    ),
    const WorkerReview(
      reviewerName: 'يوسف الزهراني',
      reviewerAvatarColor: Color(0xFFE0ECFF),
      rating: 5,
      comment: 'دقيق ومرتب وخدمة ممتازة جدًا.',
      timeAgo: 'منذ شهر',
    ),
    const WorkerReview(
      reviewerName: 'مي العبدالله',
      reviewerAvatarColor: Color(0xFFF0E4D2),
      rating: 4,
      comment: 'شغل ممتاز، وأتمنى إضافة وقت مرن أكثر للحجز.',
      timeAgo: 'منذ شهرين',
    ),
  ];

  static final Map<String, WorkerProfileData> _profiles = <String, WorkerProfileData>{
    'aysar_mohamed': WorkerProfileData(
      id: 'aysar_mohamed',
      name: 'أيسار محمد',
      verified: true,
      avatarColor: const Color(0xFFE2E8F0),
      badgeValue: '4.7',
      completedTasksText: 'أكمل مقدم الخدمة 28 مهمة بنجاح',
      aboutText: 'مقدم خدمة نظافة منزلية بخبرة ممتازة في تنظيف المنازل والشقق مع عناية خاصة بالتفاصيل.',
      ratingSummary: const WorkerRatingSummary(
        average: 4.7,
        totalReviews: 1140,
        starCounts: <int, int>{5: 780, 4: 220, 3: 85, 2: 34, 1: 21},
      ),
      reviews: _baseReviews,
    ),
    'bana_salama': WorkerProfileData(
      id: 'bana_salama',
      name: 'بنى سلامة',
      verified: true,
      avatarColor: const Color(0xFFD8F3F2),
      badgeValue: '4.9',
      completedTasksText: 'أكمل مقدم الخدمة 52 مهمة بنجاح',
      aboutText: 'متخصصة في تنظيم المنازل وإعادة ترتيب المساحات الداخلية بجودة عالية وذوق مميز.',
      ratingSummary: const WorkerRatingSummary(
        average: 4.9,
        totalReviews: 860,
        starCounts: <int, int>{5: 700, 4: 110, 3: 31, 2: 12, 1: 7},
      ),
      reviews: _baseReviews,
    ),
    'mohamed_ahmed': WorkerProfileData(
      id: 'mohamed_ahmed',
      name: 'محمد أحمد',
      verified: true,
      avatarColor: const Color(0xFFD4EDEA),
      badgeValue: '4.8',
      completedTasksText: 'أكمل مقدم الخدمة 40 مهمة بنجاح',
      aboutText: 'مقدم خدمات نظافة بخبرة كبيرة على تنظيف المباني السكنية، عنايته ممتازة بكل تفاصيل المنزل.',
      ratingSummary: const WorkerRatingSummary(
        average: 4.8,
        totalReviews: 1234,
        starCounts: <int, int>{5: 920, 4: 185, 3: 74, 2: 37, 1: 18},
      ),
      reviews: _baseReviews,
    ),
    'maher_ahmed': WorkerProfileData(
      id: 'maher_ahmed',
      name: 'ماهر أحمد',
      verified: true,
      avatarColor: const Color(0xFFF6E8DE),
      badgeValue: '4.6',
      completedTasksText: 'أكمل مقدم الخدمة 24 مهمة بنجاح',
      aboutText: 'خبرة في خدمات التنظيف العامة مع التزام بالمواعيد وتقديم خدمة عملية ومرضية للعملاء.',
      ratingSummary: const WorkerRatingSummary(
        average: 4.6,
        totalReviews: 640,
        starCounts: <int, int>{5: 430, 4: 133, 3: 45, 2: 20, 1: 12},
      ),
      reviews: _baseReviews,
    ),
  };
}
