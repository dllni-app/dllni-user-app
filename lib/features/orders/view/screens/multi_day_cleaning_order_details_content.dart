import 'package:common_package/common_package.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/utils/cleaning_date_time_ui_format.dart';
import 'package:flutter/material.dart';

import '../../data/models/cleaning_booking_schedule_model.dart';
import '../../data/source/cleaning_session_remote_data_source.dart';
import '../../domain/usecases/submit_cleaning_review_use_case.dart';
import 'multi_day_cleaning_order_reschedule_screen.dart';
import 'recurring_cleaning_schedule_revision_screen.dart';

class MultiDayCleaningOrderDetailsScreen extends StatefulWidget {
  const MultiDayCleaningOrderDetailsScreen({
    super.key,
    required this.orderId,
    this.initialSessionId,
    this.recurring = false,
  });

  final int orderId;
  final int? initialSessionId;
  final bool recurring;

  @override
  State<MultiDayCleaningOrderDetailsScreen> createState() =>
      _MultiDayCleaningOrderDetailsScreenState();
}

class _MultiDayCleaningOrderDetailsScreenState
    extends State<MultiDayCleaningOrderDetailsScreen> {
  CleaningMultiDayOrderEnvelope? _envelope;
  bool _loading = true;
  int? _busySessionId;
  bool _busySeriesAction = false;
  bool _submittingReview = false;
  String? _error;
  String? _actionError;

  CleaningBookingScheduleModel? get _schedule => _envelope?.schedule;
  CleaningSessionRemoteDataSource get _sessions =>
      getIt<CleaningSessionRemoteDataSource>();

  bool get _canReschedule {
    final schedule = _schedule;
    return !widget.recurring &&
        schedule != null &&
        schedule.sessions.isNotEmpty &&
        schedule.sessions.every((session) => session.canReschedule == true);
  }

  List<_EventReviewWorker> get _eventReviewWorkers {
    final schedule = _schedule;
    if (schedule == null) return const <_EventReviewWorker>[];

    final workers = <int, _EventReviewWorker>{};
    for (final session in schedule.sessions) {
      if (!session.isCompleted) continue;

      for (final assignment in session.workerAssignments) {
        final workerId = assignment.workerId;
        final assignmentStatus = assignment.status?.trim().toLowerCase();
        if (workerId == null ||
            workerId <= 0 ||
            assignmentStatus != 'completed') {
          continue;
        }

        final workerName = assignment.workerName?.trim();
        workers.putIfAbsent(
          workerId,
          () => _EventReviewWorker(
            workerId: workerId,
            workerName: workerName?.isNotEmpty == true
                ? workerName!
                : 'العامل #$workerId',
          ),
        );
      }
    }

    return workers.values.toList(growable: false);
  }

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
        _actionError = null;
      });
    }

    try {
      final envelope = await _sessions.fetchBookingSchedule(widget.orderId);
      if (!mounted) return;
      setState(() {
        _envelope = envelope;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = widget.recurring
            ? 'تعذر تحميل الزيارات الدورية. حاول مرة أخرى.'
            : 'تعذر تحميل تفاصيل أيام المناسبة. حاول مرة أخرى.';
      });
    }
  }

  Future<void> _runSessionAction(
    CleaningBookingSessionModel session,
    Future<CleaningMultiDayOrderEnvelope> Function() action,
  ) async {
    final sessionId = session.id;
    if (sessionId == null || _busySessionId != null) return;

    setState(() {
      _busySessionId = sessionId;
      _actionError = null;
    });

    try {
      final envelope = await action();
      if (!mounted) return;
      if (envelope.schedule != null) {
        setState(() => _envelope = envelope);
      } else {
        await _load();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _actionError =
            'تعذر تنفيذ الإجراء لهذه الجلسة. حدّث الطلب وتحقق من حالتها ثم حاول مرة أخرى.';
      });
    } finally {
      if (mounted) setState(() => _busySessionId = null);
    }
  }

  Future<void> _runSeriesAction(
    Future<CleaningMultiDayOrderEnvelope> Function() action,
  ) async {
    if (_busySeriesAction || _busySessionId != null) return;

    setState(() {
      _busySeriesAction = true;
      _actionError = null;
    });

    try {
      final envelope = await action();
      if (!mounted) return;
      if (envelope.schedule != null) {
        setState(() => _envelope = envelope);
      } else {
        await _load();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _actionError =
            'تعذر تحديث حالة الحجز الدوري. حدّث الطلب وتحقق من حالته ثم حاول مرة أخرى.';
      });
    } finally {
      if (mounted) setState(() => _busySeriesAction = false);
    }
  }

  Future<void> _openReschedule() async {
    if (!_canReschedule) return;

    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            MultiDayCleaningOrderRescheduleScreen(orderId: widget.orderId),
      ),
    );

    if (changed == true && mounted) {
      await _load();
    }
  }

  Future<void> _openRecurringRevision() async {
    final schedule = _schedule;
    if (!widget.recurring || schedule == null || schedule.isPaused) return;

    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RecurringCleaningScheduleRevisionScreen(
          orderId: widget.orderId,
          initialSessions: schedule.sessions,
        ),
      ),
    );
    if (changed == true && mounted) {
      await _load();
    }
  }

  Future<void> _confirmStartVerification(
    CleaningBookingSessionModel session,
  ) async {
    final sessionId = session.id;
    if (sessionId == null || !session.canConfirmStartVerification) return;
    final code = await _askSecurityCode();
    if (code == null) return;

    await _runSessionAction(
      session,
      () => _sessions.confirmStartVerification(
        orderId: widget.orderId,
        sessionId: sessionId,
        code: code,
      ),
    );
  }

  Future<void> _confirmCompletion(CleaningBookingSessionModel session) async {
    final sessionId = session.id;
    if (sessionId == null || !session.canConfirmCompletion) return;
    final approved = await _confirmDialog(
      title: widget.recurring
          ? 'تأكيد إكمال هذه الزيارة'
          : 'تأكيد إكمال هذا اليوم',
      message: widget.recurring
          ? 'هل تؤكد أن العمل الخاص بهذه الزيارة انتهى؟ ستُغلق هذه الزيارة فقط، وتبقى الزيارات القادمة ضمن نفس الحجز.'
          : 'هل تؤكد أن العمل الخاص بهذه الجلسة انتهى؟ سيُغلق هذا اليوم فقط، وتبقى الأيام القادمة ضمن نفس الحجز.',
      confirmLabel: 'تأكيد الإكمال',
    );
    if (!approved) return;

    await _runSessionAction(
      session,
      () => _sessions.confirmCompletion(
        orderId: widget.orderId,
        sessionId: sessionId,
      ),
    );
  }

  Future<void> _cancelSession(CleaningBookingSessionModel session) async {
    final sessionId = session.id;
    if (sessionId == null || !session.canCancel) return;
    final reason = await _askText(
      title: widget.recurring ? 'إلغاء هذه الزيارة فقط' : 'إلغاء هذا اليوم فقط',
      hint: 'سبب الإلغاء',
      confirmLabel: 'إلغاء اليوم',
    );
    if (reason == null) return;

    final approved = await _confirmDialog(
      title: widget.recurring
          ? 'تأكيد إلغاء الزيارة ${session.sequence}'
          : 'تأكيد إلغاء اليوم ${session.sequence}',
      message: widget.recurring
          ? 'سيتم إلغاء هذه الزيارة فقط وتحرير العمال المرتبطين بها. الزيارات المنفذة وبقية الزيارات لن تُلغى.'
          : 'سيتم إلغاء هذه الجلسة فقط وتحرير العمال المرتبطين بها. الأيام المنفذة وباقي الأيام لن تُلغى.',
      confirmLabel: 'تأكيد الإلغاء',
      destructive: true,
    );
    if (!approved) return;

    await _runSessionAction(
      session,
      () => _sessions.cancelSession(
        orderId: widget.orderId,
        sessionId: sessionId,
        reason: reason,
      ),
    );
  }

  Future<void> _skipSession(CleaningBookingSessionModel session) async {
    final sessionId = session.id;
    if (sessionId == null || !session.canSkip) return;

    final reason = await _askText(
      title: 'تخطي هذه الزيارة',
      hint: 'سبب تخطي الزيارة',
      confirmLabel: 'متابعة',
    );
    if (reason == null) return;

    final approved = await _confirmDialog(
      title: 'تأكيد تخطي الزيارة ${session.sequence}',
      message:
          'سيتم تخطي هذه الزيارة فقط وتحرير العامل المرتبط بها دون رسوم إلغاء، وسيُعاد احتساب إجمالي الحجز. بقية الزيارات ستبقى كما هي.',
      confirmLabel: 'تخطي الزيارة',
    );
    if (!approved) return;

    await _runSessionAction(
      session,
      () => _sessions.skipSession(
        orderId: widget.orderId,
        sessionId: sessionId,
        reason: reason,
      ),
    );
  }

  Future<void> _pauseRecurringSeries() async {
    final schedule = _schedule;
    if (!widget.recurring || schedule == null || !schedule.canPause) return;

    final reason = await _askText(
      title: 'إيقاف الحجز الدوري مؤقتاً',
      hint: 'سبب الإيقاف المؤقت',
      confirmLabel: 'متابعة',
    );
    if (reason == null) return;

    final approved = await _confirmDialog(
      title: 'تأكيد إيقاف الحجز الدوري',
      message:
          'سيتم إيقاف الزيارات المستقبلية المؤهلة مؤقتاً وتحرير العمال المرتبطين بها دون اعتبارها ملغاة أو متخطاة. يمكنك استئناف نفس الحجز لاحقاً.',
      confirmLabel: 'إيقاف مؤقت',
    );
    if (!approved) return;

    await _runSeriesAction(
      () => _sessions.pauseRecurringSeries(
        orderId: widget.orderId,
        reason: reason,
      ),
    );
  }

  Future<void> _resumeRecurringSeries() async {
    final schedule = _schedule;
    if (!widget.recurring || schedule == null || !schedule.canResume) return;

    final approved = await _confirmDialog(
      title: 'استئناف الحجز الدوري',
      message:
          'ستعود الزيارات المستقبلية للبحث عن عمال. أي زيارة انتهى موعدها أثناء الإيقاف ستُعامل كزيارة متخطاة دون رسوم إلغاء.',
      confirmLabel: 'استئناف الحجز',
    );
    if (!approved) return;

    await _runSeriesAction(
      () => _sessions.resumeRecurringSeries(orderId: widget.orderId),
    );
  }

  Future<void> _sendSos(CleaningBookingSessionModel session) async {
    final sessionId = session.id;
    if (sessionId == null || !session.canSendSos) return;
    final message = await _askText(
      title: 'طلب مساعدة عاجلة لهذه الجلسة',
      hint: 'اشرح الحالة الطارئة باختصار',
      confirmLabel: 'إرسال SOS',
    );
    if (message == null) return;

    await _runSessionAction(
      session,
      () => _sessions.sendSos(
        orderId: widget.orderId,
        sessionId: sessionId,
        emergencyType: 'safety_threat',
        message: message,
      ),
    );
  }

  Future<void> _reportRecurringLate(CleaningBookingSessionModel session) async {
    final sessionId = session.id;
    final workerIds = session.reportableLateWorkerIds;
    if (!widget.recurring ||
        sessionId == null ||
        !session.canReportLate ||
        workerIds.isEmpty ||
        _busySessionId != null) {
      return;
    }

    final names = _workerNamesForIds(session, workerIds);
    final approved = await _confirmDialog(
      title: 'العامل متأخر عن موعد الزيارة',
      message:
          'مرّت مهلة التأخير${names.isEmpty ? '' : ' للعامل: ${names.join('، ')}'}. إذا اخترت الانتظار، سنسجل البلاغ وتبقى الزيارة فعالة. إذا لم يبدأ العامل التنقل بعد مهلة عدم التنقل سيظهر لك خيار الاستبدال أو الإلغاء دون رسوم.',
      confirmLabel: 'سأنتظر العامل',
    );
    if (!approved) return;

    await _runSessionAction(
      session,
      () => _sessions.reportSessionAttendance(
        orderId: widget.orderId,
        sessionId: sessionId,
        workerIds: workerIds,
        action: 'wait',
      ),
    );
  }

  Future<void> _handleRecurringNoTravel(
    CleaningBookingSessionModel session,
  ) async {
    final sessionId = session.id;
    final workerIds = session.reportableNoTravelWorkerIds;
    if (!widget.recurring ||
        sessionId == null ||
        !session.canReportNoTravel ||
        workerIds.isEmpty ||
        _busySessionId != null) {
      return;
    }

    final names = _workerNamesForIds(session, workerIds);
    final action = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('العامل لم يبدأ التنقل'),
        content: Text(
          '${names.isEmpty ? 'العامل المعيّن' : names.join('، ')} لم يبدأ التنقل بعد انتهاء المهلة المحددة. يمكنك طلب بديل لهذه الزيارة أو إلغاء الزيارة دون رسوم إلغاء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('رجوع'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop('cancel'),
            child: const Text('إلغاء الزيارة دون رسوم'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop('replace'),
            child: const Text('استبدال العامل'),
          ),
        ],
      ),
    );
    if (!mounted || action == null) return;

    await _runSessionAction(
      session,
      () => _sessions.reportSessionAttendance(
        orderId: widget.orderId,
        sessionId: sessionId,
        workerIds: workerIds,
        action: action,
      ),
    );
  }

  List<String> _workerNamesForIds(
    CleaningBookingSessionModel session,
    List<int> workerIds,
  ) {
    final ids = workerIds.toSet();
    return session.workerAssignments
        .where(
          (assignment) =>
              assignment.workerId != null && ids.contains(assignment.workerId),
        )
        .map((assignment) => assignment.workerName?.trim())
        .whereType<String>()
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }

  Future<void> _reviewRecurringSession(
    CleaningBookingSessionModel session,
  ) async {
    final sessionId = session.id;
    if (!widget.recurring ||
        sessionId == null ||
        !session.canReview ||
        _busySessionId != null) {
      return;
    }

    final reviewableIds = session.reviewableWorkerIds.toSet();
    final workers = session.workerAssignments
        .where(
          (assignment) =>
              assignment.workerId != null &&
              reviewableIds.contains(assignment.workerId),
        )
        .map(
          (assignment) => _EventReviewWorker(
            workerId: assignment.workerId!,
            workerName: assignment.workerName?.trim().isNotEmpty == true
                ? assignment.workerName!.trim()
                : 'العامل #${assignment.workerId}',
          ),
        )
        .toList(growable: false);

    if (workers.isEmpty) {
      setState(
        () => _actionError = 'تعذر تحديد العامل القابل للتقييم لهذه الزيارة.',
      );
      return;
    }

    final draft = await showDialog<_RecurringSessionReviewDraft>(
      context: context,
      builder: (dialogContext) =>
          _RecurringSessionReviewDialog(workers: workers),
    );
    if (!mounted || draft == null) return;

    await _runSessionAction(
      session,
      () => _sessions.submitSessionReview(
        orderId: widget.orderId,
        sessionId: sessionId,
        workerId: draft.workerId,
        rating: draft.rating,
        comment: draft.comment,
      ),
    );
  }

  Future<void> _openRecurringSessionDispute(
    CleaningBookingSessionModel session,
  ) async {
    final sessionId = session.id;
    if (!widget.recurring ||
        sessionId == null ||
        !session.canOpenDispute ||
        _busySessionId != null) {
      return;
    }

    final draft = await showDialog<_RecurringSessionDisputeDraft>(
      context: context,
      builder: (dialogContext) => const _RecurringSessionDisputeDialog(),
    );
    if (!mounted || draft == null) return;

    await _runSessionAction(
      session,
      () => _sessions.openSessionDispute(
        orderId: widget.orderId,
        sessionId: sessionId,
        description: draft.description,
        category: draft.category,
      ),
    );
  }

  Future<String?> _askSecurityCode() async {
    final controller = TextEditingController();
    try {
      return await showDialog<String>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) {
            final valid = controller.text.trim().length == 4;
            return AlertDialog(
              title: const Text('رمز بدء هذه الجلسة'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'أدخل الرمز المكوّن من 4 أرقام الذي يظهر لدى العامل.',
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 4,
                    inputFormatters: const [],
                    onChanged: (_) => setDialogState(() {}),
                    decoration: const InputDecoration(
                      hintText: '0000',
                      counterText: '',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: valid
                      ? () => Navigator.of(
                          dialogContext,
                        ).pop(controller.text.trim())
                      : null,
                  child: const Text('تحقق'),
                ),
              ],
            );
          },
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  Future<String?> _askText({
    required String title,
    required String hint,
    required String confirmLabel,
  }) async {
    final controller = TextEditingController();
    try {
      return await showDialog<String>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) {
            final value = controller.text.trim();
            return AlertDialog(
              title: Text(title),
              content: TextField(
                controller: controller,
                minLines: 2,
                maxLines: 5,
                maxLength: 1000,
                onChanged: (_) => setDialogState(() {}),
                decoration: InputDecoration(hintText: hint),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('رجوع'),
                ),
                FilledButton(
                  onPressed: value.isEmpty
                      ? null
                      : () => Navigator.of(dialogContext).pop(value),
                  child: Text(confirmLabel),
                ),
              ],
            );
          },
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _openEventReview() async {
    final envelope = _envelope;
    if (envelope == null || !envelope.canReview || _submittingReview) return;

    final workers = _eventReviewWorkers;
    if (workers.isEmpty) {
      setState(() {
        _actionError =
            'تعذر تحديد العمال الذين شاركوا في الجلسات المكتملة. حدّث الطلب وحاول مرة أخرى.';
      });
      return;
    }

    final result = await showDialog<List<_EventReviewDraft>>(
      context: context,
      builder: (dialogContext) => _EventReviewDialog(workers: workers),
    );
    if (!mounted || result == null || result.isEmpty) return;

    setState(() {
      _submittingReview = true;
      _actionError = null;
    });

    final Either<Failure, dynamic> response =
        await getIt<SubmitCleaningReviewUseCase>()(
          SubmitCleaningReviewParams(
            orderId: widget.orderId,
            reviews: result
                .map(
                  (review) => CleaningWorkerReviewInput(
                    workerId: review.workerId,
                    rating: review.rating,
                    comment: review.comment,
                  ),
                )
                .toList(growable: false),
          ),
        );

    if (!mounted) return;
    setState(() => _submittingReview = false);

    await response.fold(
      (failure) async {
        setState(() => _actionError = failure.message);
      },
      (_) async {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال تقييمات عمال المناسبة بنجاح')),
        );
        await _load();
      },
    );
  }

  Future<bool> _confirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('رجوع'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  )
                : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text(
          widget.recurring ? 'تفاصيل الحجز الدوري' : 'تفاصيل المناسبة',
        ),
        centerTitle: true,
        actions: [
          if (_canReschedule)
            IconButton(
              tooltip: widget.recurring
                  ? 'تعديل الزيارات'
                  : 'تعديل أيام المناسبة',
              onPressed: _openReschedule,
              icon: const Icon(Icons.edit_calendar_outlined),
            ),
        ],
      ),
      body: RefreshIndicator(onRefresh: _load, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
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
    final progressText = schedule.skippedDaysCount > 0
        ? '${schedule.completedDaysCount} من ${schedule.daysCount} جلسات مكتملة • ${schedule.skippedDaysCount} متخطاة'
        : '${schedule.completedDaysCount} من ${schedule.daysCount} جلسات مكتملة';

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 30),
      children: [
        if (_actionError != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: AppText.bodySmall(
              _actionError!,
              color: const Color(0xFF991B1B),
              fontWeight: FontWeight.w700,
              textAlign: TextAlign.start,
            ),
          ),
          const SizedBox(height: 12),
        ],
        _card(
          children: [
            Row(
              children: [
                Expanded(
                  child: AppText.titleMedium(
                    bookingNumber == null || bookingNumber.isEmpty
                        ? (widget.recurring
                              ? 'حجز تنظيف دوري - ${schedule.daysCount} زيارات'
                              : 'مساعدة مناسبة - ${schedule.daysCount} أيام')
                        : (widget.recurring
                              ? 'حجز تنظيف دوري #$bookingNumber'
                              : 'مساعدة مناسبة #$bookingNumber'),
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
                '${_money(_envelope!.totalPrice!)} ${_envelope?.currency ?? ''}'
                    .trim(),
              ),
            ],
          ],
        ),
        if (widget.recurring && schedule.hasRecurringSeriesState) ...[
          const SizedBox(height: 12),
          _recurringSeriesCard(schedule),
        ],
        if (!widget.recurring &&
            (_envelope?.canReview == true || _envelope?.hasReview == true)) ...[
          const SizedBox(height: 12),
          _eventReviewCard(),
        ],
        const SizedBox(height: 16),
        AppText.titleSmall(
          widget.recurring ? 'الزيارات' : 'أيام التنفيذ',
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
            widget.recurring
                ? 'كل زيارة مستقلة داخل نفس رقم الحجز. غياب عامل أو استبداله في زيارة لا يلغي الزيارات الأخرى.'
                : 'كل يوم هو جلسة تنفيذ مستقلة داخل نفس رقم الحجز. إكمال يوم لا يغلق المناسبة قبل انتهاء آخر جلسة مطلوبة.',
            color: const Color(0xFF1E3A8A),
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }

  Widget _recurringSeriesCard(CleaningBookingScheduleModel schedule) {
    final paused = schedule.isPaused;
    final busy = _busySeriesAction;

    return _card(
      children: [
        Row(
          children: [
            Icon(
              paused ? Icons.pause_circle_filled_rounded : Icons.repeat_rounded,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppText.bodyLarge(
                paused ? 'الحجز الدوري متوقف مؤقتاً' : 'إدارة الحجز الدوري',
                fontWeight: FontWeight.w800,
                textAlign: TextAlign.start,
              ),
            ),
            if (busy)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 8),
        AppText.bodySmall(
          paused
              ? 'الزيارات المستقبلية المتوقفة لا تُعرض للعمال حتى تستأنف هذا الحجز.'
              : 'يمكنك إيقاف الزيارات المستقبلية مؤقتاً دون إلغاء الحجز أو حذف الزيارات.',
          color: const Color(0xFF6B7280),
          fontWeight: FontWeight.w600,
          textAlign: TextAlign.start,
        ),
        if (schedule.pauseReason != null &&
            schedule.pauseReason!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          _infoRow('سبب الإيقاف', schedule.pauseReason!.trim()),
        ],
        if (!paused) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: busy || _busySessionId != null
                ? null
                : _openRecurringRevision,
            icon: const Icon(Icons.edit_calendar_outlined),
            label: const Text('تعديل الزيارات القادمة'),
          ),
        ],
        if (schedule.canResume) ...[
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: busy || _busySessionId != null
                ? null
                : _resumeRecurringSeries,
            icon: const Icon(Icons.play_circle_outline_rounded),
            label: const Text('استئناف الحجز الدوري'),
          ),
        ] else if (schedule.canPause) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: busy || _busySessionId != null
                ? null
                : _pauseRecurringSeries,
            icon: const Icon(Icons.pause_circle_outline_rounded),
            label: const Text('إيقاف الحجز مؤقتاً'),
          ),
        ],
      ],
    );
  }

  Widget _eventReviewCard() {
    final submitted = _envelope?.hasReview == true;

    return _card(
      children: [
        Row(
          children: [
            Icon(
              submitted ? Icons.star_rounded : Icons.star_border_rounded,
              color: const Color(0xFFF59E0B),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppText.bodyLarge(
                submitted ? 'تم تقييم عمال المناسبة' : 'تقييم عمال المناسبة',
                fontWeight: FontWeight.w800,
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AppText.bodySmall(
          submitted
              ? 'شكراً لك. تم حفظ تقييم مستقل لكل عامل شارك في المناسبة.'
              : 'بعد اكتمال المناسبة، قيّم كل عامل شارك فيها بشكل مستقل. يظهر العامل مرة واحدة حتى لو شارك في أكثر من يوم.',
          color: const Color(0xFF6B7280),
          fontWeight: FontWeight.w600,
          textAlign: TextAlign.start,
        ),
        if (!submitted) ...[
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _submittingReview ? null : _openEventReview,
            icon: _submittingReview
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.rate_review_outlined),
            label: const Text('تقييم عمال المناسبة'),
          ),
        ],
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
    final cancellationFee = session.pricing?.cancellationFee ?? 0;
    final highlighted =
        session.id != null && session.id == widget.initialSessionId;
    final busy = _busySessionId == session.id;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted
              ? Theme.of(context).colorScheme.primary
              : const Color(0xFFE5E7EB),
          width: highlighted ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText.bodyLarge(
                  widget.recurring
                      ? 'الزيارة ${session.sequence} من $totalDays'
                      : 'اليوم ${session.sequence} من $totalDays',
                  fontWeight: FontWeight.w800,
                  textAlign: TextAlign.start,
                ),
              ),
              if (busy) ...[
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
              ],
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
              '${_money(session.pricing!.totalPrice!)} ${session.pricing?.currency ?? _envelope?.currency ?? ''}'
                  .trim(),
            ),
          ],
          if (widget.recurring &&
              (session.isCompleted ||
                  session.paymentStatus == 'ready' ||
                  session.paymentStatus == 'settled')) ...[
            const SizedBox(height: 7),
            _infoRow(
              'التسوية المالية',
              _paymentStatusLabel(session.paymentStatus),
            ),
          ],
          if (widget.recurring &&
              session.attendance != null &&
              session.attendance!.incidents.isNotEmpty) ...[
            const SizedBox(height: 10),
            _attendanceIncidentPanel(session),
          ],
          if (widget.recurring && session.hasOpenDispute) ...[
            const SizedBox(height: 7),
            _infoRow('حالة النزاع', _disputeStatusLabel(session.disputeStatus)),
          ],
          if (session.isCancelled && cancellationFee > 0) ...[
            const SizedBox(height: 7),
            _infoRow(
              'رسوم إلغاء هذا اليوم',
              '${_money(cancellationFee)} ${session.pricing?.currency ?? _envelope?.currency ?? ''}'
                  .trim(),
            ),
          ],
          if (session.isCancelled &&
              session.cancellationReason != null &&
              session.cancellationReason!.trim().isNotEmpty) ...[
            const SizedBox(height: 7),
            _infoRow('سبب الإلغاء', session.cancellationReason!.trim()),
          ],
          if (session.isSkipped &&
              session.skipReason != null &&
              session.skipReason!.trim().isNotEmpty) ...[
            const SizedBox(height: 7),
            _infoRow('سبب التخطي', session.skipReason!.trim()),
          ],
          if (_hasActions(session)) ...[
            const SizedBox(height: 14),
            _sessionActions(session, busy),
          ],
        ],
      ),
    );
  }

  bool _hasActions(CleaningBookingSessionModel session) {
    return session.canConfirmStartVerification ||
        session.canConfirmCompletion ||
        session.canSkip ||
        session.canCancel ||
        session.canSendSos ||
        (widget.recurring &&
            (session.canReportLate ||
                session.canReportNoTravel ||
                session.canReview ||
                session.canOpenDispute));
  }

  Widget _sessionActions(CleaningBookingSessionModel session, bool busy) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (session.canConfirmStartVerification)
          FilledButton.icon(
            onPressed: busy ? null : () => _confirmStartVerification(session),
            icon: const Icon(Icons.password),
            label: const Text('إدخال رمز بدء هذا اليوم'),
          ),
        if (session.canConfirmCompletion) ...[
          if (session.canConfirmStartVerification) const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: busy ? null : () => _confirmCompletion(session),
            icon: const Icon(Icons.task_alt),
            label: Text(
              widget.recurring
                  ? 'تأكيد إكمال هذه الزيارة'
                  : 'تأكيد إكمال هذا اليوم',
            ),
          ),
        ],
        if (session.canSkip) ...[
          if (session.canConfirmStartVerification ||
              session.canConfirmCompletion)
            const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: busy ? null : () => _skipSession(session),
            icon: const Icon(Icons.skip_next_rounded),
            label: const Text('تخطي هذه الزيارة'),
          ),
        ],
        if (widget.recurring &&
            (session.canReportLate || session.canReportNoTravel)) ...[
          if (session.canConfirmStartVerification ||
              session.canConfirmCompletion ||
              session.canSkip)
            const SizedBox(height: 8),
          if (session.canReportNoTravel)
            FilledButton.icon(
              onPressed: busy ? null : () => _handleRecurringNoTravel(session),
              icon: const Icon(Icons.no_transfer_rounded),
              label: const Text('العامل لم يبدأ التنقل'),
            )
          else if (session.canReportLate)
            OutlinedButton.icon(
              onPressed: busy ? null : () => _reportRecurringLate(session),
              icon: const Icon(Icons.schedule_rounded),
              label: const Text('الإبلاغ عن تأخر العامل'),
            ),
        ],
        if (widget.recurring &&
            (session.canReview || session.canOpenDispute)) ...[
          if (session.canConfirmStartVerification ||
              session.canConfirmCompletion ||
              session.canSkip)
            const SizedBox(height: 8),
          Row(
            children: [
              if (session.canReview)
                Expanded(
                  child: FilledButton.icon(
                    onPressed: busy
                        ? null
                        : () => _reviewRecurringSession(session),
                    icon: const Icon(Icons.star_outline_rounded),
                    label: const Text('تقييم الزيارة'),
                  ),
                ),
              if (session.canReview && session.canOpenDispute)
                const SizedBox(width: 8),
              if (session.canOpenDispute)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: busy
                        ? null
                        : () => _openRecurringSessionDispute(session),
                    icon: const Icon(Icons.report_problem_outlined),
                    label: const Text('فتح نزاع'),
                  ),
                ),
            ],
          ),
        ],
        if (session.canCancel || session.canSendSos) ...[
          if (session.canConfirmStartVerification ||
              session.canConfirmCompletion ||
              session.canSkip)
            const SizedBox(height: 8),
          Row(
            children: [
              if (session.canSendSos)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: busy ? null : () => _sendSos(session),
                    icon: const Icon(Icons.sos_outlined),
                    label: const Text('SOS'),
                  ),
                ),
              if (session.canSendSos && session.canCancel)
                const SizedBox(width: 8),
              if (session.canCancel)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: busy ? null : () => _cancelSession(session),
                    icon: const Icon(Icons.event_busy_outlined),
                    label: Text(
                      widget.recurring ? 'إلغاء الزيارة' : 'إلغاء هذا اليوم',
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _attendanceIncidentPanel(CleaningBookingSessionModel session) {
    final incidents =
        session.attendance?.incidents ??
        const <CleaningSessionAttendanceIncidentModel>[];
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText.bodySmall(
            'بلاغات التأخر وعدم التنقل',
            fontWeight: FontWeight.w800,
            color: const Color(0xFF92400E),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 6),
          ...incidents.map((incident) {
            final worker = incident.workerName?.trim().isNotEmpty == true
                ? incident.workerName!.trim()
                : 'العامل #${incident.workerId ?? '-'}';
            final issue = incident.isNoTravel
                ? 'لم يبدأ التنقل'
                : 'تم الإبلاغ عن تأخره';
            final action = switch (incident.action) {
              'wait' => 'انتظار العامل',
              'replace' => 'طلب استبدال',
              'cancel' => 'إلغاء الزيارة دون رسوم',
              _ => 'بانتظار الإجراء',
            };
            final state = incident.isResolved ? 'مغلقة' : 'مفتوحة';
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: AppText.bodySmall(
                '$worker: $issue • $action • $state',
                color: const Color(0xFF78350F),
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.start,
              ),
            );
          }),
        ],
      ),
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
      case 'awaiting_worker_start_confirmation':
        return 'بانتظار بدء العامل';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'awaiting_customer_completion':
        return 'بانتظار تأكيد الإكمال';
      case 'completed':
        return 'مكتملة';
      case 'cancelled':
        return 'ملغاة';
      case 'skipped':
        return 'تم تخطيها';
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
      case 'skipped':
        return const Color(0xFFFEF3C7);
      case 'in_progress':
      case 'travel_started':
      case 'arrived':
      case 'awaiting_start_verification':
      case 'awaiting_customer_completion':
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
      case 'skipped':
        return const Color(0xFF92400E);
      case 'in_progress':
      case 'travel_started':
      case 'arrived':
      case 'awaiting_start_verification':
      case 'awaiting_customer_completion':
        return const Color(0xFF1D4ED8);
      default:
        return const Color(0xFF374151);
    }
  }

  String _paymentStatusLabel(String status) {
    switch (status.trim().toLowerCase()) {
      case 'ready':
        return 'بانتظار تأكيد إكمال الزيارة';
      case 'settled':
        return 'تمت تسوية الزيارة';
      case 'not_required':
        return 'لا توجد تسوية لهذه الزيارة';
      default:
        return 'قيد الانتظار';
    }
  }

  String _disputeStatusLabel(String? status) {
    switch (status?.trim().toLowerCase()) {
      case 'open':
        return 'مفتوح';
      case 'under_review':
        return 'قيد المراجعة';
      case 'resolved':
        return 'تم الحل';
      case 'closed':
        return 'مغلق';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'غير محدد';
    }
  }

  String _hours(double value) =>
      value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);

  String _money(double value) =>
      value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
}

