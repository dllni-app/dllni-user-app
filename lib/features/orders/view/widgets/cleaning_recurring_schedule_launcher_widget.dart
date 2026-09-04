import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';

import '../../data/source/cleaning_session_remote_data_source.dart';
import '../screens/multi_day_cleaning_order_details_screen.dart';

typedef CleaningRecurringScheduleReturnCallback = Future<void> Function();

class CleaningRecurringScheduleLauncherWidget extends StatefulWidget {
  const CleaningRecurringScheduleLauncherWidget({
    super.key,
    required this.orderId,
    this.onReturn,
  });

  final int orderId;
  final CleaningRecurringScheduleReturnCallback? onReturn;

  @override
  State<CleaningRecurringScheduleLauncherWidget> createState() =>
      _CleaningRecurringScheduleLauncherWidgetState();
}

class _CleaningRecurringScheduleLauncherWidgetState
    extends State<CleaningRecurringScheduleLauncherWidget> {
  bool _visible = false;

  CleaningSessionRemoteDataSource get _sessions =>
      getIt<CleaningSessionRemoteDataSource>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(
    covariant CleaningRecurringScheduleLauncherWidget oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderId != widget.orderId) {
      _visible = false;
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final envelope = await _sessions.fetchBookingSchedule(widget.orderId);
      final schedule = envelope.schedule;
      final isRecurring =
          schedule != null &&
          schedule.sessions.any(
            (session) => session.sessionType == 'recurring_cleaning',
          );
      if (!mounted) return;
      setState(() => _visible = isRecurring);
    } catch (_) {
      if (!mounted) return;
      setState(() => _visible = false);
    }
  }

  Future<void> _open() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => MultiDayCleaningOrderDetailsScreen(
          orderId: widget.orderId,
          recurring: true,
        ),
      ),
    );
    if (!mounted) return;
    await _load();
    final callback = widget.onReturn;
    if (callback != null) await callback();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _open,
          icon: const Icon(Icons.repeat_rounded),
          label: const Text('عرض الزيارات الدورية وإدارتها'),
        ),
      ),
    );
  }
}
