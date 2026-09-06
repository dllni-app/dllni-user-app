from pathlib import Path


def read(path: str) -> str:
    return Path(path).read_text()


def write(path: str, text: str) -> None:
    Path(path).write_text(text)


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{label}: expected 1 match, found {count}')
    return text.replace(old, new, 1)


# Shared recurring worker-scope contract.
path = 'lib/features/cl_main/domain/models/cleaning_recurring_session.dart'
text = read(path)
text = replace_once(
    text,
    "const int cleaningRecurringMaxWindowDays = 30;\n",
    "import 'cleaning_assignment_mode.dart';\n\nconst int cleaningRecurringMaxWindowDays = 30;\n",
    'model import',
)
text = replace_once(
    text,
    "enum CleaningRecurringCalculationMode { task, hours }\n\nextension CleaningRecurringCalculationModeX",
    """enum CleaningRecurringCalculationMode { task, hours }

enum CleaningRecurringWorkerScope { any, specific }

extension CleaningRecurringWorkerScopeX on CleaningRecurringWorkerScope {
  String get apiValue => switch (this) {
    CleaningRecurringWorkerScope.any => 'any',
    CleaningRecurringWorkerScope.specific => 'specific',
  };

  String get labelAr => switch (this) {
    CleaningRecurringWorkerScope.any => 'أي عامل متاح',
    CleaningRecurringWorkerScope.specific => 'عمال محددون فقط',
  };

  String get descriptionAr => switch (this) {
    CleaningRecurringWorkerScope.any =>
      'يمكن لأي عامل مؤهل ومتاح قبول مقعد في كل زيارة.',
    CleaningRecurringWorkerScope.specific =>
      'تُحصر الزيارات بالعمال الذين تختارهم فقط، ولن يتم فتحها تلقائياً لعمال آخرين.',
  };
}

class CleaningRecurringWorkerSelection {
  const CleaningRecurringWorkerSelection({
    required this.scope,
    required this.workerIds,
    required this.assignmentMode,
    required this.numberOfWorkers,
  });

  final CleaningRecurringWorkerScope scope;
  final List<int> workerIds;
  final CleaningAssignmentMode assignmentMode;
  final int numberOfWorkers;

  static CleaningRecurringWorkerSelection resolve({
    required bool isRecurring,
    required CleaningRecurringWorkerScope recurringScope,
    required List<int> selectedWorkerIds,
    required CleaningAssignmentMode legacyAssignmentMode,
    required int? requestedWorkers,
  }) {
    final workerIds = <int>[];
    for (final id in selectedWorkerIds) {
      if (id <= 0 || workerIds.contains(id)) continue;
      workerIds.add(id);
    }
    final safeRequested = (requestedWorkers ?? 1) < 1
        ? 1
        : requestedWorkers ?? 1;

    if (isRecurring) {
      if (recurringScope == CleaningRecurringWorkerScope.any) {
        return CleaningRecurringWorkerSelection(
          scope: recurringScope,
          workerIds: const <int>[],
          assignmentMode: CleaningAssignmentMode.openCount,
          numberOfWorkers: safeRequested,
        );
      }

      return CleaningRecurringWorkerSelection(
        scope: recurringScope,
        workerIds: List<int>.unmodifiable(workerIds),
        assignmentMode: workerIds.length <= 1
            ? CleaningAssignmentMode.preferredWorker
            : CleaningAssignmentMode.openCount,
        numberOfWorkers: workerIds.isEmpty ? 1 : workerIds.length,
      );
    }

    var effectiveMode = legacyAssignmentMode;
    if (workerIds.isNotEmpty &&
        (legacyAssignmentMode == CleaningAssignmentMode.openCount ||
            safeRequested > 1 ||
            workerIds.length > 1)) {
      effectiveMode = CleaningAssignmentMode.openCount;
    } else if (workerIds.isNotEmpty) {
      effectiveMode = CleaningAssignmentMode.preferredWorker;
    }

    final resolvedWorkers =
        effectiveMode == CleaningAssignmentMode.preferredWorker
        ? 1
        : (workerIds.length > safeRequested ? workerIds.length : safeRequested);

    return CleaningRecurringWorkerSelection(
      scope: recurringScope,
      workerIds: List<int>.unmodifiable(workerIds),
      assignmentMode: effectiveMode,
      numberOfWorkers: resolvedWorkers,
    );
  }
}

extension CleaningRecurringCalculationModeX""",
    'worker scope model',
)
write(path, text)