class _RecurringSessionReviewDraft {
  const _RecurringSessionReviewDraft({
    required this.workerId,
    required this.rating,
    this.comment,
  });

  final int workerId;
  final int rating;
  final String? comment;
}

class _RecurringSessionReviewDialog extends StatefulWidget {
  const _RecurringSessionReviewDialog({required this.workers});

  final List<_EventReviewWorker> workers;

  @override
  State<_RecurringSessionReviewDialog> createState() =>
      _RecurringSessionReviewDialogState();
}

class _RecurringSessionReviewDialogState
    extends State<_RecurringSessionReviewDialog> {
  late int _workerId;
  int _rating = 0;
  final TextEditingController _comment = TextEditingController();

  @override
  void initState() {
    super.initState();
    _workerId = widget.workers.first.workerId;
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تقييم هذه الزيارة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.workers.length > 1) ...[
            DropdownButtonFormField<int>(
              initialValue: _workerId,
              decoration: const InputDecoration(labelText: 'العامل'),
              items: widget.workers
                  .map(
                    (worker) => DropdownMenuItem<int>(
                      value: worker.workerId,
                      child: Text(worker.workerName),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value != null) setState(() => _workerId = value);
              },
            ),
            const SizedBox(height: 12),
          ] else
            Text(
              widget.workers.first.workerName,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(5, (index) {
              final value = index + 1;
              return IconButton(
                onPressed: () => setState(() => _rating = value),
                icon: Icon(
                  Icons.star_rounded,
                  color: _rating >= value
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFFD1D5DB),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _comment,
            minLines: 2,
            maxLines: 4,
            maxLength: 1000,
            decoration: const InputDecoration(
              hintText: 'ملاحظات عن هذه الزيارة (اختياري)',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: _rating < 1
              ? null
              : () {
                  final comment = _comment.text.trim();
                  Navigator.of(context).pop(
                    _RecurringSessionReviewDraft(
                      workerId: _workerId,
                      rating: _rating,
                      comment: comment.isEmpty ? null : comment,
                    ),
                  );
                },
          child: const Text('إرسال التقييم'),
        ),
      ],
    );
  }
}

class _RecurringSessionDisputeDraft {
  const _RecurringSessionDisputeDraft({
    required this.category,
    required this.description,
  });

  final String category;
  final String description;
}

class _RecurringSessionDisputeDialog extends StatefulWidget {
  const _RecurringSessionDisputeDialog();

  @override
  State<_RecurringSessionDisputeDialog> createState() =>
      _RecurringSessionDisputeDialogState();
}

class _RecurringSessionDisputeDialogState
    extends State<_RecurringSessionDisputeDialog> {
  static const Map<String, String> _categories = <String, String>{
    'poor_quality': 'جودة الخدمة',
    'property_damage': 'ضرر بالممتلكات',
    'unprofessional': 'سلوك غير مهني',
    'billing_issue': 'مشكلة مالية',
    'financial_or_verbal_dispute': 'نزاع مالي أو لفظي',
    'other': 'سبب آخر',
  };

  String _category = 'poor_quality';
  final TextEditingController _description = TextEditingController();

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('فتح نزاع لهذه الزيارة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'نوع المشكلة'),
            items: _categories.entries
                .map(
                  (entry) => DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) setState(() => _category = value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _description,
            minLines: 3,
            maxLines: 6,
            maxLength: 1000,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'اشرح المشكلة الخاصة بهذه الزيارة',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: _description.text.trim().length < 3
              ? null
              : () => Navigator.of(context).pop(
                  _RecurringSessionDisputeDraft(
                    category: _category,
                    description: _description.text.trim(),
                  ),
                ),
          child: const Text('فتح النزاع'),
        ),
      ],
    );
  }
}

