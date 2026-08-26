import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../data/models/cleaning_booking_schedule_model.dart';
import '../../data/source/cleaning_session_remote_data_source.dart';
import '../../domain/usecases/fetch_cleaning_worker_profile_use_case.dart';
import 'cleaning_worker_rating_screen.dart';

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
  int? _selectedSessionId;
  bool _loading = true;
  bool _busy = false;
  String? _error;

  CleaningBookingScheduleModel? get _schedule => _envelope?.schedule;

  CleaningBookingSessionModel? get _activeSession {
    final schedule = _schedule;
    if (schedule == null) return null;

    final selected = schedule.sessionById(_selectedSessionId);
    if (selected != null) return selected;

    final nextSession = schedule.nextSession;
    if (nextSession != null) {
      return schedule.sessionById(nextSession.id) ?? nextSession;
    }

    return schedule.sessions.isEmpty ? null : schedule.sessions.first;
  }

  bool get _parentCompleted {
    if ((_envelope?.status ?? '').trim().toLowerCase() == 'completed') {
      return true;
    }

    final schedule = _schedule;
    if (schedule == null || schedule.sessions.isEmpty) return false;

    final nonCancelledSessions = schedule.sessions
        .where((session) => !session.isCancelled)
        .toList(growable: false);

    return nonCancelledSessions.isNotEmpty &&
        nonCancelledSessions.every((session) => session.isCompleted);
  }

  @override
  void initState() {
    super.initState();
    _selectedSessionId = widget.initialSessionId;
    _refresh(showLoading: true);
  }

  Future<void> _refresh({bool showLoading = false}) async {
    if (showLoading && mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final result = await getIt<CleaningSessionRemoteDataSource>()
          .fetchBookingSchedule(widget.orderId);
      if (!mounted) return;

      final schedule = result.schedule;
      setState(() {
        _envelope = result;
        _loading = false;
        _error = null;

        if (schedule != null &&
            schedule.sessionById(_selectedSessionId) == null) {
          _selectedSessionId = schedule.nextSession?.id ??
              (schedule.sessions.isEmpty ? null : schedule.sessions.first.id);
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'تعذر تحميل تفاصيل أيام المناسبة. حاول مرة أخرى.';
      });
    }
  }

  Future<void> _runAction(Future<void> Function() action) async {
    if (_busy || !mounted) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await action();
      await _refresh();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _friendlyError(error));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  String _friendlyError(Object error) {
    final text = error.toString().toLowerCase();

    if (text.contains('schedule') && text.contains('accepted')) {
      return 'لا يمكن تعديل جدول المناسبة بعد قبول أحد العمال.';
    }
    if (text.contains('code')) {
      return 'رمز التحقق غير صحيح أو انتهت صلاحيته.';
    }

    return 'تعذر تنفيذ العملية. تحقق من حالة اليوم وحاول مرة أخرى.';
  }

  Future<void> _confirmStartCode() async {
    final session = _activeSession;
    final sessionId = session?.id;
    if (session == null || sessionId == null) return;

    final code = await _askText(
      title: 'تأكيد بدء اليوم ${session.sequence}',
      hint: 'أدخل رمز التحقق الذي يعرضه مقدم الخدمة',
      isRequired: true,
      keyboardType: TextInputType.number,
    );
    if (code == null || code.trim().isEmpty) return;

    await _runAction(() async {
      await getIt<CleaningSessionRemoteDataSource>().confirmStartVerification(
        orderId: widget.orderId,
        sessionId: sessionId,
        code: code.trim(),
      );
    });
  }

  Future<void> _confirmCompletion() async {
    final session = _activeSession;
    final sessionId = session?.id;
    if (session == null || sessionId == null) return;

    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('تأكيد إكمال اليوم ${session.sequence}'),
        content: const Text('هل تم تنفيذ أعمال هذا اليوم بالشكل المطلوب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('رجوع'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('تأكيد الإكمال'),
          ),
        ],
      ),
    );
    if (approved != true) return;

    await _runAction(() async {
      await getIt<CleaningSessionRemoteDataSource>().confirmCompletion(
        orderId: widget.orderId,
        sessionId: sessionId,
      );
    });
  }

  Future<void> _rejectCompletion() async {
    final session = _activeSession;
    final sessionId = session?.id;
    if (session == null || sessionId == null) return;

    final message = await _askText(
      title: 'العمل غير مكتمل',
      hint: 'اشرح ما الذي يحتاج إلى إكمال',
      isRequired: true,
    );
    if (message == null || message.trim().isEmpty) return;

    await _runAction(() async {
      await getIt<CleaningSessionRemoteDataSource>().rejectCompletion(
        orderId: widget.orderId,
        sessionId: sessionId,
        message: message.trim(),
      );
    });
  }

  Future<void> _requestExtension() async {
    final session = _activeSession;
    final sessionId = session?.id;
    if (session == null || sessionId == null) return;

    final minutesText = await _askText(
      title: 'تمديد وقت هذا اليوم',
      hint: 'عدد الدقائق الإضافية، مثال: 30',
      isRequired: true,
      keyboardType: TextInputType.number,
    );
    if (!mounted || minutesText == null) return;

    final minutes = int.tryParse(minutesText.trim());
    if (minutes == null || minutes <= 0) {
      _toast('أدخل مدة إضافية صحيحة بالدقائق', ToastificationType.warning);
      return;
    }

    final message = await _askText(
      title: 'ملاحظة التمديد',
      hint: 'ملاحظة لمقدم الخدمة (اختياري)',
      isRequired: false,
    );
    if (message == null) return;

    await _runAction(() async {
      await getIt<CleaningSessionRemoteDataSource>().requestExtension(
        orderId: widget.orderId,
        sessionId: sessionId,
        additionalMinutes: minutes,
        message: message,
      );
    });
  }

  Future<void> _cancelSession() async {
    final session = _activeSession;
    final sessionId = session?.id;
    if (session == null || sessionId == null) return;

    final reason = await _askText(
      title: 'إلغاء اليوم ${session.sequence}',
      hint: 'سبب إلغاء هذا اليوم',
      isRequired: true,
    );
    if (!mounted || reason == null || reason.trim().isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد إلغاء اليوم'),
        content: Text(
          'سيتم إلغاء ${_dateLabel(session)} فقط، وستبقى بقية أيام المناسبة كما هي. قد تطبق رسوم إلغاء حسب السياسة.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('رجوع'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('إلغاء اليوم'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await _runAction(() async {
      await getIt<CleaningSessionRemoteDataSource>().cancelSession(
        orderId: widget.orderId,
        sessionId: sessionId,
        reason: reason.trim(),
      );
    });
  }

  Future<String?> _askText({
    required String title,
    required String hint,
    required bool isRequired,
    TextInputType? keyboardType,
  }) async {
    final controller = TextEditingController();

    try {
      return await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: keyboardType,
            minLines: keyboardType == TextInputType.number ? 1 : 2,
            maxLines: keyboardType == TextInputType.number ? 1 : 5,
            decoration: InputDecoration(hintText: hint),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                if (isRequired && value.isEmpty) return;
                Navigator.of(dialogContext).pop(value);
              },
              child: const Text('تأكيد'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  void _toast(String message, ToastificationType type) {
    if (!mounted) return;
    AppToast.showToast(context: context, message: message, type: type);
  }

  String _dateLabel(CleaningBookingSessionModel session) {
    final date = session.date;
    if (date == null) return '-';

    const days = <String>[
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];

    return '${days[date.weekday - 1]}، ${date.day}/${date.month}/${date.year}';
  }

  String _timeLabel(String? value) {
    if (value == null || value.trim().isEmpty) return '-';

    final parts = value.split(':');
    if (parts.length < 2) return value;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return value;

    final suffix = hour >= 12 ? 'م' : 'ص';
    var displayHour = hour % 12;
    if (displayHour == 0) displayHour = 12;

    return '$displayHour:${minute.toString().padLeft(2, '0')} $suffix';
  }

  String _hours(double value) {
    return value % 1 == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }

  String _statusLabel(CleaningBookingSessionModel session) {
    final apiLabel = session.statusLabel?.trim();
    if (apiLabel != null && apiLabel.isNotEmpty) return apiLabel;

    return switch (session.status) {
      'scheduled' => 'مجدول',
      'worker_assigned' => session.startedTravelAt != null
          ? 'مقدم الخدمة في الطريق'
          : 'تم تعيين مقدمي الخدمة',
      'awaiting_start_verification' => 'بانتظار رمز التحقق',
      'awaiting_worker_start_confirmation' => 'بانتظار بدء مقدمي الخدمة',
      'in_progress' => 'قيد التنفيذ',
      'awaiting_customer_completion' => 'بانتظار قرار الإكمال',
      'time_extension_requested' => 'بانتظار رد مقدم الخدمة على التمديد',
      'completed' => 'مكتمل',
      'cancelled' => 'ملغي',
      'under_dispute' => 'قيد المراجعة',
      _ => 'قيد المعالجة',
    };
  }

  int? _extractWorkerId() {
    final schedule = _schedule;
    if (schedule == null) return null;

    for (final session in schedule.sessions) {
      for (final assignment in session.workerAssignments) {
        final direct = assignment['workerId'] ?? assignment['worker_id'];
        if (direct is int && direct > 0) return direct;
        if (direct is num && direct.toInt() > 0) return direct.toInt();

        final parsed = int.tryParse(direct?.toString() ?? '');
        if (parsed != null && parsed > 0) return parsed;

        final worker = assignment['worker'];
        if (worker is Map) {
          final nested = worker['id'];
          final nestedParsed = nested is num
              ? nested.toInt()
              : int.tryParse(nested?.toString() ?? '');
          if (nestedParsed != null && nestedParsed > 0) {
            return nestedParsed;
          }
        }
      }
    }

    return null;
  }

  Future<void> _openReview() async {
    if (_busy) return;

    final workerId = _extractWorkerId();
    if (workerId == null) {
      _toast(
        'تعذر تحديد مقدم الخدمة للتقييم',
        ToastificationType.warning,
      );
      return;
    }

    setState(() => _busy = true);

    try {
      final response = await getIt<FetchCleaningWorkerProfileUseCase>()(
        FetchCleaningWorkerProfileParams(workerId: workerId),
      );
      if (!mounted) return;

      response.fold(
        (failure) => _toast(failure.message, ToastificationType.error),
        (result) {
          final profile = result.data;
          if (profile == null) {
            _toast(
              'تعذر تحميل مقدم الخدمة للتقييم',
              ToastificationType.warning,
            );
            return;
          }

          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CleaningWorkerRatingScreen(
                args: CleaningWorkerRatingArgs(
                  orderId: widget.orderId,
                  workerProfile: profile,
                ),
              ),
            ),
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Widget _summaryCard(CleaningBookingScheduleModel schedule) {
    final rawProgress = schedule.daysCount <= 0
        ? 0.0
        : schedule.completedDaysCount / schedule.daysCount;
    final progress = rawProgress.clamp(0.0, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText.titleMedium(
                  'مساعدة مناسبة متعددة الأيام',
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffE2F5F4),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: AppText.bodySmall(
                  '${schedule.completedDaysCount}/${schedule.daysCount} مكتمل',
                  color: const Color(0xff0F766E),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 10),
          AppText.bodySmall(
            '${schedule.daysCount} أيام · ${_hours(schedule.totalHours)} ساعة لكل عامل · ${schedule.cancelledDaysCount} ملغي',
          ),
          if (_envelope?.totalPrice != null) ...[
            const SizedBox(height: 6),
            AppText.bodyMedium(
              'الإجمالي: ${_envelope!.totalPrice!.toStringAsFixed(0)} ${_envelope?.currency ?? 'SYP'}',
              fontWeight: FontWeight.w800,
            ),
          ],
          if (schedule.nextSession != null && !_parentCompleted) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xffEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'الجلسة القادمة: ${_dateLabel(schedule.nextSession!)}، ${_timeLabel(schedule.nextSession!.time)}',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sessionSelector(CleaningBookingScheduleModel schedule) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: schedule.sessions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final session = schedule.sessions[index];
          return ChoiceChip(
            selected: session.id == _selectedSessionId,
            onSelected: (_) {
              setState(() => _selectedSessionId = session.id);
            },
            avatar: session.isCompleted
                ? const Icon(Icons.check_circle, size: 18)
                : session.isCancelled
                    ? const Icon(Icons.cancel_outlined, size: 18)
                    : null,
            label: Text('اليوم ${session.sequence}'),
          );
        },
      ),
    );
  }

  Widget _sessionCard(
    CleaningBookingScheduleModel schedule,
    CleaningBookingSessionModel session,
  ) {
    final price = session.pricing?.totalPrice;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText.titleMedium(
                  'اليوم ${session.sequence} من ${schedule.daysCount}',
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffF3F4F6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(_statusLabel(session)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppText.bodyMedium(
            _dateLabel(session),
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 4),
          AppText.bodySmall(
            '${_timeLabel(session.time)} · ${_hours(session.hours)} ساعة',
          ),
          if (price != null) ...[
            const SizedBox(height: 5),
            AppText.bodySmall(
              'إجمالي هذا اليوم: ${price.toStringAsFixed(0)} ${session.pricing?.currency ?? _envelope?.currency ?? 'SYP'}',
            ),
          ],
          const SizedBox(height: 14),
          _actionArea(session),
        ],
      ),
    );
  }

  Widget _actionArea(CleaningBookingSessionModel session) {
    if (session.isCompleted) {
      return const _InfoBanner(
        icon: Icons.check_circle_outline,
        text: 'تم إكمال هذا اليوم بنجاح.',
      );
    }

    if (session.isCancelled) {
      return const _InfoBanner(
        icon: Icons.cancel_outlined,
        text: 'تم إلغاء هذا اليوم.',
      );
    }

    if (session.status == 'under_dispute') {
      return const _InfoBanner(
        icon: Icons.gavel_outlined,
        text: 'هذه الجلسة قيد المراجعة.',
      );
    }

    if (session.isAwaitingStartVerification) {
      return FilledButton.icon(
        onPressed: _busy ? null : _confirmStartCode,
        icon: const Icon(Icons.verified_user_outlined),
        label: const Text('إدخال رمز بدء هذا اليوم'),
      );
    }

    if (session.status == 'awaiting_worker_start_confirmation') {
      return const _InfoBanner(
        icon: Icons.hourglass_top,
        text: 'تم التحقق من الرمز. بانتظار تأكيد مقدمي الخدمة لبدء العمل.',
      );
    }

    if (session.isInProgress) {
      return const _InfoBanner(
        icon: Icons.cleaning_services_outlined,
        text: 'العمل في هذا اليوم قيد التنفيذ.',
      );
    }

    if (session.isExtensionPending) {
      return const _InfoBanner(
        icon: Icons.more_time,
        text: 'تم إرسال طلب التمديد لهذا اليوم وبانتظار رد مقدم الخدمة.',
      );
    }

    if (session.isAwaitingCustomerCompletion) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: _busy ? null : _confirmCompletion,
            icon: const Icon(Icons.task_alt),
            label: const Text('تأكيد إكمال هذا اليوم'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : _rejectCompletion,
                  child: const Text('العمل غير مكتمل'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : _requestExtension,
                  child: const Text('طلب تمديد'),
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (session.canCancel) {
      return OutlinedButton.icon(
        onPressed: _busy ? null : _cancelSession,
        icon: const Icon(Icons.cancel_outlined),
        label: const Text('إلغاء هذا اليوم'),
      );
    }

    return const _InfoBanner(
      icon: Icons.schedule,
      text: 'بانتظار موعد هذه الجلسة أو تحديث حالتها.',
    );
  }

  Widget _loadingBody() {
    return const Scaffold(
      backgroundColor: Color(0xffF3F4F6),
      body: SafeArea(
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _loadErrorBody() {
    return Scaffold(
      backgroundColor: const Color(0xffF3F4F6),
      appBar: AppBar(title: const Text('تفاصيل المناسبة')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _refresh(showLoading: true),
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _loadingBody();

    final schedule = _schedule;
    if (_error != null && schedule == null) {
      return _loadErrorBody();
    }

    if (schedule == null || !schedule.isMultiDay) {
      return Scaffold(
        backgroundColor: const Color(0xffF3F4F6),
        appBar: AppBar(title: const Text('تفاصيل المناسبة')),
        body: const Center(
          child: Text('هذا الطلب لا يحتوي جدولاً متعدد الأيام.'),
        ),
      );
    }

    final session = _activeSession;

    return Scaffold(
      backgroundColor: const Color(0xffF3F4F6),
      appBar: AppBar(
        title: Text(_envelope?.bookingNumber ?? 'تفاصيل المناسبة'),
        actions: [
          IconButton(
            onPressed: _busy ? null : _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _summaryCard(schedule),
            const SizedBox(height: 12),
            _sessionSelector(schedule),
            const SizedBox(height: 12),
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xffFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Color(0xffB91C1C)),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (_busy) ...[
              const LinearProgressIndicator(minHeight: 2),
              const SizedBox(height: 12),
            ],
            if (session != null) _sessionCard(schedule, session),
            if (_parentCompleted) ...[
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _busy ? null : _openReview,
                icon: const Icon(Icons.star_outline),
                label: const Text('تقييم الخدمة بعد اكتمال المناسبة'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