# Create request serialization.
path = 'lib/features/cl_main/domain/usecases/create_cleaning_order_use_case.dart'
text = read(path)
text = replace_once(
    text,
    '  final double? recurringHoursPerVisit;\n  final String? specialRequirement;',
    '  final double? recurringHoursPerVisit;\n  final CleaningRecurringWorkerScope recurringWorkerScope;\n  final String? specialRequirement;',
    'create field',
)
text = replace_once(
    text,
    '    this.recurringHoursPerVisit,\n    this.assignmentMode = CleaningAssignmentMode.preferredWorker,',
    '    this.recurringHoursPerVisit,\n    this.recurringWorkerScope = CleaningRecurringWorkerScope.any,\n    this.assignmentMode = CleaningAssignmentMode.preferredWorker,',
    'create constructor',
)
text = replace_once(
    text,
    '       recurringCalculationMode = CleaningRecurringCalculationMode.task,\n       recurringHoursPerVisit = null;',
    '       recurringCalculationMode = CleaningRecurringCalculationMode.task,\n       recurringHoursPerVisit = null,\n       recurringWorkerScope = CleaningRecurringWorkerScope.any;',
    'event create initializer',
)
start = text.index('  CleaningAssignmentMode _effectiveAssignmentMode(List<int> workerIds) {')
end = text.index('  List<String> _sanitizeCleaningServices()', start)
text = text[:start] + text[end:]
text = replace_once(
    text,
    """  BodyMap getBody() {
    final workerIds = _sanitizePreferredWorkerIds();
    final effectiveAssignmentMode = _effectiveAssignmentMode(workerIds);
    final normalizedCouponCode = couponCode?.trim();
    final schedule = _isEventAssistance
        ? _normalizedEventSessions.scheduleJson
        : _normalizedRecurringSessions.scheduleJsonFor(
            calculationMode: recurringCalculationMode,
            hoursPerVisit: recurringHoursPerVisit,
          );
""",
    """  BodyMap getBody() {
    final sanitizedWorkerIds = _sanitizePreferredWorkerIds();
    final isRecurring =
        !_isEventAssistance && _normalizedRecurringSessions.isNotEmpty;
    final workerSelection = CleaningRecurringWorkerSelection.resolve(
      isRecurring: isRecurring,
      recurringScope: recurringWorkerScope,
      selectedWorkerIds: sanitizedWorkerIds,
      legacyAssignmentMode: assignmentMode,
      requestedWorkers: numberOfWorkers,
    );
    final workerIds = workerSelection.workerIds;
    final normalizedCouponCode = couponCode?.trim();
    final schedule = _isEventAssistance
        ? _normalizedEventSessions.scheduleJson
        : _normalizedRecurringSessions.scheduleJsonFor(
            calculationMode: recurringCalculationMode,
            hoursPerVisit: recurringHoursPerVisit,
          );
""",
    'create body setup',
)
text = replace_once(
    text,
    """      'assignmentMode': effectiveAssignmentMode.apiValue,
      if (workerIds.isNotEmpty) 'preferredWorkerIds': workerIds,
      'termsAccepted': termsAccepted,
""",
    """      'assignmentMode': workerSelection.assignmentMode.apiValue,
      if (isRecurring) 'workerScope': workerSelection.scope.apiValue,
      if (workerIds.isNotEmpty) 'preferredWorkerIds': workerIds,
      'termsAccepted': termsAccepted,
""",
    'create body worker scope',
)
text = replace_once(
    text,
    """      'numberOfWorkers': _resolvedNumberOfWorkers(
        workerIds,
        effectiveAssignmentMode,
      ),
""",
    "      'numberOfWorkers': workerSelection.numberOfWorkers,\n",
    'create worker count',
)
write(path, text)


