import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/models/cleaning_service_extras.dart';
import '../../data/source/orders_remote_data_source.dart';

class CleaningOpenTimeLiveCard extends StatefulWidget {
  const CleaningOpenTimeLiveCard({
    required this.orderId,
    required this.initialValue,
    this.sessionId,
    this.onChanged,
    super.key,
  });

  final int orderId;
  final CleaningOpenTimeModel initialValue;
  final int? sessionId;
  final ValueChanged<CleaningOpenTimeModel>? onChanged;

  @override
  State<CleaningOpenTimeLiveCard> createState() =>
      _CleaningOpenTimeLiveCardState();
}

class _CleaningOpenTimeLiveCardState extends State<CleaningOpenTimeLiveCard> {
  late CleaningOpenTimeModel _value;
  late DateTime _snapshotReceivedAt;
  Timer? _ticker;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _snapshotReceivedAt = DateTime.now();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _value.ceilingEndsAt != null) setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant CleaningOpenTimeLiveCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue && !_submitting) {
      _value = widget.initialValue;
      _snapshotReceivedAt = DateTime.now();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Duration? get _remaining {
    final ceiling = _value.ceilingEndsAt;
    if (ceiling == null) return null;
    final serverNow = _value.serverNow?.toLocal() ?? _snapshotReceivedAt;
    final estimatedNow = serverNow.add(
      DateTime.now().difference(_snapshotReceivedAt),
    );
    final difference = ceiling.toLocal().difference(estimatedNow);
    return difference.isNegative ? Duration.zero : difference;
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _remaining;
    final isRunning =
        _value.ceilingEndsAt != null &&
        _value.isPricingFinal != true &&
        _value.endStatus != 'accepted';
    final pending = _value.pendingExtension?.status == 'pending';
    final requiresSessionSelection =
        widget.sessionId == null && _value.isMultiSession;
    return Semantics(
      container: true,
      label: 'متابعة الطلب المفتوح',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'الطلب بوقت مفتوح',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _StatusBadge(
                  label: _statusLabel(isRunning),
                  color: isRunning
                      ? const Color(0xFF166534)
                      : const Color(0xFF475569),
                ),
              ],
            ),
            if (remaining != null) ...[
              const SizedBox(height: 16),
              Text(
                'الوقت المتبقي',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Semantics(
                liveRegion: true,
                value: _durationText(remaining),
                child: Text(
                  _clockText(remaining),
                  textDirection: TextDirection.ltr,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_value.liveAmount != null)
                  _Metric(
                    label: 'المبلغ الجاري',
                    value:
                        '${_value.liveAmount!.toStringAsFixed(0)} ${_value.currency ?? 'SYP'}',
                  ),
                if (_value.liveBillableMinutes != null)
                  _Metric(
                    label: 'المدة المحتسبة',
                    value: '${_value.liveBillableMinutes} دقيقة',
                  ),
                if (_value.expectedMaxMinutes != null)
                  _Metric(
                    label: 'السقف الحالي',
                    value: '${_value.expectedMaxMinutes} دقيقة',
                  ),
              ],
            ),
            if (pending) ...[
              const SizedBox(height: 12),
              const _InlineNotice(
                icon: Icons.hourglass_top_rounded,
                message: 'طلب التمديد بانتظار موافقة العامل الحالي.',
              ),
            ],
            if (_value.endStatus == 'pending') ...[
              const SizedBox(height: 12),
              const _InlineNotice(
                icon: Icons.pending_actions_outlined,
                message: 'طلب الإنهاء بانتظار موافقة العامل.',
              ),
            ],
            if (requiresSessionSelection) ...[
              const SizedBox(height: 12),
              const _InlineNotice(
                icon: Icons.view_timeline_outlined,
                message:
                    'اختر الجلسة المطلوبة من قائمة جلسات الوقت المفتوح لإرسال تمديد أو طلب إنهاء.',
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              _InlineNotice(
                icon: Icons.error_outline,
                message: _error!,
                isError: true,
              ),
            ],
            if (isRunning && !requiresSessionSelection) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _submitting || pending ? null : _extend,
                        icon: const Icon(Icons.more_time_outlined),
                        label: const Text('طلب تمديد'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: _submitting || _value.endStatus == 'pending'
                            ? null
                            : _requestEnd,
                        icon: _submitting
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.stop_circle_outlined),
                        label: const Text('طلب إنهاء'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _statusLabel(bool isRunning) {
    if (_value.isPricingFinal == true) return 'مكتمل';
    if (_value.endStatus == 'pending') return 'إنهاء معلّق';
    return isRunning ? 'قيد التنفيذ' : 'بانتظار البدء';
  }

  Future<void> _extend() async {
    final options = _value.extensionOptions;
    if (options.isEmpty) {
      setState(() => _error = 'لا توجد مدة تمديد متاحة حالياً.');
      return;
    }
    final minutes = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => _ExtensionPicker(options: options),
    );
    if (minutes == null || !mounted) return;
    await _run(
      () => getIt<OrdersRemoteDataSource>().requestCleaningOpenTimeExtension(
        orderId: widget.orderId,
        sessionId: widget.sessionId,
        minutes: minutes,
        idempotencyKey:
            'open-time-${widget.orderId}-$minutes-${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
  }

  Future<void> _requestEnd() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('طلب إنهاء الخدمة؟'),
        content: const Text(
          'سيُرسل الطلب للعامل للموافقة، ثم تُحسب الفاتورة حسب الوقت الفعلي.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('رجوع'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('إرسال الطلب'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _run(
      () => getIt<OrdersRemoteDataSource>().requestCleaningOpenTimeEnd(
        widget.orderId,
        sessionId: widget.sessionId,
      ),
    );
  }

  Future<void> _run(Future<CleaningOpenTimeModel> Function() action) async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final updated = await action();
      if (!mounted) return;
      setState(() {
        _value = updated;
        _snapshotReceivedAt = DateTime.now();
      });
      widget.onChanged?.call(updated);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إرسال الطلب بنجاح.')));
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'تعذر تنفيذ الإجراء. حاول مرة أخرى.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class _ExtensionPicker extends StatelessWidget {
  const _ExtensionPicker({required this.options});

  final List<int> options;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 20 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'اختر مدة التمديد',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('لن يُطبق التمديد إلا بعد موافقة العامل وفحص التعارض.'),
          const SizedBox(height: 16),
          for (final minutes in options) ...[
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, minutes),
                child: Text('$minutes دقيقة'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({
    required this.icon,
    required this.message,
    this.isError = false,
  });

  final IconData icon;
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? const Color(0xFFB91C1C) : const Color(0xFF92400E);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

String _clockText(Duration value) {
  final hours = value.inHours.toString().padLeft(2, '0');
  final minutes = (value.inMinutes % 60).toString().padLeft(2, '0');
  final seconds = (value.inSeconds % 60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}

String _durationText(Duration value) {
  return '${value.inHours} ساعة و${value.inMinutes % 60} دقيقة';
}
