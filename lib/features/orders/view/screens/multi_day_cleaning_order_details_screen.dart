import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/utils/cleaning_date_time_ui_format.dart';
import 'package:flutter/material.dart';

import '../../data/models/cleaning_booking_schedule_model.dart';
import '../../data/source/cleaning_session_remote_data_source.dart';

class MultiDayCleaningOrderDetailsScreen extends StatefulWidget {
  const MultiDayCleaningOrderDetailsScreen({
    super.key,
    required this.orderId,
    this.initialSessionId,
  });

  final int orderId;
  final int? initialSessionId;

  @override
  State<MultiDayCleaningOrderDetailsScreen> createState() =>
      _MultiDayCleaningOrderDetailsScreenState();
}

class _MultiDayCleaningOrderDetailsScreenState
    extends State<MultiDayCleaningOrderDetailsScreen> {
  CleaningMultiDayOrderEnvelope? _envelope;
  bool _loading = true;
  String? _error;

  CleaningBookingScheduleModel? get _schedule => _envelope?.schedule;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final envelope = await getIt<CleaningSessionRemoteDataSource>()
          .fetchBookingSchedule(widget.orderId);
      if (!mounted) return;
      setState(() {
        _envelope = envelope;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'تعذر تحميل تفاصيل أيام المناسبة. حاول مرة أخرى.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('تفاصيل المناسبة'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 220),
          Center(child: CircularProgressIndicator.adaptive()),
        ],
      );
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 120),
          const Icon(Icons.cloud_off_outlined, size: 42),
          const SizedBox(height: 12),
          AppText.bodyMedium(
            _error!,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 14),
          Center(
            child: OutlinedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ),
        ],
      );
    }

    final schedule = _schedule;
    if (schedule == null || schedule.sessions.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          _card(
            children: [
              AppText.bodyMedium(
                'لا توجد جلسات مسجلة لهذا الطلب بعد.',
                textAlign: TextAlign.center,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
        ],
      );
    }

    final nextSession = schedule.nextSession;
    final bookingNumber = _envelope?.bookingNumber?.trim();
    final progressText =
        '${schedule.completedDaysCount} من ${schedule.daysCount} جلسات مكتملة';

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 30),
      children: [
        _card(
          children: [
            Row(
              children: [
                Expanded(
                  child: AppText.titleMedium(
                    bookingNumber == null || bookingNumber.isEmpty
                        ? 'مساعدة مناسبة - ${schedule.daysCount} أيام'
                        : 'مساعدة مناسبة #$bookingNumber',
                    fontWeight: FontWeight.w800,
                    textAlign: TextAlign.start,
                  ),
                ),
                _statusBadge(_envelope?.status ?? 'pending'),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow('التقدم', progressText),
            const SizedBox(height: 8),
            _infoRow('إجمالي الساعات', '${_hours(schedule.totalHours)} ساعة'),
            if (nextSession != null) ...[
              const SizedBox(height: 8),
              _infoRow('الموعد القادم', _sessionDateTime(nextSession)),
            ],
            if (_envelope?.totalPrice != null) ...[
              const SizedBox(height: 8),
              _infoRow(
                'إجمالي الطلب',
                '${_money(_envelope!.totalPrice!)} ${_envelope?.currency ?? ''}'.trim(),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        AppText.titleSmall(
          'أيام التنفيذ',
          fontWeight: FontWeight.w800,
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 10),
        ...schedule.sessions.map(
          (session) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _sessionCard(session, schedule.daysCount),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: AppText.bodySmall(
            'كل يوم هو جلسة تنفيذ مستقلة داخل نفس رقم الحجز. إكمال يوم لا يغلق المناسبة قبل انتهاء آخر جلسة مطلوبة.',
            color: const Color(0xFF1E3A8A),
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }

  Widget _sessionCard(CleaningBookingSessionModel session, int totalDays) {
    final assignmentNames = session.workerAssignments
        .map((assignment) => assignment.workerName?.trim())
        .whereType<String>()
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList(growable: false);

    return _card(
      children: [
        Row(
          children: [
            Expanded(
              child: AppText.bodyLarge(
                'اليوم ${session.sequence} من $totalDays',
                fontWeight: FontWeight.w800,
                textAlign: TextAlign.start,
              ),
            ),
            _statusBadge(session.status, label: session.statusLabel),
          ],
        ),
        const SizedBox(height: 10),
        _infoRow('الموعد', _sessionDateTime(session)),
        const SizedBox(height: 7),
        _infoRow('المدة', '${_hours(session.hours)} ساعة'),
        if (assignmentNames.isNotEmpty) ...[
          const SizedBox(height: 7),
          _infoRow('العامل', assignmentNames.join('، ')),
        ],
        if (session.pricing?.totalPrice != null) ...[
          const SizedBox(height: 7),
          _infoRow(
            'سعر الجلسة',
            '${_money(session.pricing!.totalPrice!)} ${session.pricing?.currency ?? _envelope?.currency ?? ''}'.trim(),
          ),
        ],
        if (session.isCancelled &&
            session.cancellationReason != null &&
            session.cancellationReason!.trim().isNotEmpty) ...[
          const SizedBox(height: 7),
          _infoRow('سبب الإلغاء', session.cancellationReason!.trim()),
        ],
      ],
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: AppText.bodySmall(
            label,
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.start,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: AppText.bodySmall(
            value,
            color: const Color(0xFF111827),
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String status, {String? label}) {
    final normalized = status.trim().toLowerCase();
    final resolved = label?.trim().isNotEmpty == true
        ? label!.trim()
        : _statusLabel(normalized);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _statusBackground(normalized),
        borderRadius: BorderRadius.circular(999),
      ),
      child: AppText.bodySmall(
        resolved,
        color: _statusForeground(normalized),
        fontWeight: FontWeight.w800,
      ),
    );
  }

  String _sessionDateTime(CleaningBookingSessionModel session) {
    final date = session.date;
    final dateText = date == null
        ? '-'
        : '${CleaningDateTimeUiFormat.weekday(date)}، ${CleaningDateTimeUiFormat.date(date)}';
    final time = session.time;
    if (time == null || time.trim().isEmpty) return dateText;
    return '$dateText - ${CleaningDateTimeUiFormat.time(time)}';
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'scheduled':
        return 'مجدولة';
      case 'searching':
      case 'pending':
        return 'جاري البحث عن عامل';
      case 'worker_assigned':
      case 'assigned':
        return 'تم تعيين العامل';
      case 'travel_started':
        return 'العامل في الطريق';
      case 'arrived':
      case 'awaiting_start_verification':
        return 'بانتظار بدء الخدمة';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'awaiting_customer_completion':
        return 'بانتظار تأكيد الإكمال';
      case 'completed':
        return 'مكتملة';
      case 'cancelled':
        return 'ملغاة';
      case 'under_dispute':
        return 'قيد المراجعة';
      default:
        return status.isEmpty ? 'غير محدد' : status;
    }
  }

  Color _statusBackground(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFFDCFCE7);
      case 'cancelled':
      case 'under_dispute':
        return const Color(0xFFFEE2E2);
      case 'in_progress':
      case 'travel_started':
      case 'arrived':
        return const Color(0xFFDBEAFE);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _statusForeground(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF166534);
      case 'cancelled':
      case 'under_dispute':
        return const Color(0xFF991B1B);
      case 'in_progress':
      case 'travel_started':
      case 'arrived':
        return const Color(0xFF1D4ED8);
      default:
        return const Color(0xFF374151);
    }
  }

  String _hours(double value) =>
      value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);

  String _money(double value) =>
      value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
}