# Estimate request serialization.
path = 'lib/features/cl_main/domain/usecases/estimate_cleaning_price_use_case.dart'
text = read(path)
text = replace_once(
    text,
    '  final double? recurringHoursPerVisit;\n  final String? specialRequirement;',
    '  final double? recurringHoursPerVisit;\n  final CleaningRecurringWorkerScope recurringWorkerScope;\n  final String? specialRequirement;',
    'estimate field',
)
text = replace_once(
    text,
    '    this.recurringHoursPerVisit,\n    this.assignmentMode = CleaningAssignmentMode.preferredWorker,',
    '    this.recurringHoursPerVisit,\n    this.recurringWorkerScope = CleaningRecurringWorkerScope.any,\n    this.assignmentMode = CleaningAssignmentMode.preferredWorker,',
    'estimate constructor',
)
text = replace_once(
    text,
    '       recurringCalculationMode = CleaningRecurringCalculationMode.task,\n       recurringHoursPerVisit = null;',
    '       recurringCalculationMode = CleaningRecurringCalculationMode.task,\n       recurringHoursPerVisit = null,\n       recurringWorkerScope = CleaningRecurringWorkerScope.any;',
    'event estimate initializer',
)
start = text.index('  CleaningAssignmentMode _effectiveAssignmentMode(List<int> workerIds) {')
end = text.index('  int? get _resolvedBedrooms', start)
text = text[:start] + text[end:]
text = replace_once(
    text,
    """  Map<String, dynamic> _buildBody() {
    final workerIds = _sanitizePreferredWorkerIds();
    final effectiveAssignmentMode = _effectiveAssignmentMode(workerIds);
    final hasAddressId = addressId != null && addressId! > 0;
""",
    """  Map<String, dynamic> _buildBody() {
    final sanitizedWorkerIds = _sanitizePreferredWorkerIds();
    final isRecurring =
        !_isEventAssistance && _normalizedRecurringSessions.isNotEmpty;
    final workerSelection = CleaningRecurringWorkerSelection.resolve(
      isRecurring: isRecurring,
      recurringScope: recurringWorkerScope,
      selectedWorkerIds: sanitizedWorkerIds,
      legacyAssignmentMode: assignmentMode,
      requestedWorkers: numberOfWorkers,
    );
    final workerIds = workerSelection.workerIds;
    final hasAddressId = addressId != null && addressId! > 0;
""",
    'estimate body setup',
)
text = replace_once(
    text,
    """      'assignmentMode': effectiveAssignmentMode.apiValue,
      if (workerIds.isNotEmpty) 'preferredWorkerIds': workerIds,
      'numberOfWorkers': _resolvedNumberOfWorkers(
        workerIds,
        effectiveAssignmentMode,
      ),
""",
    """      'assignmentMode': workerSelection.assignmentMode.apiValue,
      if (isRecurring) 'workerScope': workerSelection.scope.apiValue,
      if (workerIds.isNotEmpty) 'preferredWorkerIds': workerIds,
      'numberOfWorkers': workerSelection.numberOfWorkers,
""",
    'estimate body worker scope',
)
write(path, text)


