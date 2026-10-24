import 'dart:async';

import 'package:common_package/helpers/dio_network.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/cleaning_date_time_ui_format.dart';
import '../../data/models/cleaning_orders_api_models.dart';
import '../../data/source/supervised_team_customer_api.dart';
import '../widgets/cleaning_accepted_workers_section_widget.dart';

class SupervisedTeamCustomerScreen extends StatefulWidget {
  const SupervisedTeamCustomerScreen({
    super.key,
    required this.orderId,
    this.order,
    this.api,
  });

  final int orderId;
  final CleaningOrderDetailModel? order;
  final SupervisedTeamCustomerApi? api;

  @override
  State<SupervisedTeamCustomerScreen> createState() =>
      _SupervisedTeamCustomerScreenState();
}

class _SupervisedTeamCustomerScreenState
    extends State<SupervisedTeamCustomerScreen> {
  late final SupervisedTeamCustomerApi _api;
  final _objection = TextEditingController();
  Timer? _poll;
  TeamJson? _snapshot;
  String? _error;
  bool _loading = false;
  bool _saving = false;
  bool _codeVisible = false;

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? SupervisedTeamCustomerApi(getIt<DioNetwork>());
    unawaited(_refresh());
    _poll = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!_saving) unawaited(_refresh());
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    _objection.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (_loading || _saving) return;
    _loading = true;
    try {
      final snapshot = await _api.fetch(widget.orderId);
      if (mounted) {
        setState(() {
          _snapshot = snapshot;
          _error = null;
        });
      }
    } on DioException catch (error) {
      if (mounted) setState(() => _error = _failureMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _failureMessage(DioException error) =>
      switch (error.response?.statusCode) {
        401 => 'انتهت الجلسة. سجّل الدخول مجدداً.',
        403 || 404 => 'هذا الطلب غير متاح لهذا الحساب.',
        409 => 'تغيّرت حالة الطلب. حدّث الصفحة لمراجعة آخر حالة.',
        _ => 'تعذّر إكمال الطلب. تحقق من الاتصال وأعد المحاولة.',
      };

  Future<void> _submit(Future<void> Function() decision) async {
    if (_saving || _loading) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    var succeeded = false;
    try {
      await decision();
      succeeded = true;
      _objection.clear();
    } on DioException catch (error) {
      if (mounted) setState(() => _error = _failureMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    if (mounted && succeeded) await _refresh();
  }

  Future<void> _showCode() async {
    if (_saving || _loading) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final challenge = await _api.verificationCode(widget.orderId);
      if (!mounted) return;
      final expiresAt = DateTime.parse(challenge['expiresAt'] as String);
      setState(() => _codeVisible = true);
      await showDialog<void>(
        context: context,
        builder: (_) => _VerificationCodeDialog(
          code: challenge['code'] as String,
          expiresAt: expiresAt,
        ),
      );
    } on DioException catch (error) {
      if (mounted) setState(() => _error = _failureMessage(error));
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
          _codeVisible = false;
        });
      }
    }
    if (mounted) await _refresh();
  }

  Widget _panel(String title, List<Widget> children) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    final booking = snapshot?['booking'] as Map? ?? {};
    final actions = snapshot?['allowedActions'] as List? ?? [];
    final handover = snapshot?['handover'] as Map? ?? {};
    final extensions = snapshot?['extensions'] as List? ?? [];
    final enabled = !_saving && !_loading && _error == null;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('متابعة فريق التنظيف')),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              if (_loading || (_saving && !_codeVisible))
                const LinearProgressIndicator(),
              if (_error != null)
                _panel('تعذّر تحديث الطلب', [
                  Text(_error!, semanticsLabel: _error),
                  TextButton(
                    onPressed: _loading || _saving ? null : _refresh,
                    child: const Text('إعادة المحاولة'),
                  ),
                ]),
              if (snapshot != null) ...[
                _panel('طلب ${booking['bookingNumber'] ?? widget.orderId}', [
                  Text(
                    _stageLabel(
                      booking['status'] == 'cancelled'
                          ? 'cancelled'
                          : booking['teamState'] as String?,
                    ),
                  ),
                  Text(
                    'حضور الفريق: ${booking['arrivedWorkers']} من ${booking['requiredWorkers']}',
                  ),
                  if (booking['scheduledEndAt'] != null)
                    Text(
                      'نهاية الوقت المحدد: ${CleaningDateTimeUiFormat.timeFromDateTime(DateTime.parse(booking['scheduledEndAt'] as String).toLocal())}',
                    ),
                ]),
                if (widget.order?.acceptedWorkerAssignments.isNotEmpty == true)
                  CleaningAcceptedWorkersSectionWidget(
                    assignments: widget.order!.acceptedWorkerAssignments,
                  ),
                if (actions.contains('view_verification_code'))
                  _panel('رمز بدء الخدمة', [
                    const Text(
                      'اعرض الرمز وأعطه للمشرف عند استعداد الفريق لبدء الخدمة.',
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: enabled ? _showCode : null,
                      icon: const Icon(Icons.lock_outline),
                      label: const Text('عرض رمز البدء'),
                    ),
                  ]),
                for (final extension in extensions.where(
                  (entry) => (entry as Map)['status'] == 'pending',
                ))
                  _panel('طلب وقت إضافي', [
                    Text('${extension['additionalMinutes']} دقيقة إضافية'),
                    Text(extension['reason'] as String),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: enabled && actions.contains('decide_extension')
                          ? () => _submit(
                              () => _api.decideExtension(
                                widget.orderId,
                                extension['id'] as int,
                                true,
                              ),
                            )
                          : null,
                      child: const Text('الموافقة على التمديد'),
                    ),
                    OutlinedButton(
                      onPressed: enabled && actions.contains('decide_extension')
                          ? () => _submit(
                              () => _api.decideExtension(
                                widget.orderId,
                                extension['id'] as int,
                                false,
                              ),
                            )
                          : null,
                      child: const Text('رفض التمديد'),
                    ),
                  ]),
                if (actions.contains('decide_handover'))
                  _panel('استلام الخدمة', [
                    const Text(
                      'أبلغ المشرف بانتهاء العمل. راجع الخدمة ثم أكد الاستلام أو سجّل اعتراضك.',
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: enabled
                          ? () => _submit(
                              () => _api.decideHandover(widget.orderId),
                            )
                          : null,
                      child: const Text('تأكيد استلام الخدمة'),
                    ),
                    TextField(
                      controller: _objection,
                      enabled: enabled,
                      minLines: 2,
                      maxLines: 4,
                      maxLength: 2000,
                      decoration: const InputDecoration(
                        labelText: 'سبب الاعتراض',
                        helperText: 'اكتب 5 أحرف على الأقل',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    OutlinedButton(
                      onPressed:
                          enabled && _objection.text.trim().runes.length >= 5
                          ? () => _submit(
                              () => _api.decideHandover(
                                widget.orderId,
                                objection: _objection.text.trim(),
                              ),
                            )
                          : null,
                      child: const Text('إرسال الاعتراض'),
                    ),
                  ]),
                if (handover['status'] == 'confirmed')
                  _panel('تم تأكيد الاستلام', [
                    const Text(
                      'تم تسجيل موافقتك. المشرف مسؤول عن اعتماد التقرير النهائي.',
                    ),
                  ]),
                if (handover['status'] == 'objected')
                  _panel('تم تسجيل اعتراضك', [
                    Text(handover['customerNote'] as String? ?? ''),
                  ]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _stageLabel(String? stage) => switch (stage) {
  'verification_pending' => 'بانتظار التحقق لبدء الخدمة',
  'verified' => 'تم التحقق. بانتظار بدء المشرف',
  'in_progress' => 'الخدمة قيد التنفيذ',
  'handover_pending' => 'بانتظار استلام الخدمة',
  'handover_confirmed' => 'بانتظار التقرير النهائي',
  'handover_objected' => 'الاعتراض قيد المراجعة',
  'completed' => 'اكتملت الخدمة',
  'cancelled' => 'تم إلغاء الطلب',
  _ => 'جارٍ تجهيز الفريق',
};

class _VerificationCodeDialog extends StatefulWidget {
  const _VerificationCodeDialog({required this.code, required this.expiresAt});
  final String code;
  final DateTime expiresAt;

  @override
  State<_VerificationCodeDialog> createState() =>
      _VerificationCodeDialogState();
}

class _VerificationCodeDialogState extends State<_VerificationCodeDialog>
    with WidgetsBindingObserver {
  Timer? _expiry;
  bool _dismissed = false;

  void _dismiss() {
    if (_dismissed || !mounted) return;
    _dismissed = true;
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _expiry = Timer(widget.expiresAt.difference(DateTime.now()), _dismiss);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _dismiss();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _expiry?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('رمز بدء الخدمة'),
    content: Text(
      widget.code,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineLarge,
    ),
    actions: [TextButton(onPressed: _dismiss, child: const Text('إغلاق'))],
  );
}
