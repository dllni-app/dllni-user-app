import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:common_package/common_package.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/auth/auth_gate.dart';
import '../../../../core/session/session_expired_handler.dart';
import '../../../../core/models/cleaning_gender_preference.dart';
import '../../../../core/models/cleaning_service_extras.dart';
import '../../../orders/view/screens/cleaning_order_details_screen.dart';
import '../../../profile/domain/models/address_list_item.dart';
import '../../../profile/domain/usecases/fetch_addresses_use_case.dart';
import '../../data/models/cleaning_services_response_model.dart';
import '../../data/models/estimate_price_response_model.dart';
import '../../data/models/previous_workers_response_model.dart';
import '../../data/source/cl_main_remote_data_source.dart';
import '../../domain/models/cleaning_booking_draft.dart';
import '../../domain/models/cleaning_type.dart';
import '../../domain/models/cleaning_recurring_session.dart';
import '../../domain/models/cleaning_team_schedule.dart';
import '../../domain/models/work_environment_confirmation.dart';
import '../../domain/usecases/get_previous_cleaning_workers_use_case.dart';
import '../../domain/usecases/get_cleaning_services_use_case.dart';
import '../data/cl_main_route_args.dart';
import '../widgets/cl_female_worker_safety_confirmation_sheet.dart';
import '../widgets/cl_redesign_components.dart';
import '../widgets/cl_booking_pencil_header.dart';
import '../../../../core/widgets/design_system/design_system.dart';
import '../../../../core/themes/shared_platform_colors.dart';
import '../widgets/cl_service_address_section_widget.dart';

class CleaningBookingV2Screen extends StatefulWidget {
  const CleaningBookingV2Screen({super.key, required this.args});
  final ClMainScheduleArgs args;
  @override
  State<CleaningBookingV2Screen> createState() =>
      _CleaningBookingV2ScreenState();
}

class _CleaningBookingV2ScreenState extends State<CleaningBookingV2Screen> {
  late CleaningBookingDraft _draft;
  late ValueNotifier<AddressListItem?> _address;
  final _scroll = ScrollController();
  final Map<String, GlobalKey> _scheduleAnchors = {};
  final _notes = TextEditingController();
  final _api = getIt<ClMainRemoteDataSource>();
  EstimatePriceResponseModel? _quote;
  List<CleaningMaterialLineModel> _materials = [];
  final Map<String, List<CleaningMaterialLineModel>> _periodMaterials = {};
  List<CleaningServiceModel> _services = [];
  bool _loadingServices = false;
  bool _servicesCatalogError = false;
  List<PreviousWorkerModel> _previousWorkers = [];
  Map<String, dynamic> _policy = {};
  CleaningGenderPreference? _gender;
  WorkEnvironmentConfirmation? _safety;
  final Set<int> _workerIds = {};
  bool _preferred = false;
  bool _loadingWorkers = false;
  bool _quoting = false;
  bool _submitting = false;
  bool _terms = false;
  bool _uncertainSubmission = false;
  bool _created = false;
  Map<String, String> _fieldErrors = {};
  String? _error;
  String? _quotedPayload;
  String? _attemptKey;
  Map<String, dynamic>? _submittedPayload;
  int _step = 0;
  int _generation = 0;
  Timer? _debounce;
  Timer? _expiry;
  CleaningMaterialChoice? _materialChoice;
  final Set<int> _missingMaterialIds = {};
  final List<PeriodSpecialistService> _bookingServices = [];
  bool _servicesReviewed = true;
  bool _previewReady = false;
  bool _previewLoading = false;
  bool _materialsExpanded = false;
  int _teamWorkers = 1;
  bool _editingFromReview = false;
  bool _recurring = false;
  CleaningRecurringPattern _recurrencePattern = CleaningRecurringPattern.weekly;
  int _occurrences = 2;

  static const _titles = [
    'المواد جاهزة عندك؟',
    'تفاصيل صغيرة، فرق كبير',
    'وين وإيمتى نجيك؟',
    'كل شيء جاهز للمراجعة',
  ];
  static const _subtitles = [
    'هذه المتطلبات حسب غرفك ونوع التنظيف.',
    'خدمات اختيارية؛ يمكنك المتابعة من دون إضافة.',
    'العنوان والفريق ومواعيد التنظيف في مكان واحد.',
    'راجع تفاصيلك قبل إرسال طلب التنظيف.',
  ];