# Recurring UI card.
path = 'lib/features/cl_main/view/widgets/cl_recurring_schedule_section_widget.dart'
text = read(path)
text = replace_once(
    text,
    '    required this.pattern,\n    this.calculationMode = CleaningRecurringCalculationMode.task,',
    '    required this.pattern,\n    this.workerScope = CleaningRecurringWorkerScope.any,\n    this.calculationMode = CleaningRecurringCalculationMode.task,',
    'widget constructor scope',
)
text = replace_once(
    text,
    '    required this.onPatternChanged,\n    this.onCalculationModeChanged,',
    '    required this.onPatternChanged,\n    this.onWorkerScopeChanged,\n    this.onCalculationModeChanged,',
    'widget callback constructor',
)
text = replace_once(
    text,
    '  final CleaningRecurringPattern pattern;\n  final CleaningRecurringCalculationMode calculationMode;',
    '  final CleaningRecurringPattern pattern;\n  final CleaningRecurringWorkerScope workerScope;\n  final CleaningRecurringCalculationMode calculationMode;',
    'widget field scope',
)
text = replace_once(
    text,
    '  final ValueChanged<CleaningRecurringPattern> onPatternChanged;\n  final ValueChanged<CleaningRecurringCalculationMode>?',
    '  final ValueChanged<CleaningRecurringPattern> onPatternChanged;\n  final ValueChanged<CleaningRecurringWorkerScope>? onWorkerScopeChanged;\n  final ValueChanged<CleaningRecurringCalculationMode>?',
    'widget field callback',
)
text = replace_once(
    text,
    """            if (enabled) ...[
              const Divider(height: 22),
              DropdownButtonFormField<CleaningRecurringCalculationMode>(
""",
    """            if (enabled) ...[
              const Divider(height: 22),
              DropdownButtonFormField<CleaningRecurringWorkerScope>(
                initialValue: workerScope,
                decoration: const InputDecoration(
                  labelText: 'نطاق العمال لكل زيارة',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: CleaningRecurringWorkerScope.values
                    .map(
                      (item) => DropdownMenuItem<CleaningRecurringWorkerScope>(
                        value: item,
                        child: Text(item.labelAr),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) onWorkerScopeChanged?.call(value);
                },
              ),
              const SizedBox(height: 6),
              Text(
                workerScope.descriptionAr,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CleaningRecurringCalculationMode>(
""",
    'widget scope UI',
)
write(path, text)


