import 'dart:async';
import 'dart:convert';

import 'package:common_package/common_package.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:dio/dio.dart';
import 'package:dllni_user_app/core/app_config.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/extensions/num_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../cl_main/view/widgets/cl_service_address_section_widget.dart';
import '../../../cl_main/view/widgets/cl_service_day_preview_card_widget.dart';
import '../../../cl_main/view/widgets/cl_service_section_card_widget.dart';
import '../../../cl_main/view/widgets/cl_service_time_picker_field_widget.dart';
import '../../data/models/cleaning_orders_api_models.dart';
import '../../domain/usecases/confirm_cleaning_completion_use_case.dart';
import '../../domain/usecases/confirm_cleaning_start_verification_use_case.dart';
import '../../domain/usecases/extend_cleaning_completion_time_use_case.dart';
import '../../domain/usecases/fetch_cleaning_order_details_use_case.dart';
import '../../domain/usecases/reject_cleaning_completion_use_case.dart';
import '../../../profile/view/widgets/personal_details_app_bar.dart';
import '../manager/bloc/orders_bloc.dart';
import '../widgets/cleaning_cancel_reason_dialog.dart';
import 'cleaning_order_problem_report_screen.dart';
import 'cleaning_order_reschedule_screen.dart';

const String _kCleaningPusherKey = 'e85e7756c1171baaa471';
const String _kCleaningPusherCluster = 'eu';

class CleaningOrderDetailsArgs {
  const CleaningOrderDetailsArgs({required this.orderId});

  final int orderId;
}

@AutoRoutePage(path: '/cleaning-order-details')
class CleaningOrderDetailsScreen extends StatefulWidget {
  const CleaningOrderDetailsScreen({super.key, required this.args});

  final CleaningOrderDetailsArgs args;

  @override
  State<CleaningOrderDetailsScreen> createState() => _CleaningOrderDetailsScreenState();
}

class _CleaningOrderDetailsScreenState extends State<CleaningOrderDetailsScreen> {
  CleaningOrderDetailModel? _order;
  bool _isLoading = true;
  String? _loadError;
  late TextEditingController _fromTimeController;
  late TextEditingController _toTimeController;
  late TextEditingController _pinController;

  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  String? _cleaningPusherChannelName;
  double? _workerLiveLatitude;
  double? _workerLiveLongitude;