class _EventReviewWorker {
  const _EventReviewWorker({required this.workerId, required this.workerName});

  final int workerId;
  final String workerName;
}

class _EventReviewDraft {
  const _EventReviewDraft({
    required this.workerId,
    required this.rating,
    this.comment,
  });

  final int workerId;
  final int rating;
  final String? comment;
}

class _EventReviewDialog extends StatefulWidget {
  const _EventReviewDialog({required this.workers});

  final List<_EventReviewWorker> workers;

  @override
  State<_EventReviewDialog> createState() => _EventReviewDialogState();
}

class _EventReviewDialogState extends State<_EventReviewDialog> {
  final Map<int, int> _ratings = <int, int>{};
  final Map<int, TextEditingController> _commentControllers =
      <int, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    for (final worker in widget.workers) {
      _commentControllers[worker.workerId] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in _commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _allWorkersRated =>
      widget.workers.every((worker) => (_ratings[worker.workerId] ?? 0) >= 1);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تقييم عمال المناسبة'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'قيّم كل عامل شارك في المناسبة. العامل الذي شارك في عدة أيام يظهر مرة واحدة فقط.',
              ),
              const SizedBox(height: 14),
              ...widget.workers.map((worker) => _workerReviewCard(worker)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: !_allWorkersRated
              ? null
              : () {
                  final reviews = widget.workers
                      .map((worker) {
                        final comment =
                            _commentControllers[worker.workerId]?.text.trim() ??
                            '';
                        return _EventReviewDraft(
                          workerId: worker.workerId,
                          rating: _ratings[worker.workerId]!,
                          comment: comment.isEmpty ? null : comment,
                        );
                      })
                      .toList(growable: false);
                  Navigator.of(context).pop(reviews);
                },
          child: const Text('إرسال التقييمات'),
        ),
      ],
    );
  }

  Widget _workerReviewCard(_EventReviewWorker worker) {
    final rating = _ratings[worker.workerId] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            worker.workerName,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(5, (index) {
              final selected = rating >= index + 1;
              return IconButton(
                tooltip: '${index + 1} نجوم',
                onPressed: () =>
                    setState(() => _ratings[worker.workerId] = index + 1),
                icon: Icon(
                  Icons.star_rounded,
                  size: 32,
                  color: selected
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFFD1D5DB),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentControllers[worker.workerId],
            minLines: 2,
            maxLines: 4,
            maxLength: 1000,
            decoration: const InputDecoration(
              hintText: 'ملاحظات عن هذا العامل (اختياري)',
            ),
          ),
        ],
      ),
    );
  }
}