# Schedule screen state + scope-aware UX and serialization.
path = 'lib/features/cl_main/view/screens/cl_main_service_schedule_screen.dart'
text = read(path)
text = replace_once(
    text,
    """  CleaningRecurringCalculationMode _recurringCalculationMode =
      CleaningRecurringCalculationMode.task;
  double _recurringHoursPerVisit = 2;
""",
    """  CleaningRecurringCalculationMode _recurringCalculationMode =
      CleaningRecurringCalculationMode.task;
  CleaningRecurringWorkerScope _recurringWorkerScope =
      CleaningRecurringWorkerScope.any;
  double _recurringHoursPerVisit = 2;
""",
    'screen scope state',
)
text = replace_once(
    text,
    """                            pattern: _recurringPattern,
                            calculationMode: _recurringCalculationMode,
""",
    """                            pattern: _recurringPattern,
                            workerScope: _recurringWorkerScope,
                            calculationMode: _recurringCalculationMode,
""",
    'screen widget scope',
)
text = replace_once(
    text,
    """                            onPatternChanged: (pattern) =>
                                _setRecurringPattern(pattern, state),
                            onCalculationModeChanged: (mode) =>
""",
    """                            onPatternChanged: (pattern) =>
                                _setRecurringPattern(pattern, state),
                            onWorkerScopeChanged: (scope) =>
                                _setRecurringWorkerScope(scope, state),
                            onCalculationModeChanged: (mode) =>
""",
    'screen widget callback',
)
old_workers = """                          const SizedBox(height: 10),
                          ClScheduledPreviousWorkersSectionWidget(
                            bloc: bloc,
                            propertyType: _routeArgs?.propertyType ?? '',
                            scheduledDate:
                                CleaningScheduleDateTimeLogic.formatDateApi(
                                  _selectedDate,
                                ),
                            scheduledTime: _fromTimeHhMm,
                            durationHours: _effectiveServiceHours(
                              estimatedHours: _perVisitEstimatedHours(estimate),
                              numberOfWorkers: _requiredWorkersCount(state),
                            ),
                            onSelectedWorkersChanged: (workerIds) {
                              _requestUpdatedEstimate(
                                state,
                                selectedWorkerIds: workerIds,
                              );
                            },
                          ),
                          const SizedBox(height: 10),
"""
new_workers = """                          const SizedBox(height: 10),
                          if (!_isRecurring ||
                              _recurringWorkerScope ==
                                  CleaningRecurringWorkerScope.specific) ...[
                            ClScheduledPreviousWorkersSectionWidget(
                              bloc: bloc,
                              propertyType: _routeArgs?.propertyType ?? '',
                              scheduledDate:
                                  CleaningScheduleDateTimeLogic.formatDateApi(
                                    _selectedDate,
                                  ),
                              scheduledTime: _fromTimeHhMm,
                              durationHours: _effectiveServiceHours(
                                estimatedHours: _perVisitEstimatedHours(estimate),
                                numberOfWorkers: _requiredWorkersCount(state),
                              ),
                              onSelectedWorkersChanged: (workerIds) {
                                _requestUpdatedEstimate(
                                  state,
                                  selectedWorkerIds: workerIds,
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
"""
text = replace_once(text, old_workers, new_workers, 'screen worker picker visibility')
text = replace_once(
    text,
    """      _recurringCalculationMode = CleaningRecurringCalculationMode.task;
      _recurringHoursPerVisit = 2;
""",
    """      _recurringCalculationMode = CleaningRecurringCalculationMode.task;
      _recurringWorkerScope = enabled && state.selectedWorkerIds.isNotEmpty
          ? CleaningRecurringWorkerScope.specific
          : CleaningRecurringWorkerScope.any;
      _recurringHoursPerVisit = 2;
""",
    'screen enable scope',
)
insert_after = """    _requestUpdatedEstimate(state);
  }

  void _setRecurringCalculationMode(
"""
scope_method = """    _requestUpdatedEstimate(state);
  }

  void _setRecurringWorkerScope(
    CleaningRecurringWorkerScope scope,
    ClMainState state,
  ) {
    if (!_isRecurring || scope == _recurringWorkerScope) return;
    setState(() {
      _recurringWorkerScope = scope;
      _resetAppliedCoupon(
        message: 'تم تغيير نطاق العمال. أعد تطبيق الكوبون.',
      );
    });
    if (scope == CleaningRecurringWorkerScope.any) {
      _bloc?.add(ClearPreferredWorkersEvent());
      _requestUpdatedEstimate(
        state,
        selectedWorkerIds: const <int>[],
      );
      return;
    }
    if (state.selectedWorkerIds.isNotEmpty) {
      _requestUpdatedEstimate(state);
    }
  }

  void _setRecurringCalculationMode(
"""
text = replace_once(text, insert_after, scope_method, 'screen scope method')
text = replace_once(
    text,
    """  int _requiredWorkersCount(ClMainState state) {
    final openCount = state.assignmentMode == CleaningAssignmentMode.openCount
        ? (state.numberOfWorkers < 1 ? 1 : state.numberOfWorkers)
        : 1;
    final preferredCount = state.selectedWorkerIds.length;
    return preferredCount > openCount ? preferredCount : openCount;
  }
""",
    """  int _requiredWorkersCount(ClMainState state) {
    if (_isRecurring &&
        _recurringWorkerScope == CleaningRecurringWorkerScope.specific) {
      return state.selectedWorkerIds.isEmpty ? 1 : state.selectedWorkerIds.length;
    }
    final openCount = state.assignmentMode == CleaningAssignmentMode.openCount
        ? (state.numberOfWorkers < 1 ? 1 : state.numberOfWorkers)
        : 1;
    final preferredCount = _isRecurring ? 0 : state.selectedWorkerIds.length;
    return preferredCount > openCount ? preferredCount : openCount;
  }
""",
    'screen worker count',
)
text = replace_once(
    text,
    """    final estimateForWorkers = _currentEstimate ?? args.estimate;
    final estimatedHours = _perVisitEstimatedHours(estimateForWorkers);
""",
    """    if (_isRecurring &&
        _recurringWorkerScope == CleaningRecurringWorkerScope.specific &&
        state.selectedWorkerIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى اختيار عامل واحد على الأقل للحجز الدوري المحدد.',
          ),
        ),
      );
      return;
    }

    final estimateForWorkers = _currentEstimate ?? args.estimate;
    final estimatedHours = _perVisitEstimatedHours(estimateForWorkers);
""",
    'screen submit scope validation',
)
text = replace_once(
    text,
    """    final estimate = _currentEstimate ?? _routeArgs?.estimate;
    final normalizedAssignments = estimate?.workerRoomAssignments ?? const [];
    final workerRoomAssignments = normalizedAssignments.isNotEmpty
        ? workerRoomAssignmentsToRequestJson(normalizedAssignments)
        : buildWorkerRoomAssignmentsJson(
            slotByRoomKey: state.workerRoomAssignments,
            units: enumerateRoomUnits(args.roomSizeBreakdown),
            preferredWorkerId: state.primarySelectedWorkerId,
            assignmentMode: state.assignmentMode,
          );
    final selectedWorkerIds = state.selectedWorkerIds;
""",
    """    final estimate = _currentEstimate ?? _routeArgs?.estimate;
    final selectedWorkerIds =
        _isRecurring &&
            _recurringWorkerScope == CleaningRecurringWorkerScope.any
        ? const <int>[]
        : state.selectedWorkerIds;
    final requestAssignmentMode = _isRecurring
        ? (_recurringWorkerScope == CleaningRecurringWorkerScope.any
              ? CleaningAssignmentMode.openCount
              : (selectedWorkerIds.length <= 1
                    ? CleaningAssignmentMode.preferredWorker
                    : CleaningAssignmentMode.openCount))
        : state.assignmentMode;
    final normalizedAssignments = estimate?.workerRoomAssignments ?? const [];
    final workerRoomAssignments = normalizedAssignments.isNotEmpty
        ? workerRoomAssignmentsToRequestJson(normalizedAssignments)
        : buildWorkerRoomAssignmentsJson(
            slotByRoomKey: state.workerRoomAssignments,
            units: enumerateRoomUnits(args.roomSizeBreakdown),
            preferredWorkerId: selectedWorkerIds.isEmpty
                ? null
                : selectedWorkerIds.first,
            assignmentMode: requestAssignmentMode,
          );
""",
    'screen canonical submit workers',
)
text = replace_once(
    text,
    '          assignmentMode: state.assignmentMode,\n          numberOfWorkers: selectedWorkers,',
    '          assignmentMode: requestAssignmentMode,\n          numberOfWorkers: selectedWorkers,',
    'screen submit assignment mode',
)
text = replace_once(
    text,
    """          recurringHoursPerVisit:
              _recurringCalculationMode ==
                  CleaningRecurringCalculationMode.hours
              ? _recurringHoursPerVisit
              : null,
          cleaningServices: _selectedCleaningServicesPayload(),
""",
    """          recurringHoursPerVisit:
              _recurringCalculationMode ==
                  CleaningRecurringCalculationMode.hours
              ? _recurringHoursPerVisit
              : null,
          recurringWorkerScope: _recurringWorkerScope,
          cleaningServices: _selectedCleaningServicesPayload(),
""",
    'screen submit scope param',
)
old_estimate = """    final workerIds = selectedWorkerIds ?? state.selectedWorkerIds;
    final preferredWorkerId = workerIds.isEmpty ? null : workerIds.first;
    final stateWorkerCount = state.numberOfWorkers < 1
        ? 1
        : state.numberOfWorkers;
    final requestedWorkers = workerIds.length > stateWorkerCount
        ? workerIds.length
        : stateWorkerCount;
    final assignmentMode = requestedWorkers > 1
        ? CleaningAssignmentMode.openCount
        : state.assignmentMode;
"""
new_estimate = """    final rawWorkerIds = selectedWorkerIds ?? state.selectedWorkerIds;
    if (_isRecurring &&
        _recurringWorkerScope == CleaningRecurringWorkerScope.specific &&
        rawWorkerIds.isEmpty) {
      return;
    }
    final workerIds =
        _isRecurring &&
            _recurringWorkerScope == CleaningRecurringWorkerScope.any
        ? const <int>[]
        : rawWorkerIds;
    final preferredWorkerId = workerIds.isEmpty ? null : workerIds.first;
    final stateWorkerCount = state.numberOfWorkers < 1
        ? 1
        : state.numberOfWorkers;
    final requestedWorkers = _isRecurring
        ? (_recurringWorkerScope == CleaningRecurringWorkerScope.specific
              ? (workerIds.isEmpty ? 1 : workerIds.length)
              : stateWorkerCount)
        : (workerIds.length > stateWorkerCount
              ? workerIds.length
              : stateWorkerCount);
    final assignmentMode = _isRecurring
        ? (_recurringWorkerScope == CleaningRecurringWorkerScope.any
              ? CleaningAssignmentMode.openCount
              : (workerIds.length <= 1
                    ? CleaningAssignmentMode.preferredWorker
                    : CleaningAssignmentMode.openCount))
        : (requestedWorkers > 1
              ? CleaningAssignmentMode.openCount
              : state.assignmentMode);
"""
text = replace_once(text, old_estimate, new_estimate, 'screen estimate workers')
# This exact block appears once now in the estimate constructor because submit was already patched above.
needle = """          recurringHoursPerVisit:
              _recurringCalculationMode ==
                  CleaningRecurringCalculationMode.hours
              ? _recurringHoursPerVisit
              : null,
          workerRoomAssignments: workerRoomAssignments.isEmpty
"""
replacement = """          recurringHoursPerVisit:
              _recurringCalculationMode ==
                  CleaningRecurringCalculationMode.hours
              ? _recurringHoursPerVisit
              : null,
          recurringWorkerScope: _recurringWorkerScope,
          workerRoomAssignments: workerRoomAssignments.isEmpty
"""
text = replace_once(text, needle, replacement, 'screen estimate scope param')
write(path, text)


