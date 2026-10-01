import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../orders/data/models/cleaning_worker_profile_model.dart';
import '../../../orders/domain/usecases/fetch_cleaning_worker_profile_use_case.dart';
import '../data/cl_worker_profile_route_args.dart';
import '../widgets/cl_redesign_components.dart';

export '../data/cl_worker_profile_route_args.dart' show WorkerProfileRouteArgs;

@AutoRoutePage()
class ClWorkerProfileDetailScreen extends StatefulWidget {
  const ClWorkerProfileDetailScreen({super.key, required this.args});

  final WorkerProfileRouteArgs args;

  @override
  State<ClWorkerProfileDetailScreen> createState() =>
      _ClWorkerProfileDetailScreenState();
}

class _ClWorkerProfileDetailScreenState
    extends State<ClWorkerProfileDetailScreen> {
  CleaningWorkerProfileModel? _profile;
  bool _isLoading = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final workerId = int.tryParse(widget.args.workerId);
    if (workerId == null || workerId <= 0) return;

    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    final response = await getIt<FetchCleaningWorkerProfileUseCase>()(
      FetchCleaningWorkerProfileParams(workerId: workerId),
    );
    if (!mounted) return;

    response.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          final message = failure.message.trim();
          _loadError = message.isEmpty
              ? 'تعذر تحديث بيانات مقدم الخدمة.'
              : message;
        });
      },
      (result) {
        setState(() {
          _isLoading = false;
          _profile = result.data;
          if (result.data == null) {
            _loadError = 'تعذر تحديث بيانات مقدم الخدمة.';
          }
        });
      },
    );
  }

  String? _nonEmpty(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  String get _name =>
      _nonEmpty(_profile?.user?.name) ??
      _nonEmpty(_profile?.firstName) ??
      _nonEmpty(widget.args.worker?.name) ??
      'مقدم خدمة';

  String? get _avatarUrl =>
      _nonEmpty(_profile?.avatar?.url) ??
      _nonEmpty(widget.args.worker?.profileImage);

  String? get _bio =>
      _nonEmpty(_profile?.bio) ?? _nonEmpty(widget.args.worker?.description);

  double? get _rating {
    final value =
        _profile?.averageRating ??
        widget.args.worker?.ratings?.average ??
        widget.args.worker?.rating;
    return value != null && value >= 0 ? value : null;
  }

  int? get _ratingsCount => widget.args.worker?.ratings?.count;

  int? get _completedJobs =>
      _profile?.totalCompletedJobs ?? widget.args.worker?.completedJobs;

  bool get _isVerified {
    final badges = widget.args.worker?.badges ?? const <String>[];
    return badges.any((badge) => badge.trim().toLowerCase() == 'verified');
  }

  String? get _genderLabel {
    final raw = _nonEmpty(_profile?.gender);
    if (raw != null) {
      final normalized = raw.toLowerCase();
      if (normalized == 'male' || normalized == 'm') return 'ذكر';
      if (normalized == 'female' || normalized == 'f') return 'أنثى';
      return raw;
    }

    final gender = widget.args.worker?.gender;
    if (gender == null) return null;
    return switch (gender.name) {
      'male' => 'ذكر',
      'female' => 'أنثى',
      _ => null,
    };
  }

  List<String> get _serviceZones {
    final zones = _profile?.zones ?? const <CleaningWorkerZoneModel>[];
    final labels = <String>[];
    for (final zone in zones) {
      final name = _nonEmpty(zone.name);
      final city = _nonEmpty(zone.city);
      final label = [name, city].whereType<String>().join(' - ');
      if (label.isNotEmpty && !labels.contains(label)) {
        labels.add(label);
      }
    }
    return labels;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: Column(
          children: [
            _WorkerProfileHeader(
              name: _name,
              avatarUrl: _avatarUrl,
              verified: _isVerified,
              onBack: () => context.pop(),
            ),
            if (_isLoading)
              const LinearProgressIndicator(
                minHeight: 3,
                color: Color(0xFF12B8C4),
                backgroundColor: Color(0xFFE8ECF2),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadProfile,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    24 + MediaQuery.viewPaddingOf(context).bottom,
                  ),
                  children: [
                    if (_loadError != null) ...[
                      _InlineWorkerNotice(
                        message: _loadError!,
                        onRetry: _loadProfile,
                      ),
                      const SizedBox(height: 12),
                    ],
                    _WorkerStatsCard(
                      rating: _rating,
                      ratingsCount: _ratingsCount,
                      completedJobs: _completedJobs,
                    ),
                    const SizedBox(height: 12),
                    ClRedesignCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'نبذة عن مقدم الخدمة',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Color(0xFF172033),
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _bio ?? 'لا توجد نبذة مضافة حالياً.',
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              color: Color(0xFF667085),
                              height: 1.55,
                            ),
                          ),
                          if (_genderLabel != null) ...[
                            const SizedBox(height: 12),
                            _WorkerInfoRow(
                              icon: Icons.person_outline,
                              label: 'الجنس',
                              value: _genderLabel!,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (_serviceZones.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ClRedesignCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'مناطق الخدمة',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: Color(0xFF172033),
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _serviceZones
                                  .map(
                                    (zone) => Chip(
                                      label: Text(zone),
                                      side: const BorderSide(
                                        color: Color(0xFFB6ECEF),
                                      ),
                                      backgroundColor: const Color(0xFFE9F9FA),
                                    ),
                                  )
                                  .toList(growable: false),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    ClRedesignCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'تقييمات العملاء',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Color(0xFF172033),
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _ratingsCount != null && _ratingsCount! > 0
                                ? 'يتوفر التقييم الإجمالي من ${_ratingsCount!} تقييم. تفاصيل المراجعات الفردية غير متاحة في بيانات العامل الحالية.'
                                : 'لا توجد مراجعات مكتوبة متاحة في بيانات العامل الحالية.',
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              color: Color(0xFF667085),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () {
                              context.pushRoute(
                                '/clworkerreviewsall',
                                arguments: widget.args,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              foregroundColor: const Color(0xFF1E2A78),
                              side: const BorderSide(color: Color(0xFFD0D5DD)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'عرض ملخص التقييمات',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkerProfileHeader extends StatelessWidget {
  const _WorkerProfileHeader({
    required this.name,
    required this.avatarUrl,
    required this.verified,
    required this.onBack,
  });

  final String name;
  final String? avatarUrl;
  final bool verified;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [Color(0xFF1E2A78), Color(0xFF0CBBC7)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: IconButton(
                  onPressed: onBack,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1E2A78),
                    minimumSize: const Size(44, 44),
                  ),
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
              CircleAvatar(
                radius: 48,
                backgroundColor: const Color(0xFFE2E8F0),
                backgroundImage: avatarUrl == null
                    ? null
                    : NetworkImage(avatarUrl!),
                child: avatarUrl == null
                    ? const Icon(
                        Icons.person_outline,
                        size: 52,
                        color: Color(0xFF475467),
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (verified) ...[
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.verified_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkerStatsCard extends StatelessWidget {
  const _WorkerStatsCard({
    required this.rating,
    required this.ratingsCount,
    required this.completedJobs,
  });

  final double? rating;
  final int? ratingsCount;
  final int? completedJobs;

  @override
  Widget build(BuildContext context) {
    return ClRedesignCard(
      child: Row(
        children: [
          Expanded(
            child: _WorkerStat(
              icon: Icons.star_rounded,
              value: rating == null ? '—' : rating!.toStringAsFixed(1),
              label: ratingsCount != null && ratingsCount! > 0
                  ? '${ratingsCount!} تقييم'
                  : 'التقييم',
            ),
          ),
          const SizedBox(
            height: 54,
            child: VerticalDivider(color: Color(0xFFE4E7EC)),
          ),
          Expanded(
            child: _WorkerStat(
              icon: Icons.task_alt_rounded,
              value: completedJobs?.toString() ?? '—',
              label: 'مهام مكتملة',
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkerStat extends StatelessWidget {
  const _WorkerStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF0F8E98), size: 22),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF172033),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF667085),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _WorkerInfoRow extends StatelessWidget {
  const _WorkerInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0F8E98)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Color(0xFF667085),
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.start,
            style: const TextStyle(
              color: Color(0xFF172033),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _InlineWorkerNotice extends StatelessWidget {
  const _InlineWorkerNotice({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return ClRedesignCard(
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFB54708)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.start,
              style: const TextStyle(color: Color(0xFF667085)),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }
}