  @override
  void initState() {
    super.initState();
    final saved = widget.args.draft;
    final old = saved?['bookingV2'];
    _draft = old is CleaningBookingDraft
        ? old.reconcileRooms(widget.args.roomUnits)
        : CleaningBookingDraft.fromRooms(
            widget.args.roomUnits,
            DateTime.now().add(const Duration(days: 1)),
          );
    _teamWorkers = (saved?['v2TeamWorkers'] as int? ?? 1).clamp(1, 6);
    _recurring = saved?['v2Recurring'] as bool? ?? false;
    _recurrencePattern =
        saved?['v2RecurrencePattern'] as CleaningRecurringPattern? ??
        CleaningRecurringPattern.weekly;
    _occurrences = (saved?['v2Occurrences'] as int? ?? 2).clamp(2, 4);
    if (!_recurring) {
      for (final key
          in _draft.schedules
              .map((s) => s.visitKey)
              .toSet()
              .where((key) => key != 'visit.1')
              .toList()) {
        _draft = _draft.removeVisit(key);
      }
    }
    _address = ValueNotifier(
      saved?['v2Address'] as AddressListItem? ?? widget.args.defaultAddress,
    );
    final savedStep = saved?['v2Step'] as int? ?? 0;
    final version = saved?['v2FlowVersion'] as int?;
    _step = switch (version) {
      5 => savedStep.clamp(0, 3),
      4 => switch (savedStep) {
        0 => 2,
        1 => 0,
        2 => 1,
        _ => 3,
      },
      3 => switch (savedStep) {
        0 || 1 => 2,
        2 => 0,
        3 => 1,
        _ => 3,
      },
      _ =>
        saved?['v2Step'] == null
            ? 0
            : switch (savedStep) {
                0 || 1 => 2,
                2 || 3 => 0,
                4 => 1,
                _ => 3,
              },
    };
    final priorMaterial = _draft.periods.firstOrNull?.materials;
    _materialChoice =
        saved?['v2MaterialChoice'] as CleaningMaterialChoice? ??
        priorMaterial?.choice;
    _missingMaterialIds.addAll(
      (saved?['v2MissingMaterialIds'] as List?)?.whereType<int>() ??
          priorMaterial?.missingIds ??
          [],
    );
    final previousServices = _draft.periods
        .expand((period) => period.services)
        .toList();
    final storedServices = saved?['v2BookingServices'];
    // Earlier builds unintentionally attached every add-on to all rooms.
    // The API bills service quantity once *per target room*, so a carpet area
    // of 31 m² was charged and scheduled repeatedly for four bedrooms.
    // The booking-wide quantity needs one operational anchor, not every room.
    final restoredServices = storedServices is List<PeriodSpecialistService>
        ? storedServices
        : previousServices;
    final roomKeys = _draft.rooms.map((room) => room.key).toSet();
    for (final service in restoredServices) {
      final targets = service.targetRoomKeys;
      final legacyAllRoomSelection =
          roomKeys.length > 1 &&
          targets.toSet().containsAll(roomKeys) &&
          roomKeys.containsAll(targets);
      _bookingServices.add(
        legacyAllRoomSelection
            ? PeriodSpecialistService(
                serviceKey: service.serviceKey,
                serviceId: service.serviceId,
                targetRoomKeys: [targets.first],
                quantity: service.quantity,
                dirtiness: service.dirtiness,
              )
            : service,
      );
    }
    _servicesReviewed = true; // Empty special services is valid.
    _draft = _applyBookingSelections(
      planCleaningTeam(_draft, workerCount: _teamWorkers),
    );

    _gender = saved?['v2Gender'] as CleaningGenderPreference?;
    _safety = saved?['v2Safety'] as WorkEnvironmentConfirmation?;
    _preferred = saved?['v2Preferred'] as bool? ?? false;
    _workerIds.addAll((saved?['v2WorkerIds'] as List<int>?) ?? []);
    _notes.text = saved?['v2Notes'] as String? ?? '';
    _terms = saved?['v2Terms'] as bool? ?? false;
    _submittedPayload = saved?['v2PendingSubmission'] as Map<String, dynamic>?;
    _uncertainSubmission = _submittedPayload != null;
    if (_uncertainSubmission) _step = 3;
    _notes.addListener(_inputChanged);
    SessionExpiredHandler.registerRecovery(this, _prepareAuthRecovery);
    // Persist the normalized team plan without requesting an early price quote.
    _save();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Materials are required for the selected rooms regardless of address,
      // material supplier or final price quotation availability.
      await _loadMaterialsPreview();
      if (!mounted) return;
      _loadSpecialServicesCatalog();
      if (_address.value == null) {
        _prefetchDefaultAddress();
      }
      // A customer can re-open a saved booking directly on the review step.
      // Without this refresh the total would remain "pending" indefinitely
      // until the user pressed the manual refresh button.
      if (_step == 3 && !_uncertainSubmission) {
        await _refreshQuote();
      }
    });
  }

  void _save() {
    if (_created) return;
    widget.args.draft?.addAll({
      'bookingV2': _draft,
      'v2Address': _address.value,
      'v2Step': _step,
      'v2FlowVersion': 5,
      'v2TeamWorkers': _teamWorkers,
      'v2Recurring': _recurring,
      'v2RecurrencePattern': _recurrencePattern,
      'v2Occurrences': _occurrences,
      'v2MaterialChoice': _materialChoice,
      'v2MissingMaterialIds': _missingMaterialIds.toList(),
      'v2BookingServices': List<PeriodSpecialistService>.from(_bookingServices),
      'v2ServicesReviewed': _servicesReviewed,
      'v2Gender': _gender,
      'v2Safety': _safety,
      'v2Preferred': _preferred,
      'v2WorkerIds': _workerIds.toList(),
      'v2Notes': _notes.text,
      'v2Terms': _terms,
      'v2PendingSubmission': _uncertainSubmission ? _submittedPayload : null,
    });
  }

  void _prepareAuthRecovery() {
    _save();
    final args = widget.args;
    AuthGate.rememberAction(() {
      final navigator = SessionExpiredHandler.navigatorKey?.currentState;
      if (navigator == null) return;
      navigator.push(
        MaterialPageRoute(builder: (_) => CleaningBookingV2Screen(args: args)),
      );
    });
  }

  Map<String, dynamic> get _payload => {
    ..._draft.toJson(),
    'propertyType': widget.args.propertyType,
    'propertyDetails': {
      'bedrooms': widget.args.bedrooms,
      'rooms': widget.args.rooms,
      'bathrooms': widget.args.bathrooms,
      'living_room_size': widget.args.livingRoomSize,
      'room_size_breakdown': widget.args.roomSizeBreakdown.toBackendJson(),
      'address': _address.value?.line1 ?? '',
      'location_name': _address.value?.label ?? '',
    },
    'addressId': int.tryParse(_address.value?.id ?? ''),
    'addressLatitude': _address.value?.latitude,
    'addressLongitude': _address.value?.longitude,
    'genderPreference': (_gender ?? CleaningGenderPreference.any).apiValue,
    'assignmentMode': _preferred && _teamWorkers == 1 && _workerIds.length == 1
        ? 'preferred_worker'
        : 'open_count',
    'numberOfWorkers': _teamWorkers,
    if (_preferred) 'preferredWorkerIds': _workerIds.toList()..sort(),
    if (_preferred) 'workerScope': 'specific',
    if (_safety != null) 'workEnvironmentConfirmation': _safety!.toJson(),
    'notes': _notes.text.trim(),
  };

  void _inputChanged() {
    if (!mounted || _uncertainSubmission) return;
    _generation++;
    _debounce?.cancel();
    _expiry?.cancel();
    setState(() {
      _quote = null;
      _quotedPayload = null;
      _error = null;
      _fieldErrors = {};
    });
    _save();
    // Keep screen-to-screen navigation immediate. Refresh the final quote
    // only while reviewing; materials/catalogs are loaded initially.
    if (_step == 3) {
      _debounce = Timer(const Duration(milliseconds: 350), _refreshQuote);
    }
  }

  CleaningBookingDraft _applyBookingSelections(CleaningBookingDraft draft) {
    if (draft.periods.isEmpty) return draft;
    return CleaningBookingDraft(
      rooms: draft.rooms,
      schedules: draft.schedules,
      periods: [
        for (final period in draft.periods)
          period.copyWith(
            materials: PeriodMaterialDecision(
              choice: _materialChoice,
              missingIds:
                  _materialChoice == CleaningMaterialChoice.customerPartial
                  ? _missingMaterialIds.toList()
                  : [],
            ),
            servicesReviewed: _servicesReviewed,
            services: [
              for (final service in _bookingServices)
                if (service.targetRoomKeys.any(
                  (key) => draft
                      .schedulesFor(period)
                      .any((schedule) => schedule.roomKey == key),
                ))
                  PeriodSpecialistService(
                    serviceKey: '${service.serviceKey}.${period.periodKey}',
                    serviceId: service.serviceId,
                    targetRoomKeys: service.targetRoomKeys
                        .where(
                          (key) => draft
                              .schedulesFor(period)
                              .any((schedule) => schedule.roomKey == key),
                        )
                        .toList(),
                    quantity: service.quantity,
                    dirtiness: service.dirtiness,
                  ),
            ],
          ),
      ],
      revision: draft.revision + 1,
    );
  }

  void _changeDraft(CleaningBookingDraft revised) {
    setState(() => _draft = _applyBookingSelections(revised));
    _inputChanged();
  }

  Future<void> _loadSpecialServicesCatalog() async {
    if (!mounted || _loadingServices) return;
    setState(() {
      _loadingServices = true;
      _servicesCatalogError = false;
    });
    try {
      // Optional services are independent from final price quotations.
      final catalog = await _api.getCleaningServices(
        GetCleaningServicesParams(category: 'special_service'),
      );
      if (!mounted) return;
      setState(
        () => _services = catalog.data
            .where((service) => service.isActive != false && service.id != null)
            .toList(),
      );
    } on DioException catch (_) {
      if (mounted) setState(() => _servicesCatalogError = true);
    } on Failure catch (_) {
      if (mounted) setState(() => _servicesCatalogError = true);
    } catch (_) {
      if (mounted) setState(() => _servicesCatalogError = true);
    } finally {
      if (mounted) setState(() => _loadingServices = false);
    }
  }

  Future<void> _loadMaterialsPreview() async {
    if (!mounted || _draft.rooms.isEmpty || _previewLoading) return;
    setState(() => _previewLoading = true);
    try {
      final preview = await _api.previewBookingMaterialsV2(_draft.toJson());
      if (!mounted) return;
      var updatedDraft = _draft;
      for (final schedule in _draft.schedules) {
        final work = preview.roomWorkMinutes[schedule.roomKey];
        if (work == null || work <= 0) continue;
        updatedDraft = updatedDraft.replaceSchedule(
          schedule.copyWith(workMinutes: work),
        );
      }
      if (preview.roomWorkMinutes.isNotEmpty) {
        updatedDraft = _applyBookingSelections(
          planCleaningTeam(updatedDraft, workerCount: _teamWorkers),
        );
      }
      setState(() {
        _draft = updatedDraft;
        _materials = preview.availableMaterials;
        _previewReady = true;
      });
      _save();
    } on DioException catch (_) {
      // Keep a visible retry control rather than blocking the booking flow.
    } on Failure catch (_) {
      // The materials-preview endpoint may recover on the next attempt.
    } finally {
      if (mounted) setState(() => _previewLoading = false);
    }
  }

  Future<void> _refreshQuote({int reconciliationPass = 0}) async {
    if (!mounted ||
        _uncertainSubmission ||
        _address.value?.hasCompleteServiceLocation != true ||
        _draft.schedules.isEmpty) {
      return;
    }
    final generation = ++_generation;
    final payload = _payload;
    setState(() {
      _quoting = true;
      _error = null;
    });
    try {
      final response = await _api.estimateBookingV2(payload);
      if (!mounted || generation != _generation) return;
      final revised = _applyBookingSelections(
        planCleaningTeam(
          _draft.applyAuthoritativeVisits(response.visits),
          workerCount: _teamWorkers,
        ),
      );
      final updatedPolicy = response.schedulingPolicy;
      final revisedPayload = {
        ...payload,
        ...revised.toJson(),
        'numberOfWorkers': _teamWorkers,
      };
      // The server signs the submitted draft. A new grouping needs a fresh quote.
      final sameContract = jsonEncode(revisedPayload) == jsonEncode(payload);
      setState(() {
        _draft = revised;
        _policy = updatedPolicy;
        _quoting = false;
        _materials = response.availableMaterials;
        _previewReady = true;
        _periodMaterials.clear();
        for (final visit in response.visits) {
          for (final raw in (visit['timePeriods'] as List? ?? []).cast<Map>()) {
            if (raw['materialsPreview'] is! List) continue;
            final keys = (raw['roomScheduleKeys'] as List).cast<String>()
              ..sort();
            _periodMaterials[keys.join('|')] = cleaningMaterialLinesFromJson(
              raw['materialsPreview'],
            );
          }
        }
        if (response.specialServicesCatalog.isNotEmpty) {
          _services = response.specialServicesCatalog
              .map(CleaningServiceModel.fromJson)
              .toList();
        }
        _quote = sameContract ? response : null;
        _quotedPayload = _quote == null ? null : jsonEncode(_payload);
      });
      _save();
      if (!sameContract) {
        // The API may regroup time periods after adding a special service.
        // Bound the automatic convergence so the UI cannot quote endlessly
        // and leave the price card looking permanently unfinished.
        if (reconciliationPass < 5) {
          await _refreshQuote(reconciliationPass: reconciliationPass + 1);
        } else if (mounted) {
          setState(() {
            _quoting = false;
            _error =
                'تغيّرت مواعيد الغرف بعد إضافة الخدمات. راجع مواعيدك وحدّث السعر من جديد.';
          });
        }
      } else if (response.quoteSignature == null) {
        setState(() {
          _quoting = false;
          _error =
              'تحتاج فترات التنظيف إلى مراجعة بعد احتساب الخدمات الإضافية. راجع المواعيد ثم حدّث السعر.';
        });
      } else {
        _expiry?.cancel();
        final expiry = response.quoteExpiresAt;
        if (expiry != null) {
          _expiry = Timer(expiry.difference(DateTime.now()), () {
            if (mounted) setState(() => _quote = null);
          });
        }
      }
    } on DioException catch (failure) {
      _quoteFailure(generation, _networkError(failure));
    } on Failure catch (failure) {
      _quoteFailure(generation, _arabicError(failure.message));
    }
  }

  void _quoteFailure(int generation, String message) {
    if (!mounted || generation != _generation) return;
    setState(() {
      _quoting = false;
      _quote = null;
      _error = message;
    });
  }

  String _arabicError(String message) =>
      RegExp(r'[\u0600-\u06FF]').hasMatch(message)
      ? message
      : 'تعذر إكمال الطلب. راجع المواعيد والاختيارات ثم أعد المحاولة.';

  String _networkError(DioException failure) {
    final response = failure.response?.data;
    if (response is Map) {
      final errors = response['errors'];
      if (errors is Map && errors.isNotEmpty) {
        _fieldErrors = {
          for (final entry in errors.entries)
            entry.key.toString(): _arabicError(
              (entry.value is List
                      ? (entry.value as List).join('\n')
                      : entry.value)
                  .toString(),
            ),
        };
        final messages = errors.values
            .expand((entry) => entry is List ? entry : [entry])
            .map((entry) => _arabicError(entry.toString()))
            .toSet();
        if (errors.keys.any(
          (key) =>
              key.toString().contains('timePeriods.') &&
              key.toString().contains('.materials.materialTypeIds'),
        )) {
          return 'تعذّر اعتماد بعض المواد للتكرار. جرّب توفير جميع المواد، أو احجز كل موعد منفصلاً حتى يُعالج تعارض المواد الدورية.';
        }
        return messages.join('\n');
      }
      return _arabicError(response['message']?.toString() ?? '');
    }
    return 'تعذر الاتصال. اختياراتك محفوظة، حاول مجدداً.';
  }

  Future<void> _prefetchDefaultAddress() async {
    if (!getIt.isRegistered<FetchAddressesUseCase>()) return;
    try {
      final response = await getIt<FetchAddressesUseCase>()(
        FetchAddressesParams(),
      );
      if (!mounted || _address.value != null) return;
      response.fold((_) {}, (result) {
        final all = result.addresses;
        if (all == null || all.isEmpty) return;
        final item = all.firstWhere(
          (item) => item.isDefault,
          orElse: () => all.first,
        );
        final label = (item.label ?? '').trim().isNotEmpty
            ? item.label!
            : 'العنوان';
        final parts = <String>[
          for (final piece in [item.city, item.neighborhood, item.street])
            if (piece?.trim().isNotEmpty ?? false) piece!.trim(),
          if (item.building?.trim().isNotEmpty ?? false)
            'بناء ${item.building ?? ''}',
          if (item.floor?.trim().isNotEmpty ?? false)
            'طابق ${item.floor ?? ''}',
        ];
        _address.value = AddressListItem(
          id: item.id?.toString() ?? '',
          label: label,
          line1: parts.join(' - '),
          type: AddressType.home,
          latitude: item.latitude,
          longitude: item.longitude,
          isDefault: item.isDefault,
        );
        _inputChanged();
      });
    } catch (_) {
      // The customer can select an address on the appointment screen.
    }
  }

  Future<void> _selectAddress() async {
    final address = await context.pushRoute('/myaddresses', arguments: true);
    if (!mounted || address is! AddressListItem) return;
    _address.value = address;
    _inputChanged();
  }

  Future<void> _selectGender(CleaningGenderPreference gender) async {
    if (gender == CleaningGenderPreference.female) {
      try {
        final policy = await _api.getFemaleWorkerSafetyPolicy();
        if (!mounted) return;
        final confirmation = await showFemaleWorkerSafetyConfirmationSheet(
          context: context,
          policy: policy,
        );
        if (!mounted || confirmation == null) return;
        _safety = confirmation;
      } on DioException catch (failure) {
        _feedback(_networkError(failure));
        return;
      } on Failure catch (failure) {
        _feedback(_arabicError(failure.message));
        return;
      }
    } else {
      _safety = null;
    }
    setState(() {
      _gender = gender;
      _workerIds.clear();
    });
    _inputChanged();
  }

  Future<void> _loadWorkers() async {
    setState(() => _loadingWorkers = true);
    final response = await getIt<GetPreviousCleaningWorkersUseCase>()(
      GetPreviousCleaningWorkersParams(propertyType: widget.args.propertyType),
    );
    if (!mounted) return;
    response.fold((failure) => _feedback(_arabicError(failure.message)), (
      workers,
    ) {
      setState(
        () => _previousWorkers = (workers.data ?? [])
            .where(
              (worker) =>
                  worker.id != null &&
                  (_gender == CleaningGenderPreference.any ||
                      worker.gender == _gender),
            )
            .toList(),
      );
    });
    setState(() => _loadingWorkers = false);
  }

  void _feedback(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _next() async {
    ScaffoldMessenger.of(context).clearSnackBars();
    if (_step == 0 && !_previewReady) {
      _feedback('ما قدرنا نحمّل قائمة المواد. حاول مرة ثانية قبل المتابعة.');
      return;
    }
    if (_step == 0 &&
        (_previewReady &&
            _materialsForBooking.isNotEmpty &&
            (_materialChoice == null ||
                (_materialChoice == CleaningMaterialChoice.customerPartial &&
                    _missingMaterialIds.isEmpty)))) {
      _feedback('راجع المواد المطلوبة واختر من سيوفّرها.');
      return;
    }
    if (_step == 2) {
      if (_draft.schedules.any((s) => !s.start.isAfter(DateTime.now()))) {
        _feedback('اختر موعداً مستقبلياً للتنظيف.');
        return;
      }
      if (_address.value?.hasCompleteServiceLocation != true) {
        _feedback('اختر عنوان الخدمة مع موقعه على الخريطة.');
        return;
      }
      if (_gender == null) {
        _feedback('اختر تفضيل العامل للمتابعة.');
        return;
      }
      if (_preferred && _workerIds.isEmpty) {
        _feedback('اختر عاملاً مفضلاً على الأقل، أو أوقف التفضيل للمتابعة.');
        return;
      }
      // Room duration and backend quote can refresh after navigation.
      // Do not hold customers on this step while the API is calculating.
    }
    if (_step == 3) {
      await _submit();
      return;
    }
    if (_editingFromReview) {
      _editingFromReview = false;
      setState(() => _step = 3);
    } else {
      setState(() => _step++);
    }
    _save();
    if (_scroll.hasClients) _scroll.jumpTo(0);
    if (_step == 3) await _refreshQuote();
  }

  bool get _quoteCurrent =>
      _quote?.quoteSignature != null &&
      _quotedPayload == jsonEncode(_payload) &&
      (_quote?.quoteExpiresAt?.isAfter(DateTime.now()) ?? false);

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_uncertainSubmission && !_previewReady) {
      setState(() => _step = 0);
      _feedback('راجع قائمة المواد قبل إرسال الطلب.');
      return;
    }
    if (!_uncertainSubmission &&
        (_previewReady &&
            _materialsForBooking.isNotEmpty &&
            (_materialChoice == null ||
                (_materialChoice == CleaningMaterialChoice.customerPartial &&
                    _missingMaterialIds.isEmpty)))) {
      setState(() => _step = 0);
      _feedback('راجع مواد التنظيف لهذا الطلب.');
      return;
    }
    if (!_terms) {
      _feedback('وافق على شروط الخدمة قبل التأكيد.');
      return;
    }
    if (!_uncertainSubmission && !_quoteCurrent) {
      await _refreshQuote();
      if (!mounted || !_quoteCurrent) {
        _feedback('تعذّر تحديث السعر. أعد المحاولة لإتمام الحجز.');
        return;
      }
    }
    _attemptKey ??= _uuid();
    _submittedPayload ??= {
      ..._payload,
      'quoteId': _quote!.quoteId,
      'quoteSignature': _quote!.quoteSignature,
      'idempotencyKey': _attemptKey,
      'termsAccepted': true,
    };
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final created = await _api.createBookingV2(_submittedPayload!);
      if (!mounted) return;
      final orderId = created.orderId;
      if (orderId == null) {
        setState(() {
          _error = 'تعذر عرض تأكيد الطلب. أعد المحاولة بنفس الطلب.';
          _uncertainSubmission = true;
        });
        _save();
        return;
      }
      widget.args.draft?.clear();
      _created = true;
      context.pushRouteAndRemoveUntil(
        '/cleaning-order-details',
        arguments: CleaningOrderDetailsArgs(orderId: orderId),
        predicate: (route) => route.settings.name == '/clmain',
      );
    } on DioException catch (failure) {
      if (mounted) setState(() => _error = _networkError(failure));
      _uncertainSubmission =
          failure.response == null ||
          (failure.response?.statusCode ?? 0) >= 500;
      if (!_uncertainSubmission) {
        _submittedPayload = null;
        _attemptKey = null;
      }
      if (failure.response?.statusCode == 401) {
        _submittedPayload = null;
        _attemptKey = null;
        _uncertainSubmission = false;
      }
      if (failure.response?.statusCode == 422) {
        _attemptKey = null;
        _submittedPayload = null;
        _quote = null;
      }
      _save();
    } on Failure catch (failure) {
      if (mounted) setState(() => _error = _arabicError(failure.message));
      _uncertainSubmission = failure is! UnauthenticatedFailure;
      if (!_uncertainSubmission) {
        _submittedPayload = null;
        _attemptKey = null;
      }
      _save();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _uuid() {
    final random = Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 15) | 64;
    bytes[8] = (bytes[8] & 63) | 128;
    final hex = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        backgroundColor: AlnadhaTokens.background,
        appBar: ClBookingTopBar(
          onExit: _confirmExit,
          exitEnabled: !_submitting && !_uncertainSubmission,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 6),
                child: ClBookingPencilHeader(
                  step: _step + 3,
                  title: _titles[_step],
                  subtitle: _subtitles[_step],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scroll,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_quoting && _step == 3)
                        const LinearProgressIndicator(minHeight: 2),
                      if (_error != null)
                        Card(
                          color: const Color(0xFFFFF0E8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(_error!, key: const Key('booking_error')),
                                if (_fieldErrors.keys.any(
                                  (field) => field.startsWith('visits'),
                                ))
                                  TextButton(
                                    onPressed: _jumpToInvalidSchedule,
                                    child: const Text(
                                      'الانتقال إلى موعد الغرفة',
                                    ),
                                  ),
                                TextButton(
                                  onPressed: _uncertainSubmission
                                      ? _submit
                                      : _refreshQuote,
                                  child: const Text('إعادة المحاولة'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (_uncertainSubmission)
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            'لم يصل تأكيد الطلب. احتفظنا بنفس الاختيارات والسعر، وأوقفنا التعديل حتى نتحقق من الطلب. أعد المحاولة بأمان.',
                          ),
                        ),
                      AbsorbPointer(
                        absorbing: _submitting || _uncertainSubmission,
                        child: switch (_step) {
                          0 => _materialsStep(),
                          1 => _servicesStep(),
                          2 => _appointmentStep(),
                          _ => _review(),
                        },
                      ),
                      if (_submitting)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'جاري تأكيد طلبك',
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              ClRedesignStickyActions(
                key: _step == 3
                    ? const Key('booking_submit')
                    : const Key('booking_continue'),
                primaryLabel: _uncertainSubmission
                    ? 'التحقق وإعادة المحاولة'
                    : _step == 3
                    ? 'تأكيد وإنشاء الطلب'
                    : 'متابعة',
                primaryEnabled: !_submitting,
                onPrimary: _next,
                secondaryLabel: 'السابق',
                onSecondary: _submitting || _uncertainSubmission ? null : _back,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Future<void> _confirmExit() async {
    if (_submitting || _uncertainSubmission || !mounted) return;
    final exit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('الخروج من طلب التنظيف؟'),
        content: const Text(
          'سيتم فقدان التقدم الذي أدخلته في هذا الطلب. هل أنت متأكد من الخروج؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('متابعة الطلب'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('الخروج من الطلب'),
          ),
        ],
      ),
    );
    if (!mounted || exit != true) return;
    // An explicitly confirmed exit discards the in-progress booking.
    widget.args.draft?.clear();
    _created = true;
    Navigator.of(context).pop();
  }

  void _back() {
    if (_uncertainSubmission || _submitting) return;
    _save();
    if (_editingFromReview) {
      _editingFromReview = false;
      setState(() => _step = 3);
    } else {
      if (_step == 0) {
        // Previous in step four returns to the cleaning-mode step.
        // X / Android system back still guards discarding the whole booking.
        Navigator.of(context).pop();
        return;
      }
      setState(() => _step--);
    }
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _jumpToInvalidSchedule() {
    setState(() => _step = 2);
    final affected = _draft.schedules
        .where((schedule) => _scheduleErrors(schedule).isNotEmpty)
        .firstOrNull;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final anchor = _scheduleAnchors[affected?.scheduleKey]?.currentContext;
      if (anchor != null) {
        Scrollable.ensureVisible(
          anchor,
          duration: const Duration(milliseconds: 200),
        );
      }
    });
  }

  Widget _genderCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AlnadhaTokens.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'تفضيل مقدم الخدمة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: SharedPlatformColors.cleaningInk,
          ),
        ),
        const SizedBox(height: 6),
        const Text('اختر ما يناسبك، وسيتم البحث وفق الإتاحة.'),
        const SizedBox(height: 10),
        for (final preference in [
          CleaningGenderPreference.male,
          CleaningGenderPreference.female,
        ])
          InkWell(
            key: Key('cleaning_gender_pref_${preference.apiValue}'),
            onTap: () => _selectGender(preference),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _gender == preference
                    ? SharedPlatformColors.cleaningSoft
                    : Colors.white,
                border: Border.all(
                  color: _gender == preference
                      ? SharedPlatformColors.cleaning
                      : AlnadhaTokens.border,
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  Icon(
                    _gender == preference
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: SharedPlatformColors.cleaning,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    preference.arabicLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );

  Widget _addressStep() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (_address.value == null)
        CleaningAddressSelectWidget(
          selectedAddress: _address,
          onChangeTap: _selectAddress,
          afterBringDefault: _inputChanged,
        )
      else
        ClServiceAddressSectionWidget(
          locationName: _address.value?.label ?? 'عنوان الخدمة',
          address: _address.value?.line1 ?? '',
          onChangeTap: _selectAddress,
          afterBringDefault: _inputChanged,
        ),
      const SizedBox(height: 12),
      _genderCard(),
      SwitchListTile(
        title: const Text('اختيار عمال تعاملت معهم سابقاً'),
        subtitle: const Text(
          'يمكنك تفضيل عامل سبق التعامل معه، وسيُستكمل الفريق حسب العدد المطلوب.',
        ),
        value: _preferred,
        onChanged: (enabled) {
          setState(() => _preferred = enabled);
          _inputChanged();
          if (enabled) _loadWorkers();
        },
      ),
      if (_loadingWorkers) const LinearProgressIndicator(),
      if (_preferred && !_loadingWorkers && _previousWorkers.isEmpty)
        const Text(
          'لا يوجد عمال سابقون مطابقون لتفضيلك. يمكنك اختيار البحث التلقائي.',
        ),
      if (_preferred)
        for (final worker in _previousWorkers)
          CheckboxListTile(
            title: Text(worker.name ?? 'عامل سابق'),
            value: _workerIds.contains(worker.id),
            onChanged: (checked) {
              setState(() {
                checked == true
                    ? _workerIds.add(worker.id!)
                    : _workerIds.remove(worker.id);
              });
              _inputChanged();
            },
          ),
    ],
  );

  DateTime get _appointmentStart => _draft.schedules
      .where((s) => s.visitKey == 'visit.1')
      .map((s) => s.start)
      .reduce((a, b) => a.isBefore(b) ? a : b);

  CleaningBookingDraft _buildAppointment(DateTime start) {
    var draft = CleaningBookingDraft.fromRooms(_draft.rooms, start);
    final known = {
      for (final s in _draft.schedules.where((s) => s.visitKey == 'visit.1'))
        s.roomKey: s.workMinutes,
    };
    for (final schedule in draft.schedules.toList()) {
      draft = draft.replaceSchedule(
        schedule.copyWith(start: start, workMinutes: known[schedule.roomKey]),
      );
    }
    if (_recurring) {
      final dates = CleaningRecurringScheduleGenerator.generate(
        pattern: _recurrencePattern,
        startDate: start,
        time: cleaningClock(start),
        occurrences: _occurrences,
      );
      for (final date in dates.skip(1)) {
        draft = draft.addVisit(date.date);
      }
    }
    return _applyBookingSelections(
      planCleaningTeam(draft, workerCount: _teamWorkers),
    );
  }

  void _changeTeamWorkers(int count) {
    final maxWorkers = min(
      6,
      (_policy['maximumWorkers'] as num?)?.toInt() ?? 6,
    );
    final minWorkers = (_policy['minimumWorkers'] as num?)?.toInt() ?? 1;
    if (count < minWorkers || count > maxWorkers) return;
    setState(() {
      _teamWorkers = count;
      _draft = _buildAppointment(_appointmentStart);
    });
    _inputChanged();
  }

  List<DateTime> get _visitDates {
    final seen = <String>{};
    return [
      for (final schedule in _draft.schedules)
        if (seen.add(schedule.visitKey)) schedule.start,
    ];
  }

  Widget _dateChips() => Column(
    key: const Key('booking_recurrence_dates'),
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var index = 0; index < _visitDates.length; index++)
        Container(
          key: Key('booking_recurrence_date_$index'),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9FC),
            border: Border.all(color: AlnadhaTokens.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.event_available_outlined,
                color: SharedPlatformColors.cleaning,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'الموعد ${index + 1} · '
                  '${_visitDates[index].toIso8601String().substring(0, 10)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                cleaningClock(_visitDates[index]),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: SharedPlatformColors.cleaningInk,
                ),
              ),
            ],
          ),
        ),
    ],
  );

  void _changeRecurrence({
    bool? enabled,
    CleaningRecurringPattern? pattern,
    int? count,
  }) {
    final nextEnabled = enabled ?? _recurring;
    final nextPattern = pattern ?? _recurrencePattern;
    final maxCount =
        CleaningRecurringScheduleGenerator.maxOccurrencesWithinWindow(
          pattern: nextPattern,
          startDate: _appointmentStart,
        );
    final nextCount = (count ?? _occurrences).clamp(
      2,
      max(2, min(4, maxCount)).toInt(),
    );
    if (nextEnabled) {
      if (maxCount < 2) {
        _feedback('لا توجد مواعيد متاحة ضمن فترة التكرار المسموحة.');
        return;
      }
      try {
        CleaningRecurringScheduleGenerator.generate(
          pattern: nextPattern,
          startDate: _appointmentStart,
          time: cleaningClock(_appointmentStart),
          occurrences: nextCount,
        );
      } on RangeError {
        _feedback('اختر عدد مواعيد أقل ضمن الفترة المتاحة.');
        return;
      }
    }
    setState(() {
      _recurring = nextEnabled;
      _recurrencePattern = nextPattern;
      _occurrences = nextCount;
      _draft = _buildAppointment(_appointmentStart);
    });
    _inputChanged();
  }

  Widget _appointmentStep() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _addressStep(),
      const SizedBox(height: 14),
      _scheduleStep(),
      const SizedBox(height: 14),
      _recurringCard(),
    ],
  );

  Widget _scheduleStep() {
    if (_draft.schedules.isEmpty) return const Text('اختر الغرف أولاً.');
    final start = _appointmentStart;
    final minutes = cleaningTeamDurationMinutes(_draft);
    final finish = minutes == null
        ? null
        : start.add(Duration(minutes: minutes));
    final maximum = min(6, (_policy['maximumWorkers'] as num?)?.toInt() ?? 6);
    final minimum = (_policy['minimumWorkers'] as num?)?.toInt() ?? 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AlnadhaTokens.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'الموعد والوقت',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: SharedPlatformColors.cleaningInk,
                ),
              ),
              const SizedBox(height: 4),
              const Text('اختر تاريخ بدء الخدمة والساعة المناسبة لك.'),
              const SizedBox(height: 10),
              _bookingPickerRow(
                key: 'booking_date',
                icon: Icons.calendar_month_outlined,
                label: 'تاريخ الخدمة',
                value: start.toIso8601String().substring(0, 10),
                onTap: () => _pickRoomDate(_draft.schedules.first),
              ),
              const SizedBox(height: 8),
              _bookingPickerRow(
                key: 'booking_time',
                icon: Icons.access_time_outlined,
                label: 'وقت البدء',
                value: cleaningClock(start),
                onTap: () => _pickRoomTime(_draft.schedules.first),
              ),
              const SizedBox(height: 8),
              _bookingPickerRow(
                key: 'booking_finish',
                icon: Icons.timelapse_outlined,
                label: 'وقت الانتهاء المتوقع',
                value: finish == null
                    ? 'جارٍ حساب المدة'
                    : cleaningClock(finish),
                onTap: null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          key: const Key('booking_team_card'),
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AlnadhaTokens.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.groups_2_outlined,
                    color: SharedPlatformColors.cleaning,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'عدد العمال للطلب',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: SharedPlatformColors.cleaningInk,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'اختر العدد المناسب، مهما كان عدد الغرف. ننسق العمل لتقليل وقت التنفيذ.',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton.filledTonal(
                    key: const Key('booking_team_minus'),
                    onPressed: _teamWorkers > minimum
                        ? () => _changeTeamWorkers(_teamWorkers - 1)
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _teamWorkers.toString(),
                      key: const Key('booking_team_count'),
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    key: const Key('booking_team_plus'),
                    onPressed: _teamWorkers < maximum
                        ? () => _changeTeamWorkers(_teamWorkers + 1)
                        : null,
                    icon: const Icon(Icons.add),
                  ),
                  const Spacer(),
                  Text(
                    _teamWorkers == 1 ? 'عامل واحد' : 'فريق من العمال',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              if (minutes != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'المدة الإجمالية المتوقعة: ${minutes >= 60 ? '${minutes ~/ 60} ساعة و${minutes % 60} دقيقة' : '$minutes دقيقة'}',
                    key: const Key('booking_total_duration'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: SharedPlatformColors.cleaning,
                    ),
                  ),
                ),
              if (_bookingServices.isNotEmpty && minutes != null)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'مدة تنظيف الغرف تقريبية. الخدمات المتخصصة قد تزيد المدة، وسنؤكدها في المراجعة النهائية.',
                    style: AlnadhaTokens.caption,
                  ),
                ),
              if (_teamWorkers > 1) _teamSupervisorNotice(),
              for (final schedule in _draft.schedules.where(
                (s) => s.visitKey == 'visit.1',
              ))
                for (final message in _scheduleErrors(schedule))
                  Text(message, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bookingPickerRow({
    required String key,
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback? onTap,
  }) => Material(
    color: const Color(0xFFF7F8FA),
    borderRadius: BorderRadius.circular(15),
    child: InkWell(
      key: Key(key),
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFE5E9EE)),
        ),
        child: Row(
          children: [
            Icon(icon, color: SharedPlatformColors.cleaning),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B778A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: SharedPlatformColors.cleaningInk,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null) const Icon(Icons.chevron_left),
          ],
        ),
      ),
    ),
  );

  Widget _teamSupervisorNotice() => Container(
    key: const Key('booking_team_supervisor_notice'),
    margin: const EdgeInsets.only(top: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: SharedPlatformColors.cleaningSoft,
      borderRadius: BorderRadius.circular(15),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.verified_user_outlined,
          color: SharedPlatformColors.cleaning,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'فريق منظّم لإنجاز أسرع!',
                style: TextStyle(
                  color: SharedPlatformColors.cleaningInk,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'سيتابع عامل مشرف تنفيذ الخدمة بالتنسيق مع فريق العمال. '
                'عدد أكبر من العمال يساعد على إنجاز التنظيف بوقت أقل.',
                style: TextStyle(color: SharedPlatformColors.cleaningInk),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _recurringCard() {
    final start = _appointmentStart;
    final maximum =
        CleaningRecurringScheduleGenerator.maxOccurrencesWithinWindow(
          pattern: _recurrencePattern,
          startDate: start,
        );
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AlnadhaTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.repeat_rounded,
                color: SharedPlatformColors.cleaning,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'حجز دوري لخدمة التنظيف',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text('كرّر نفس الخدمة تلقائياً في الموعد الذي تختاره.'),
                  ],
                ),
              ),
              Switch(
                key: const Key('booking_recurring_toggle'),
                value: _recurring,
                onChanged: (value) => _changeRecurrence(enabled: value),
              ),
            ],
          ),
          if (_recurring) ...[
            const Divider(),
            const Text(
              'نمط التكرار',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final pattern in [
                  CleaningRecurringPattern.weekly,
                  CleaningRecurringPattern.monthly,
                ])
                  ChoiceChip(
                    key: Key('booking_repeat_${pattern.name}'),
                    label: Text(pattern.labelAr),
                    selected: _recurrencePattern == pattern,
                    onSelected: (_) => _changeRecurrence(pattern: pattern),
                  ),
              ],
            ),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'عدد المواعيد',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                DropdownButton<int>(
                  key: const Key('booking_occurrences'),
                  value: _occurrences,
                  items: [
                    for (var count = 2; count <= min(4, maximum); count++)
                      DropdownMenuItem(
                        value: count,
                        child: Text(count.toString()),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) _changeRecurrence(count: value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            _dateChips(),
          ],
        ],
      ),
    );
  }

  List<String> _scheduleErrors(RoomScheduleDraft schedule) {
    final visitKeys = _draft.schedules
        .map((schedule) => schedule.visitKey)
        .toSet()
        .toList();
    final visitIndex = visitKeys.indexOf(schedule.visitKey);
    final scheduleIndex = _draft.schedules
        .where((candidate) => candidate.visitKey == schedule.visitKey)
        .toList()
        .indexOf(schedule);
    final prefix = 'visits.$visitIndex.roomSchedules.$scheduleIndex';
    return _fieldErrors.entries
        .where(
          (entry) =>
              entry.key.startsWith(prefix) ||
              entry.key == 'visits' ||
              entry.key == 'visits.$visitIndex',
        )
        .map((entry) => entry.value)
        .toList();
  }

  void _updateAllRoomStarts(DateTime start) {
    try {
      final next = _buildAppointment(start);
      _changeDraft(next);
    } on RangeError {
      _feedback(
        'الوقت المختار خارج فترة الحجز الدوري المتاحة، اختر تاريخاً آخر.',
      );
    }
  }

  Future<void> _pickRoomDate(RoomScheduleDraft schedule) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = await showDatePicker(
      context: context,
      initialDate: schedule.start.isBefore(today) ? today : schedule.start,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      locale: const Locale('ar'),
    );
    if (!mounted || date == null) return;
    _updateAllRoomStarts(
      DateTime(
        date.year,
        date.month,
        date.day,
        schedule.start.hour,
        schedule.start.minute,
      ),
    );
  }

  Future<void> _pickRoomTime(RoomScheduleDraft schedule) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(schedule.start),
      builder: (context, child) => Localizations.override(
        context: context,
        locale: const Locale('ar'),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        ),
      ),
    );
    if (!mounted || time == null) return;
    _updateAllRoomStarts(
      DateTime(
        schedule.start.year,
        schedule.start.month,
        schedule.start.day,
        time.hour,
        time.minute,
      ),
    );
  }

  String _quantityLabel(double quantity) =>
      quantity == quantity.truncateToDouble()
      ? quantity.toInt().toString()
      : quantity.toString();

  String _serviceSummary(PeriodSpecialistService selection) {
    final service = _services
        .where((item) => item.id == selection.serviceId)
        .firstOrNull;
    return '${service?.name ?? 'خدمة متخصصة'} · '
        '${_quantityLabel(selection.quantity)} ${_unitLabel(service)}';
  }

  Widget _materialsStep() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text('هذه المواد مطلوبة بحسب الغرف ونوع التنظيف المختار.'),
      const SizedBox(height: 12),
      _materialNeedsCard(),
      const SizedBox(height: 16),
      if (_previewReady && _materialsForBooking.isNotEmpty)
        _materialChoices(_draft.periods.firstOrNull)
      else if (!_previewReady)
        const Text('عم نجهّز قائمة المواد المطلوبة قبل اختيار المورّد.')
      else
        const Text('ما في مواد مطلوبة لهذا الحجز. يمكنك المتابعة مباشرة.'),
    ],
  );

  Widget _servicesStep() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        'الخدمات المتخصصة اختيارية. يمكنك المتابعة دون إضافة أي خدمة.',
      ),
      const SizedBox(height: 16),
      _specialistChoices(),
    ],
  );

  List<CleaningMaterialLineModel> get _materialsForBooking {
    if (_materials.isNotEmpty) return _materials;
    final seen = <String>{};
    return [
      for (final lines in _periodMaterials.values)
        for (final material in lines)
          if (seen.add(
            (material.materialTypeId ?? material.materialId)?.toString() ??
                (material.name ?? 'unknown'),
          ))
            material,
    ];
  }

  IconData _materialIcon(String? name) {
    final label = (name ?? '').toLowerCase();
    if (label.contains('زجاج') || label.contains('نوافذ')) {
      return Icons.window_outlined;
    }
    if (label.contains('قفاز') || label.contains('قفازات')) {
      return Icons.back_hand_outlined;
    }
    if (label.contains('ممسح') || label.contains('مساحة')) {
      return Icons.cleaning_services_outlined;
    }
    if (label.contains('فرشاة') || label.contains('إسفنجة')) {
      return Icons.brush_outlined;
    }
    if (label.contains('معقم') || label.contains('مطهر')) {
      return Icons.sanitizer_outlined;
    }
    if (label.contains('منظف') || label.contains('سائل')) {
      return Icons.science_outlined;
    }
    return Icons.inventory_2_outlined;
  }

  Widget _materialNeedsCard() {
    final lines = _materialsForBooking;
    return Container(
      key: const Key('booking_material_needs'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AlnadhaTokens.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  color: SharedPlatformColors.cleaning,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'المواد المطلوبة للتنظيف',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (!_previewReady && _previewLoading)
              const LinearProgressIndicator(
                key: Key('booking_material_loading'),
              ),
            if (!_previewReady && !_previewLoading)
              TextButton.icon(
                onPressed: _loadMaterialsPreview,
                icon: const Icon(Icons.refresh),
                label: const Text('تعذر عرض القائمة. إعادة المحاولة'),
              ),
            if (_previewReady && lines.isEmpty)
              const Text('لا توجد مواد تنظيف مطلوبة للغرف المختارة.'),
            if (_materialChoice == CleaningMaterialChoice.customerPartial)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'حدّد المواد الناقصة عندك، وسنوفّرها مع طلبك.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            for (final material
                in _previewReady
                    ? (_materialsExpanded ? lines : lines.take(3))
                    : <CleaningMaterialLineModel>[])
              if (_materialChoice == CleaningMaterialChoice.customerPartial &&
                  material.materialTypeId != null)
                CheckboxListTile(
                  key: Key('booking_material_${material.materialTypeId}'),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  secondary: Icon(
                    _materialIcon(material.name),
                    color: SharedPlatformColors.cleaning,
                  ),
                  title: Text(
                    material.name ?? 'مادة تنظيف',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: material.unitLabel == null
                      ? null
                      : Text(material.unitLabel!),
                  value: _missingMaterialIds.contains(material.materialTypeId),
                  onChanged: (missing) {
                    if (missing == true) {
                      _missingMaterialIds.add(material.materialTypeId!);
                    } else {
                      _missingMaterialIds.remove(material.materialTypeId);
                    }
                    _changeDraft(_draft);
                  },
                )
              else
                ListTile(
                  key: Key(
                    'booking_material_${material.materialTypeId ?? material.materialId ?? 0}',
                  ),
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: SharedPlatformColors.cleaningSoft,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      _materialIcon(material.name),
                      color: SharedPlatformColors.cleaning,
                    ),
                  ),
                  title: Text(
                    material.name ?? 'مادة تنظيف',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: material.quantity == null
                      ? (material.unitLabel == null
                            ? null
                            : Text(material.unitLabel!))
                      : Text(
                          '${_quantityLabel(material.quantity!)} '
                          '${material.unitLabel ?? material.unit ?? ''}',
                        ),
                ),
            if (_previewReady && lines.length > 3)
              TextButton.icon(
                key: const Key('booking_expand_materials'),
                onPressed: () =>
                    setState(() => _materialsExpanded = !_materialsExpanded),
                icon: Icon(
                  _materialsExpanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                ),
                label: Text(
                  _materialsExpanded
                      ? 'عرض مواد أقل'
                      : 'عرض جميع المواد المطلوبة (${lines.length})',
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _materialChoices(TimePeriodDraft? period) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Text(
          'من سيوفر مواد التنظيف؟',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: SharedPlatformColors.cleaningInk,
          ),
        ),
      ),
      RadioGroup<CleaningMaterialChoice>(
        groupValue: _materialChoice,
        onChanged: (selected) {
          if (selected == CleaningMaterialChoice.customerPartial &&
              _materialChoice != CleaningMaterialChoice.customerPartial) {
            _missingMaterialIds.clear();
          } else if (selected != CleaningMaterialChoice.customerPartial) {
            _missingMaterialIds.clear();
          }
          _materialChoice = selected;
          _changeDraft(_draft);
        },
        child: Column(
          children: [
            for (final choice in CleaningMaterialChoice.values)
              Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 10),
                color: _materialChoice == choice
                    ? SharedPlatformColors.cleaningSoft
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: _materialChoice == choice
                        ? SharedPlatformColors.cleaning
                        : AlnadhaTokens.border,
                    width: _materialChoice == choice ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: RadioListTile<CleaningMaterialChoice>(
                  key: Key('material_choice_${choice.apiValue}'),
                  activeColor: SharedPlatformColors.cleaning,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  secondary: Icon(switch (choice) {
                    CleaningMaterialChoice.customerAll => Icons.home_outlined,
                    CleaningMaterialChoice.customerPartial =>
                      Icons.checklist_rtl_outlined,
                    CleaningMaterialChoice.platformAll =>
                      Icons.local_shipping_outlined,
                  }, color: SharedPlatformColors.cleaning),
                  title: Text(
                    choice.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: SharedPlatformColors.cleaningInk,
                    ),
                  ),
                  subtitle: Text(switch (choice) {
                    CleaningMaterialChoice.customerAll =>
                      'لا حاجة لإضافة مواد للطلب',
                    CleaningMaterialChoice.customerPartial =>
                      'حدّد المواد الناقصة عندك؛ نوفّرها لك',
                    CleaningMaterialChoice.platformAll =>
                      'نوفر المواد المطلوبة لهذا الطلب',
                  }),
                  value: choice,
                ),
              ),
          ],
        ),
      ),
    ],
  );

  Widget _specialistChoices() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (_loadingServices)
        const Padding(
          padding: EdgeInsets.all(12),
          child: Center(child: CircularProgressIndicator()),
        ),
      if (_servicesCatalogError)
        TextButton.icon(
          onPressed: _loadSpecialServicesCatalog,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('تعذّر تحميل الخدمات. إعادة المحاولة'),
        ),
      if (_services.isEmpty && !_loadingServices && !_servicesCatalogError)
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text('لا توجد خدمات إضافية متاحة حالياً، يمكنك المتابعة.'),
        ),
      for (final service in _services.where((service) => service.id != null))
        Container(
          key: Key('special_service_card_${service.id}'),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color:
                _bookingServices.any(
                  (selected) => selected.serviceId == service.id,
                )
                ? SharedPlatformColors.cleaningSoft
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color:
                  _bookingServices.any(
                    (selected) => selected.serviceId == service.id,
                  )
                  ? SharedPlatformColors.cleaning
                  : AlnadhaTokens.border,
              width:
                  _bookingServices.any(
                    (selected) => selected.serviceId == service.id,
                  )
                  ? 2
                  : 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              key: Key('special_service_${service.id}'),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F3FA),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  _serviceIcon(service),
                  color: SharedPlatformColors.cleaningInk,
                ),
              ),
              title: Text(
                service.name ?? 'خدمة متخصصة',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: service.description == null
                  ? null
                  : Text(
                      service.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_bookingServices.any(
                    (selected) => selected.serviceId == service.id,
                  ))
                    IconButton(
                      key: Key('special_service_remove_${service.id}'),
                      tooltip: 'إزالة الخدمة',
                      onPressed: () {
                        _bookingServices.removeWhere(
                          (selected) => selected.serviceId == service.id,
                        );
                        _changeDraft(_draft);
                      },
                      icon: const Icon(Icons.close_rounded, size: 19),
                    ),
                  TextButton(
                    key: Key('special_service_action_${service.id}'),
                    onPressed: () => _editService(
                      service,
                      existing: _bookingServices
                          .where((selected) => selected.serviceId == service.id)
                          .firstOrNull,
                    ),
                    child: Text(
                      _bookingServices.any(
                            (selected) => selected.serviceId == service.id,
                          )
                          ? 'تعديل'
                          : '+',
                    ),
                  ),
                ],
              ),
              onTap: () => _editService(
                service,
                existing: _bookingServices
                    .where((selected) => selected.serviceId == service.id)
                    .firstOrNull,
              ),
            ),
          ),
        ),
    ],
  );

  IconData _serviceIcon(CleaningServiceModel service) {
    final name = service.name ?? '';
    if (name.contains('سجاد')) return Icons.grid_on_outlined;
    if (name.contains('كنب') || name.contains('أثاث')) {
      return Icons.chair_outlined;
    }
    if (name.contains('زجاج') || name.contains('نوافذ')) {
      return Icons.window_outlined;
    }
    if (name.contains('فرن')) return Icons.microwave_outlined;
    if (name.contains('حمام')) return Icons.bathtub_outlined;
    if (name.contains('مطبخ')) return Icons.kitchen_outlined;
    return Icons.cleaning_services_outlined;
  }

  String _unitLabel(CleaningServiceModel? service) =>
      switch (service?.unitCode ?? service?.pricingUnit) {
        'm2' || 'sqm' || 'square_meter' || 'per_sqm' => 'متر مربع',
        'sofa' || 'per_sofa' => 'كنبة',
        'carpet' || 'per_carpet' => 'سجادة',
        'hour' || 'per_hour' => 'ساعة',
        'room' || 'per_room' => 'غرفة',
        'seat' || 'per_seat' => 'مقعد',
        'piece' || 'item' || 'per_item' => 'قطعة',
        _ => 'وحدة حسب الخدمة',
      };

  Future<void> _editService(
    CleaningServiceModel service, {
    PeriodSpecialistService? existing,
  }) async {
    // Each entered quantity belongs to a single service selection. Assign a
    // single operational room anchor instead of multiplying quantity and
    // duration by the number of unrelated rooms in the home.
    final targets = <String>{
      if (existing != null && existing.targetRoomKeys.isNotEmpty)
        existing.targetRoomKeys.first
      else if (_draft.rooms.isNotEmpty)
        _draft.rooms.first.key,
    };
    double quantity = existing?.quantity ?? 1;
    final unit = service.unitCode ?? service.pricingUnit;
    final allowsFractions = {
      'm2',
      'sqm',
      'square_meter',
      'per_sqm',
    }.contains(unit);
    var dirtiness = existing?.dirtiness ?? 'light';
    final approved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      builder: (context) => StatefulBuilder(
        builder: (context, rebuild) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        service.name ?? 'خدمة متخصصة',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: SharedPlatformColors.cleaningInk,
                        ),
                      ),
                    ),
                    IconButton(
                      key: const Key('special_service_close'),
                      tooltip: 'العودة للخدمات المتخصصة',
                      onPressed: () => Navigator.pop(context, false),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                TextFormField(
                  key: const Key('special_service_quantity'),
                  initialValue: _quantityLabel(quantity),
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: allowsFractions,
                  ),
                  decoration: InputDecoration(
                    labelText: 'الكمية (${_unitLabel(service)})',
                  ),
                  onChanged: (text) => rebuild(() {
                    final parsed = double.tryParse(text.replaceAll(',', '.'));
                    quantity =
                        parsed == null ||
                            (!allowsFractions &&
                                parsed != parsed.truncateToDouble())
                        ? 0
                        : parsed;
                  }),
                ),
                if (service.supportsDirtiness)
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final level in ['light', 'heavy'])
                        ChoiceChip(
                          label: Text(
                            level == 'light' ? 'اتساخ بسيط' : 'اتساخ شديد',
                          ),
                          selected: dirtiness == level,
                          onSelected: (_) => rebuild(() => dirtiness = level),
                        ),
                    ],
                  ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('قد تتغير المدة المتوقعة بحسب الخدمة والكمية.'),
                ),
                FilledButton(
                  key: const Key('special_service_save'),
                  onPressed: quantity > 0 && quantity.isFinite
                      ? () => Navigator.pop(context, true)
                      : null,
                  child: Text(
                    existing == null ? 'إضافة الخدمة' : 'حفظ التعديلات',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (!mounted || approved != true) return;
    final selected = PeriodSpecialistService(
      serviceKey: existing?.serviceKey ?? _uuid(),
      serviceId: service.id!,
      targetRoomKeys: targets.toList(),
      quantity: quantity,
      dirtiness: service.supportsDirtiness ? dirtiness : null,
    );
    if (existing == null) {
      _bookingServices.add(selected);
    } else {
      final index = _bookingServices.indexWhere(
        (item) => item.serviceKey == existing.serviceKey,
      );
      if (index >= 0) {
        _bookingServices[index] = selected;
      } else {
        _bookingServices.add(selected);
      }
    }
    _servicesReviewed = true;
    _changeDraft(_draft);
  }

  void _editReviewStep(int step) {
    _editingFromReview = true;
    setState(() => _step = step);
    _save();
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  Widget _reviewCard({
    required String title,
    required IconData icon,
    required int editStep,
    required Widget child,
  }) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: AlnadhaTokens.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, color: SharedPlatformColors.cleaning, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: SharedPlatformColors.cleaningInk,
                ),
              ),
            ),
            IconButton(
              tooltip: 'تعديل $title',
              onPressed: () => _editReviewStep(editStep),
              icon: const Icon(Icons.edit_outlined, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Material(type: MaterialType.transparency, child: child),
      ],
    ),
  );

  Widget _review() {
    final duration = cleaningTeamDurationMinutes(_draft);
    final materialNames = [
      for (final material in _materialsForBooking)
        if (_missingMaterialIds.contains(material.materialTypeId))
          material.name ?? 'مادة تنظيف',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _reviewCard(
          title: 'العنوان والموعد',
          icon: Icons.location_on_outlined,
          editStep: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _address.value?.label ?? 'اختر عنوان الخدمة',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(_address.value?.line1 ?? '', softWrap: true),
              const SizedBox(height: 8),
              if (_visitDates.isNotEmpty)
                Text(
                  'موعد البداية: ${_visitDates.first.toIso8601String().substring(0, 10)} · ${cleaningClock(_visitDates.first)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
            ],
          ),
        ),
        _reviewCard(
          title: 'فريق التنظيف',
          icon: Icons.groups_2_outlined,
          editStep: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('عدد العمال: $_teamWorkers'),
              if (duration != null) Text('المدة المتوقعة: $duration دقيقة'),
              Text(
                _preferred && _workerIds.isNotEmpty
                    ? 'تم تحديد تفضيل لعامل سبق التعامل معه.'
                    : 'سيتم اختيار العمال المؤهلين بحسب الإتاحة.',
              ),
              if (_teamWorkers > 1) _teamSupervisorNotice(),
            ],
          ),
        ),
        _reviewCard(
          title: 'المواعيد والتكرار',
          icon: Icons.repeat_outlined,
          editStep: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _recurring
                    ? 'حجز ${_recurrencePattern.labelAr} · ${_visitDates.length} مواعيد'
                    : 'حجز لمرة واحدة',
              ),
              const SizedBox(height: 8),
              _dateChips(),
            ],
          ),
        ),
        _reviewCard(
          title: 'الغرف ونوع التنظيف',
          icon: Icons.meeting_room_outlined,
          editStep: 2,
          child: Column(
            children: [
              for (final room in _draft.rooms)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.check_circle_outline,
                    color: SharedPlatformColors.cleaning,
                  ),
                  title: Text(cleaningRoomLabel(room)),
                  subtitle: Text(
                    '${cleaningSizeLabel(room.size)} · ${room.cleaningType.title}',
                  ),
                ),
            ],
          ),
        ),
        _reviewCard(
          title: 'مواد التنظيف',
          icon: Icons.inventory_2_outlined,
          editStep: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _materialChoice?.label ?? 'لم يتم تحديد من سيوفر المواد',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              if (_materialChoice ==
                  CleaningMaterialChoice.customerPartial) ...[
                Text(
                  'ستوفر المنصة المواد الناقصة المختارة فقط (${materialNames.length}):',
                ),
                Text(materialNames.join('، ')),
                const Text('بقية مواد التنظيف سيوفرها العميل.'),
              ],
              if (_materialChoice == CleaningMaterialChoice.platformAll)
                Text(
                  'ستوفر المنصة جميع المواد المطلوبة (${_materialsForBooking.length}).',
                ),
              if (_materialChoice == CleaningMaterialChoice.customerAll)
                const Text(
                  'العميل سيوفر جميع المواد ولا تُضاف مواد إلى الطلب.',
                ),
              if (_materialsForBooking.isNotEmpty)
                ExpansionTile(
                  key: const Key('booking_review_materials'),
                  tilePadding: EdgeInsets.zero,
                  title: Text(
                    'عرض جميع المواد المطلوبة للغرف (${_materialsForBooking.length})',
                  ),
                  subtitle: Text(
                    _materialChoice == CleaningMaterialChoice.customerAll
                        ? 'هذه قائمة مرجعية بالمواد المطلوبة، وجميعها متوفرة لديك.'
                        : _materialChoice == CleaningMaterialChoice.platformAll
                        ? 'هذه المواد ستوفرها المنصة مع الطلب.'
                        : 'هذه قائمة مرجعية للمواد المطلوبة، ومنها اخترت المواد الناقصة.',
                  ),
                  children: [
                    for (final material in _materialsForBooking)
                      ListTile(
                        dense: true,
                        title: Text(material.name ?? 'مادة تنظيف'),
                        subtitle: material.quantity == null
                            ? null
                            : Text(
                                '${material.quantity} ${material.unitLabel ?? material.unit ?? ''}',
                              ),
                      ),
                  ],
                ),
            ],
          ),
        ),
        _reviewCard(
          title: 'الخدمات المتخصصة',
          icon: Icons.auto_awesome_outlined,
          editStep: 1,
          child: _bookingServices.isEmpty
              ? const Text('لا توجد خدمات إضافية')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final selection in _bookingServices)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          '• ${_serviceSummary(selection)}${selection.dirtiness == 'heavy'
                              ? ' · اتساخ شديد'
                              : selection.dirtiness == 'light'
                              ? ' · اتساخ بسيط'
                              : ''}',
                        ),
                      ),
                  ],
                ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: TextField(
            key: const Key('booking_review_notes'),
            controller: _notes,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'ملاحظات الطلب (اختياري)',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 4, bottom: 12),
          child: Text(
            'الخدمة: تنظيف المنزل',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: SharedPlatformColors.cleaningSoft,
            borderRadius: BorderRadius.circular(19),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'الإجمالي النهائي لجميع المواعيد',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                _quoteCurrent
                    ? '${_quote!.pricing?.totalPrice?.toStringAsFixed(0) ?? '—'} ${(_quote!.pricing?.currency ?? 'SYP') == 'SYP' ? 'ل.س' : (_quote!.pricing?.currency ?? '')}'
                    : 'بانتظار تحديث الإجمالي',
                key: const Key('booking_total'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: SharedPlatformColors.cleaningInk,
                ),
              ),
              if (!_quoteCurrent)
                TextButton.icon(
                  onPressed: _quoting ? null : _refreshQuote,
                  icon: const Icon(Icons.refresh),
                  label: const Text('تحديث السعر'),
                ),
            ],
          ),
        ),
        CheckboxListTile(
          title: const Text('أوافق على شروط الخدمة والسعر المعروض'),
          value: _terms,
          onChanged: (accepted) {
            setState(() => _terms = accepted == true);
            _save();
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    SessionExpiredHandler.unregisterRecovery(this);
    _save();
    _debounce?.cancel();
    _expiry?.cancel();
    _notes.removeListener(_inputChanged);
    _notes.dispose();
    _address.dispose();
    _scroll.dispose();
    super.dispose();
  }
}