# Serialization tests: create/estimate must match for any and specific scopes.
path = 'test/features/cl_main/domain/usecases/recurring_cleaning_request_serialization_test.dart'
text = read(path)
insert = """

  test('recurring any-worker scope clears preferred workers identically', () {
    final createBody = CreateCleaningOrderParams(
      addressId: 1,
      propertyType: 'apartment',
      bedrooms: 1,
      rooms: 1,
      bathrooms: 1,
      livingRoomSize: 'small',
      address: 'حلب',
      locationName: 'المنزل',
      scheduledDate: '2026-09-10',
      scheduledTime: '08:00',
      addressLatitude: null,
      addressLongitude: null,
      recurringSessions: visits,
      recurringWorkerScope: CleaningRecurringWorkerScope.any,
      preferredWorkerIds: const <int>[11, 22],
      numberOfWorkers: 3,
    ).getBody();
    final estimateBody = EstimateCleaningPriceParams(
      propertyType: 'apartment',
      bedrooms: 1,
      rooms: 1,
      bathrooms: 1,
      livingRoomSize: 'small',
      addressLatitude: 36.2,
      addressLongitude: 37.1,
      recurringSessions: visits,
      recurringWorkerScope: CleaningRecurringWorkerScope.any,
      preferredWorkerIds: const <int>[11, 22],
      numberOfWorkers: 3,
    ).getBody();

    for (final body in <Map<String, dynamic>>[createBody, estimateBody]) {
      expect(body['workerScope'], 'any');
      expect(body['assignmentMode'], 'open_count');
      expect(body['numberOfWorkers'], 3);
      expect(body.containsKey('preferredWorkerIds'), isFalse);
    }
  });

  test('recurring specific scope locks the exact selected workers identically', () {
    final createBody = CreateCleaningOrderParams(
      addressId: 1,
      propertyType: 'apartment',
      bedrooms: 1,
      rooms: 1,
      bathrooms: 1,
      livingRoomSize: 'small',
      address: 'حلب',
      locationName: 'المنزل',
      scheduledDate: '2026-09-10',
      scheduledTime: '08:00',
      addressLatitude: null,
      addressLongitude: null,
      recurringSessions: visits,
      recurringWorkerScope: CleaningRecurringWorkerScope.specific,
      preferredWorkerIds: const <int>[11, 22, 11],
      numberOfWorkers: 5,
    ).getBody();
    final estimateBody = EstimateCleaningPriceParams(
      propertyType: 'apartment',
      bedrooms: 1,
      rooms: 1,
      bathrooms: 1,
      livingRoomSize: 'small',
      addressLatitude: 36.2,
      addressLongitude: 37.1,
      recurringSessions: visits,
      recurringWorkerScope: CleaningRecurringWorkerScope.specific,
      preferredWorkerIds: const <int>[11, 22, 11],
      numberOfWorkers: 5,
    ).getBody();

    for (final body in <Map<String, dynamic>>[createBody, estimateBody]) {
      expect(body['workerScope'], 'specific');
      expect(body['assignmentMode'], 'open_count');
      expect(body['numberOfWorkers'], 2);
      expect(body['preferredWorkerIds'], const <int>[11, 22]);
    }
  });
"""
idx = text.rfind('\n}')
if idx < 0:
    raise SystemExit('serialization test closing brace not found')