  String? _gateError;
  bool _gateSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fromTimeController = TextEditingController();
    _toTimeController = TextEditingController();
    _pinController = TextEditingController();
    _fetchDetails();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_connectCleaningPusher());
    });
  }

  @override
  void dispose() {
    final channel = _cleaningPusherChannelName;
    if (channel != null) {
      unawaited(_pusher.unsubscribe(channelName: channel).catchError((Object _) {}));
    }
    unawaited(_pusher.disconnect().catchError((Object _) {}));
    _fromTimeController.dispose();
    _toTimeController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  String _normStatus(String? status) => (status ?? '').toLowerCase();

  bool _blocksCancel(CleaningOrderDetailModel order) {
    final s = _normStatus(order.status);
    return s == 'awaiting_start_verification' || s == 'awaiting_customer_completion';
  }

  bool _blocksReschedule(CleaningOrderDetailModel order) {
    final s = _normStatus(order.status);
    return s == 'awaiting_start_verification' ||
        s == 'awaiting_customer_completion' ||
        s == 'in_progress' ||
        s == 'time_extension_requested';
  }

  Future<void> _connectCleaningPusher() async {
    if (!mounted) return;
    final bookingId = widget.args.orderId;
    final channelName = 'private-cleaning-booking.$bookingId';
    _cleaningPusherChannelName = channelName;
    try {
      await _pusher.init(
        apiKey: _kCleaningPusherKey,
        cluster: _kCleaningPusherCluster,
        authEndpoint: '${AppConfig.baseUrl}/broadcasting/auth',
        onAuthorizer: (channelName_, socketId, dynamic options) async {
          final token = (SharedPreferencesHelper.getData(key: 'token') ?? '').toString();
          final res = await DioNetwork.dio.post<Map<String, dynamic>>(
            '/broadcasting/auth',
            data: <String, dynamic>{'channel_name': channelName_, 'socket_id': socketId},
            options: Options(
              headers: <String, dynamic>{
                'Accept': 'application/json',
                if (token.isNotEmpty) 'Authorization': 'Bearer $token',
              },
              contentType: Headers.formUrlEncodedContentType,
              responseType: ResponseType.json,
            ),
          );
          final body = res.data;
          if (body == null || body['auth'] == null) {
            throw StateError('Invalid broadcasting auth response');
          }
          return <String, dynamic>{
            'auth': body['auth'],
            if (body['channel_data'] != null) 'channel_data': body['channel_data'],
          };
        },
        onSubscriptionError: (message, e) {
          debugPrint('Cleaning Pusher subscription error: $message $e');
        },
        onError: (message, code, e) {
          debugPrint('Cleaning Pusher error: $message code=$code $e');
        },
        onEvent: _onCleaningPusherEvent,
      );
      if (!mounted) return;
      await _pusher.connect();
      if (!mounted) return;
      await _pusher.subscribe(channelName: channelName);
    } catch (e, st) {
      debugPrint('Cleaning Pusher connect failed: $e\n$st');
    }
  }

  void _onCleaningPusherEvent(PusherEvent event) {
    final expected = _cleaningPusherChannelName;
    if (expected == null || event.channelName != expected) {
      return;
    }
    if (event.eventName == 'WorkerLocationUpdated') {
      _applyWorkerLocation(event.data);
      return;
    }
    switch (event.eventName) {
      case 'CleaningBookingTrackingUpdated':
      case 'WorkerArrived':
      case 'cleaning_order.awaiting_start_verification':
      case 'cleaning_order.awaiting_customer_completion':
      case 'ArrivalVerified':
      case 'CompletionDecisionMade':
      case 'ServiceExtensionRequested':
        unawaited(_fetchDetails(showLoading: false));
        return;
      default:
        return;
    }
  }

  void _applyWorkerLocation(dynamic raw) {
    try {
      final Map<String, dynamic> map;
      if (raw is String) {
        final decoded = jsonDecode(raw);
        if (decoded is! Map) {
          return;
        }
        map = _toStringKeyMap(decoded);
      } else if (raw is Map) {
        map = _toStringKeyMap(raw);
      } else {
        return;
      }
      final lat = map['latitude'];
      final lng = map['longitude'];
      final latVal = lat is num ? lat.toDouble() : double.tryParse('$lat');
      final lngVal = lng is num ? lng.toDouble() : double.tryParse('$lng');
      if (latVal == null || lngVal == null || !mounted) {
        return;
      }
      setState(() {
        _workerLiveLatitude = latVal;
        _workerLiveLongitude = lngVal;
      });
    } catch (e, st) {
      debugPrint('WorkerLocationUpdated parse failed: $e\n$st');
    }
  }

  Map<String, dynamic> _toStringKeyMap(Map raw) {
    return raw.map((dynamic k, dynamic v) => MapEntry(k.toString(), v));
  }

  Future<void> _fetchDetails({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }
    final Either<Failure, FetchCleaningOrderDetailsModel> response = await getIt<FetchCleaningOrderDetailsUseCase>()(
      FetchCleaningOrderDetailsParams(orderId: widget.args.orderId),
    );
    if (!mounted) return;
    response.fold(
      (failure) => setState(() {
        if (showLoading) {
          _isLoading = false;
          _loadError = failure.message;
        }
      }),
      (result) => setState(() {
        if (showLoading) {
          _isLoading = false;
        }
        _order = result.data;
        if (showLoading) {
          _loadError = result.data == null ? 'تعذر تحميل تفاصيل الطلب' : null;
        }
      }),
    );
  }

  Future<void> _submitStartVerification(CleaningOrderDetailModel order) async {
    final orderId = order.id;
    if (orderId == null) return;
    final code = _pinController.text.trim();
    if (code.length != 4) {
      setState(() => _gateError = 'الرجاء إدخال 4 أرقام');
      return;
    }
    setState(() {
      _gateSubmitting = true;
      _gateError = null;
    });
    final response = await getIt<ConfirmCleaningStartVerificationUseCase>()(
      ConfirmCleaningStartVerificationParams(orderId: orderId, code: code),
    );
    if (!mounted) return;
    response.fold(
      (failure) => setState(() {
        _gateSubmitting = false;
        _gateError = failure.message;
      }),
      (result) {
        setState(() {
          _gateSubmitting = false;
          _gateError = null;
          _order = result.data;
          _pinController.clear();
        });
      },
    );
  }

  Future<void> _submitCompletionConfirm(CleaningOrderDetailModel order) async {
    final orderId = order.id;
    if (orderId == null) return;
    setState(() {
      _gateSubmitting = true;
      _gateError = null;
    });
    final response = await getIt<ConfirmCleaningCompletionUseCase>()(
      ConfirmCleaningCompletionParams(orderId: orderId),
    );
    if (!mounted) return;
    response.fold(
      (failure) => setState(() {
        _gateSubmitting = false;
        _gateError = failure.message;
      }),
      (result) => setState(() {
        _gateSubmitting = false;
        _gateError = null;
        _order = result.data;
      }),
    );
  }

  Future<void> _submitCompletionReject(CleaningOrderDetailModel order, String? reason) async {
    final orderId = order.id;
    if (orderId == null) return;
    setState(() {
      _gateSubmitting = true;
      _gateError = null;
    });
    final response = await getIt<RejectCleaningCompletionUseCase>()(
      RejectCleaningCompletionParams(orderId: orderId, reason: reason),
    );
    if (!mounted) return;
    response.fold(
      (failure) => setState(() {
        _gateSubmitting = false;
        _gateError = failure.message;
      }),
      (result) => setState(() {
        _gateSubmitting = false;
        _gateError = null;
        _order = result.data;
      }),
    );
  }

  Future<void> _submitExtendTime(CleaningOrderDetailModel order, int? additionalMinutes) async {
    final orderId = order.id;
    if (orderId == null) return;
    setState(() {
      _gateSubmitting = true;
      _gateError = null;
    });
    final response = await getIt<ExtendCleaningCompletionTimeUseCase>()(
      ExtendCleaningCompletionTimeParams(orderId: orderId, additionalMinutes: additionalMinutes),
    );
    if (!mounted) return;
    response.fold(
      (failure) => setState(() {
        _gateSubmitting = false;
        _gateError = failure.message;
      }),
      (result) => setState(() {
        _gateSubmitting = false;
        _gateError = null;
        _order = result.data;
      }),
    );
  }

  Future<void> _showRejectCompletionDialog(CleaningOrderDetailModel order) async {
    final controller = TextEditingController();
    final submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('لم يكتمل العمل'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText: 'سبب اختياري',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('إرسال'),
            ),
          ],
        );
      },
    );
    final reasonText = controller.text.trim();
    controller.dispose();
    if (submitted == true && mounted) {
      await _submitCompletionReject(order, reasonText.isEmpty ? null : reasonText);
    }
  }

  Future<void> _showExtendTimeDialog(CleaningOrderDetailModel order) async {
    final controller = TextEditingController(text: '30');
    final submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('طلب وقت إضافي'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'دقائق إضافية (1–480)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('تأكيد'),
            ),
          ],
        );
      },
    );
    final raw = controller.text.trim();
    controller.dispose();
    if (submitted != true || !mounted) return;
    final minutes = int.tryParse(raw);
    if (minutes == null || minutes < 1 || minutes > 480) {
      setState(() => _gateError = 'أدخل عدد دقائق بين 1 و 480');
      return;
    }
    await _submitExtendTime(order, minutes);
  }

  String _serviceLabel(String? propertyType) {
    switch ((propertyType ?? '').toLowerCase()) {
      case 'studio':
        return 'تنظيف ستوديو';
      case 'apartment':
        return 'تنظيف شقة';
      case 'house':
        return 'تنظيف منزل';
      case 'villa':
        return 'تنظيف فيلا';
      default:
        return 'تنظيف منزل';
    }
  }

  String _bookingLabel(CleaningOrderDetailModel order) {
    final bookingNumber = order.bookingNumber;
    if (bookingNumber == null || bookingNumber.isEmpty) {
      return '#${order.id ?? '-'}';
    }
    return '#$bookingNumber';
  }

  DateTime? _resolveStartDateTime(CleaningOrderDetailModel order) {
    final date = order.scheduledDate;
    final time = order.scheduledTime;
    if (date == null || date.isEmpty || time == null || time.isEmpty) {
      return null;
    }
    final raw = '$date ${time.split('.').first}';
    return DateTime.tryParse(raw);
  }

  double _resolveHours(CleaningOrderDetailModel order) {
    final total = order.totalHours;
    if (total != null && total > 0) return total;
    return double.tryParse(order.estimatedHours ?? '') ?? 0;
  }

  String _timeLabel(DateTime? value) {
    if (value == null) return '-';
    final hour = value.hour;
    final minute = value.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final normalizedHour = hour % 12 == 0 ? 12 : hour % 12;
    return '${normalizedHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  String _dayLabel(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '-';
    final date = DateTime.tryParse(rawDate);
    if (date == null) return '-';
    const arabicDays = <String>['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
    return arabicDays[date.weekday - 1];
  }

  String _dayDateEnLabel(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '-';
    final date = DateTime.tryParse(rawDate);
    if (date == null) return '-';
    return DateFormat('d MMM yyyy', 'en').format(date);
  }

  Widget _card({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }

  Future<void> _callWorker(String? phone) async {
    final value = phone?.trim();
    if (value == null || value.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('رقم الهاتف غير متوفر')));
      return;
    }
    final uri = Uri(scheme: 'tel', path: value);
    final launched = await launchUrl(uri);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر فتح تطبيق الاتصال')));
    }
  }

  Future<void> _goToReschedule(CleaningOrderDetailModel order) async {
    if (_blocksReschedule(order)) {
      return;
    }
    final result = await context.pushRoute('/cleaning-order-reschedule', arguments: CleaningOrderRescheduleArgs(order: order.toCleaningOrderModel()));
    if (result == true && mounted) {
      _fetchDetails();
    }
  }

  void _reportIssue(CleaningOrderDetailModel order) {
    context.pushRoute('/cleaning-order-problem', arguments: CleaningOrderProblemReportArgs(order: order.toCleaningOrderModel()));
  }

  Future<void> _cancelOrder(CleaningOrderDetailModel order) async {
    if (_blocksCancel(order)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أكمل خطوة التحقق أو تأكيد الإكمال قبل الإلغاء')),
      );
      return;
    }
    final orderId = order.id;
    if (orderId == null) return;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CleaningCancelReasonDialog(orderId: orderId, bloc: context.read<OrdersBloc>()),
    );
    if (result == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xffF3F4F6),
        appBar: AppBar(title: const Text('تفاصيل الطلب'), centerTitle: true, backgroundColor: const Color(0xffF3F4F6), elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadError != null) {
      return Scaffold(
        backgroundColor: const Color(0xffF3F4F6),
        appBar: AppBar(title: const Text('تفاصيل الطلب'), centerTitle: true, backgroundColor: const Color(0xffF3F4F6), elevation: 0),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_loadError!, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                TextButton(onPressed: () => _fetchDetails(showLoading: true), child: const Text('إعادة المحاولة')),
              ],
            ),
          ),
        ),
      );
    }
    if (order == null) {
      return Scaffold(
        backgroundColor: const Color(0xffF3F4F6),
        body: const SafeArea(
          child: Column(
            children: [
              PersonalDetailsAppBar(title: 'تفاصيل الطلب'),
              Expanded(child: Center(child: Text('تعذر تحميل تفاصيل الطلب'))),
            ],
          ),
        ),
      );
    }
    final startDateTime = _resolveStartDateTime(order);
    final endDateTime = startDateTime?.add(Duration(minutes: (_resolveHours(order) * 60).round()));
    _fromTimeController.text = _timeLabel(startDateTime);
    _toTimeController.text = _timeLabel(endDateTime);
    final isCompleted = _normStatus(order.status) == 'completed';
    final statusNorm = _normStatus(order.status);
    final rescheduleLocked = _blocksReschedule(order);

    return Scaffold(
      backgroundColor: const Color(0xffF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            const PersonalDetailsAppBar(title: 'تفاصيل الطلب'),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchDetails(showLoading: false),
                child: ListView(
                  padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 24),
                  children: [
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'معلومات الخدمة',
                            style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xff1F2937)),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _bookingLabel(order),
                                  style: const TextStyle(color: Color(0xff9CA3AF), fontWeight: FontWeight.w600),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(color: const Color(0xFFE2F5F4), borderRadius: BorderRadius.circular(16)),
                                child: Text(
                                  cleaningOrderStatusLabelAr(order.status),
                                  style: const TextStyle(color: Color(0xff0CBBC7), fontWeight: FontWeight.w700, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _serviceLabel(order.propertyType),
                            style: const TextStyle(color: Color(0xff111827), fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    if (statusNorm == 'awaiting_start_verification') ...[
                      const SizedBox(height: 12),
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'التحقق من بدء الخدمة',
                              style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xff1F2937)),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'أدخل الرمز المكوّن من 4 أرقام الذي يظهره لك مقدم الخدمة. لا يُعرض الرمز في التطبيق.',
                              style: TextStyle(color: Color(0xff6B7280), fontSize: 13),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _pinController,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              obscureText: true,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 22, letterSpacing: 8, fontWeight: FontWeight.w700),
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: const InputDecoration(
                                counterText: '',
                                border: OutlineInputBorder(),
                                hintText: '••••',
                              ),
                            ),
                            if (_gateError != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _gateError!,
                                style: const TextStyle(color: Color(0xffDC2626), fontSize: 13),
                              ),
                            ],
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: _gateSubmitting ? null : () => _submitStartVerification(order),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF1E2A78),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: _gateSubmitting
                                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('تأكيد الرمز', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (statusNorm == 'awaiting_customer_completion') ...[
                      const SizedBox(height: 12),
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'تأكيد إكمال العمل',
                              style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xff1F2937)),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'أبلغ مقدم الخدمة عن انتهاء العمل. يمكنك تأكيد الإكمال أو الإبلاغ بأن العمل لم يكتمل، أو طلب وقت إضافي.',
                              style: TextStyle(color: Color(0xff6B7280), fontSize: 13),
                            ),
                            if (_gateError != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _gateError!,
                                style: const TextStyle(color: Color(0xffDC2626), fontSize: 13),
                              ),
                            ],
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: _gateSubmitting ? null : () => _submitCompletionConfirm(order),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF0CBBC7),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: _gateSubmitting
                                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('تأكيد الإكمال', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton(
                              onPressed: _gateSubmitting ? null : () => _showRejectCompletionDialog(order),
                              child: const Text('العمل لم يكتمل بعد'),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: _gateSubmitting ? null : () => _showExtendTimeDialog(order),
                              child: const Text('طلب وقت إضافي'),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (statusNorm == 'time_extension_requested') ...[
                      const SizedBox(height: 12),
                      _card(
                        child: const Row(
                          children: [
                            Icon(Icons.schedule, color: Color(0xff1E2A78)),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'تم إرسال طلب تمديد الوقت. سيتم إشعارك عند تحديث الحالة.',
                                style: TextStyle(color: Color(0xff374151), fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    ClServiceSectionCardWidget(
                      step: 1,
                      showStepBadge: false,
                      title: 'وقت و تاريخ الخدمة',
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ClServiceDayPreviewCardWidget(dayAr: _dayLabel(order.scheduledDate), dayDate: _dayDateEnLabel(order.scheduledDate)),
                              ),
                              const SizedBox(width: 10),
                              FilledButton(
                                onPressed: rescheduleLocked ? null : () => _goToReschedule(order),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E2A78),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: AppText.bodyMedium('تغيير اليوم', color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsetsDirectional.all(12),
                            decoration: BoxDecoration(color: const Color(0xFFF7F7F9), borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText.bodyMedium('مدة الخدمة', color: const Color(0xFF656B78), fontWeight: FontWeight.w700),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClServiceTimePickerFieldWidget(
                                        title: 'من',
                                        controller: _fromTimeController,
                                        onTap: rescheduleLocked ? () {} : () => _goToReschedule(order),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ClServiceTimePickerFieldWidget(
                                        title: 'إلى',
                                        controller: _toTimeController,
                                        onTap: rescheduleLocked ? () {} : () => _goToReschedule(order),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: rescheduleLocked ? null : () => _goToReschedule(order),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: const Color(0xffE5E7EB),
                                foregroundColor: const Color(0xff1E2A78),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(
                                rescheduleLocked ? 'تغيير الموعد غير متاح حالياً' : 'تغيير موعد الخدمة',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClServiceAddressSectionWidget(locationName: order.locationName ?? 'المنزل', address: order.propertyDetails?.address ?? '-'),
                    const SizedBox(height: 12),
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: order.worker?.avatarUrl == null ? null : NetworkImage(order.worker!.avatarUrl!),
                                child: order.worker?.avatarUrl == null ? const Icon(Icons.person, size: 20) : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.worker?.name ?? 'مقدم الخدمة',
                                      style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xff1F2937)),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '⭐ ${order.worker?.averageRating?.toStringAsFixed(1) ?? '-'} • مقدم الخدمة',
                                      style: const TextStyle(color: Color(0xff6B7280), fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () => _callWorker(order.worker?.phone),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(color: const Color(0xffF3F4F6), borderRadius: BorderRadius.circular(19)),
                                  child: const Icon(Icons.call, color: Color(0xff111827), size: 19),
                                ),
                              ),
                            ],
                          ),
                          if (order.startedTravelAt != null && order.arrivedAt == null) ...[
                            const SizedBox(height: 10),
                            const Text(
                              'مقدم الخدمة في الطريق إلى موقعك.',
                              style: TextStyle(color: Color(0xff0CBBC7), fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ],
                          if (_workerLiveLatitude != null && _workerLiveLongitude != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'آخر موقع مباشر: ${_workerLiveLatitude!.toStringAsFixed(5)}, ${_workerLiveLongitude!.toStringAsFixed(5)}',
                              style: const TextStyle(color: Color(0xff6B7280), fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ملخص الطلب',
                            style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xff1F2937)),
                          ),
                          const SizedBox(height: 10),
                          _SummaryRow(title: 'تكلفة الخدمة', value: '${(order.basePrice ?? 0).formatWithComma()} ل.س'),
                          const SizedBox(height: 6),
                          _SummaryRow(title: 'رسوم التنقل', value: '${(order.travelFee ?? 0).formatWithComma()} ل.س'),
                          if ((order.addonsTotal ?? 0) > 0) ...[
                            const SizedBox(height: 6),
                            _SummaryRow(title: 'إضافات', value: '${(order.addonsTotal ?? 0).formatWithComma()} ل.س'),
                          ],
                          const SizedBox(height: 10),
                          const Divider(color: Color(0xffE5E7EB)),
                          const SizedBox(height: 10),
                          _SummaryRow(title: 'الإجمالي النهائي', value: '${(order.totalPrice ?? 0).formatWithComma()} ل.س', isTotal: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => isCompleted ? _reportIssue(order) : _cancelOrder(order),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: isCompleted ? const Color(0xff9CA3AF).withAlpha(35) : const Color(0xffFEE2E2),
                          foregroundColor: isCompleted ? const Color(0xff6B7280) : const Color(0xffDC2626),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: isCompleted ? const Color(0xff9CA3AF) : const Color(0xffEF4444)),
                          ),
                        ),
                        child: Text(isCompleted ? 'إبلاغ عن مشكلة' : 'إلغاء الطلب', style: const TextStyle(fontWeight: FontWeight.w700)),
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.title, required this.value, this.isTotal = false});

  final String title;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final color = isTotal ? const Color(0xff1E2A78) : const Color(0xff374151);
    final weight = isTotal ? FontWeight.w900 : FontWeight.w600;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(color: color, fontWeight: weight),
        ),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: weight),
        ),
      ],
    );
  }
}