text = text[:idx] + insert + text[idx:]
write(path, text)


# Widget contract test.
path = 'test/features/cl_main/view/widgets/cl_recurring_schedule_section_widget_test.dart'
text = read(path)
insert = """

  testWidgets('forwards recurring worker scope and explains specific lock', (
    tester,
  ) async {
    var scope = CleaningRecurringWorkerScope.any;
    final sessions = <CleaningRecurringSessionInput>[
      CleaningRecurringSessionInput(date: DateTime(2026, 9, 12), time: '09:00'),
      CleaningRecurringSessionInput(date: DateTime(2026, 9, 19), time: '09:00'),
    ];

    Future<void> pump() => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ClRecurringScheduleSectionWidget(
            enabled: true,
            pattern: CleaningRecurringPattern.custom,
            workerScope: scope,
            occurrences: 2,
            maxOccurrences: 0,
            sessions: sessions,
            onEnabledChanged: (_) {},
            onPatternChanged: (_) {},
            onWorkerScopeChanged: (value) => scope = value,
            onOccurrencesChanged: (_) {},
            onAddVisit: () {},
            onEditVisit: (_) {},
            onRemoveVisit: (_) {},
          ),
        ),
      ),
    );

    await pump();
    expect(find.text('نطاق العمال لكل زيارة'), findsOneWidget);
    expect(find.text('أي عامل متاح'), findsOneWidget);
    await tester.tap(find.text('أي عامل متاح'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('عمال محددون فقط').last);
    expect(scope, CleaningRecurringWorkerScope.specific);

    await pump();
    expect(
      find.text(
        'تُحصر الزيارات بالعمال الذين تختارهم فقط، ولن يتم فتحها تلقائياً لعمال آخرين.',
      ),
      findsOneWidget,
    );
  });
"""
idx = text.rfind('\n}')
if idx < 0:
    raise SystemExit('widget test closing brace not found')
text = text[:idx] + insert + text[idx:]
write(path, text)

print('recurring worker scope UI patch applied')
