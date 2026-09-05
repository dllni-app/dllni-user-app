from pathlib import Path


def read(path: str) -> str:
    return Path(path).read_text()


def write(path: str, text: str) -> None:
    Path(path).write_text(text)


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f'{label}: expected 1 match, found {count}')
    return text.replace(old, new, 1)


# 1) Shared recurring calculation-mode contract.
path = 'lib/features/cl_main/domain/models/cleaning_recurring_session.dart'
text = read(path)
text = replace_once(
    text,
    "enum CleaningRecurringPattern { custom, daily, weekly, monthly }\n",
    "enum CleaningRecurringPattern { custom, daily, weekly, monthly }\n\n"
    "enum CleaningRecurringCalculationMode { task, hours }\n\n"
    "extension CleaningRecurringCalculationModeX on CleaningRecurringCalculationMode {\n"
    "  String get apiValue => switch (this) {\n"
    "    CleaningRecurringCalculationMode.task => 'task',\n"
    "    CleaningRecurringCalculationMode.hours => 'hours',\n"
    "  };\n\n"
    "  String get labelAr => switch (this) {\n"
    "    CleaningRecurringCalculationMode.task => 'حسب المهام',\n"
    "    CleaningRecurringCalculationMode.hours => 'حسب الساعات',\n"
    "  };\n\n"
    "  String get descriptionAr => switch (this) {\n"
    "    CleaningRecurringCalculationMode.task =>\n"
    "      'تُحسب كل زيارة حسب تفاصيل المنزل والمهام المحددة.',\n"
    "    CleaningRecurringCalculationMode.hours =>\n"
    "      'يتكرر نفس عدد الساعات المحجوزة في كل زيارة.',\n"
    "  };\n"
    "}\n\n"
    "double? normalizeCleaningRecurringHoursPerVisit(double? value) {\n"
    "  if (value == null || !value.isFinite || value < 1 || value > 24) {\n"
    "    return null;\n"
    "  }\n"
    "  return (value * 2).ceilToDouble() / 2;\n"
    "}\n",
    'calculation mode enum',
)
old = """  Map<String, dynamic>? get scheduleJson {
    final items = normalized;
    if (items.isEmpty) return null;
    return <String, dynamic>{
      'mode': 'recurring',
      'sessions': items.map((item) => item.toJson()).toList(growable: false),
    };
  }
"""
new = """  Map<String, dynamic>? get scheduleJson => scheduleJsonFor();

  Map<String, dynamic>? scheduleJsonFor({
    CleaningRecurringCalculationMode calculationMode =
        CleaningRecurringCalculationMode.task,
    double? hoursPerVisit,
  }) {
    final items = normalized;
    if (items.isEmpty) return null;
    final normalizedHours = calculationMode == CleaningRecurringCalculationMode.hours
        ? normalizeCleaningRecurringHoursPerVisit(hoursPerVisit)
        : null;
    if (calculationMode == CleaningRecurringCalculationMode.hours &&
        normalizedHours == null) {
      return null;
    }
    return <String, dynamic>{
      'mode': 'recurring',
      'calculationMode': calculationMode.apiValue,
      if (normalizedHours != null) 'hoursPerVisit': normalizedHours,
      'sessions': items.map((item) => item.toJson()).toList(growable: false),
    };
  }
"""
text = replace_once(text, old, new, 'schedule serialization')
write(path, text)


# 2) Create order serialization.
path = 'lib/features/cl_main/domain/usecases/create_cleaning_order_use_case.dart'
text = read(path)
text = replace_once(
    text,
    "  final List<CleaningRecurringSessionInput> recurringSessions;\n",
    "  final List<CleaningRecurringSessionInput> recurringSessions;\n"
    "  final CleaningRecurringCalculationMode recurringCalculationMode;\n"
    "  final double? recurringHoursPerVisit;\n",
    'create fields',
)
text = replace_once(
    text,
    "    this.recurringSessions = const <CleaningRecurringSessionInput>[],\n    this.assignmentMode = CleaningAssignmentMode.preferredWorker,\n",
    "    this.recurringSessions = const <CleaningRecurringSessionInput>[],\n"
    "    this.recurringCalculationMode = CleaningRecurringCalculationMode.task,\n"
    "    this.recurringHoursPerVisit,\n"
    "    this.assignmentMode = CleaningAssignmentMode.preferredWorker,\n",
    'create constructor fields',
)
text = replace_once(
    text,
    "       cleaningServices = null,\n       recurringSessions = const <CleaningRecurringSessionInput>[];\n",
    "       cleaningServices = null,\n"
    "       recurringSessions = const <CleaningRecurringSessionInput>[],\n"
    "       recurringCalculationMode = CleaningRecurringCalculationMode.task,\n"
    "       recurringHoursPerVisit = null;\n",
    'create event initializer',
)
text = replace_once(
    text,
    "    final schedule = _isEventAssistance\n        ? _normalizedEventSessions.scheduleJson\n        : _normalizedRecurringSessions.scheduleJson;\n",
    "    final schedule = _isEventAssistance\n"
    "        ? _normalizedEventSessions.scheduleJson\n"
    "        : _normalizedRecurringSessions.scheduleJsonFor(\n"
    "            calculationMode: recurringCalculationMode,\n"
    "            hoursPerVisit: recurringHoursPerVisit,\n"
    "          );\n",
    'create schedule contract',
)
write(path, text)


# 3) Estimate serialization.
path = 'lib/features/cl_main/domain/usecases/estimate_cleaning_price_use_case.dart'
text = read(path)
text = replace_once(
    text,
    "  final List<CleaningRecurringSessionInput> recurringSessions;\n",
    "  final List<CleaningRecurringSessionInput> recurringSessions;\n"
    "  final CleaningRecurringCalculationMode recurringCalculationMode;\n"
    "  final double? recurringHoursPerVisit;\n",
    'estimate fields',
)
text = replace_once(
    text,
    "    this.recurringSessions = const <CleaningRecurringSessionInput>[],\n    this.assignmentMode = CleaningAssignmentMode.preferredWorker,\n",
    "    this.recurringSessions = const <CleaningRecurringSessionInput>[],\n"
    "    this.recurringCalculationMode = CleaningRecurringCalculationMode.task,\n"
    "    this.recurringHoursPerVisit,\n"
    "    this.assignmentMode = CleaningAssignmentMode.preferredWorker,\n",
    'estimate constructor fields',
)
text = replace_once(
    text,
    "       cleaningType = null,\n       recurringSessions = const <CleaningRecurringSessionInput>[];\n",
    "       cleaningType = null,\n"
    "       recurringSessions = const <CleaningRecurringSessionInput>[],\n"
    "       recurringCalculationMode = CleaningRecurringCalculationMode.task,\n"
    "       recurringHoursPerVisit = null;\n",
    'estimate event initializer',
)
text = replace_once(
    text,
    "    final schedule = _isEventAssistance\n        ? _normalizedEventSessions.scheduleJson\n        : _normalizedRecurringSessions.scheduleJson;\n",
    "    final schedule = _isEventAssistance\n"
    "        ? _normalizedEventSessions.scheduleJson\n"
    "        : _normalizedRecurringSessions.scheduleJsonFor(\n"
    "            calculationMode: recurringCalculationMode,\n"
    "            hoursPerVisit: recurringHoursPerVisit,\n"
    "          );\n",
    'estimate schedule contract',
)
write(path, text)


# 4) Recurring UI controls.
path = 'lib/features/cl_main/view/widgets/cl_recurring_schedule_section_widget.dart'
text = read(path)
text = replace_once(
    text,
    "    required this.pattern,\n    required this.occurrences,\n",
    "    required this.pattern,\n"
    "    this.calculationMode = CleaningRecurringCalculationMode.task,\n"
    "    this.hoursPerVisit = 2,\n"
    "    required this.occurrences,\n",
    'widget constructor mode',
)
text = replace_once(
    text,
    "    required this.onPatternChanged,\n    required this.onOccurrencesChanged,\n",
    "    required this.onPatternChanged,\n"
    "    this.onCalculationModeChanged,\n"
    "    this.onHoursPerVisitChanged,\n"
    "    required this.onOccurrencesChanged,\n",
    'widget callbacks',
)
text = replace_once(
    text,
    "  final CleaningRecurringPattern pattern;\n  final int occurrences;\n",
    "  final CleaningRecurringPattern pattern;\n"
    "  final CleaningRecurringCalculationMode calculationMode;\n"
    "  final double hoursPerVisit;\n"
    "  final int occurrences;\n",
    'widget fields',
)
text = replace_once(
    text,
    "  final ValueChanged<CleaningRecurringPattern> onPatternChanged;\n  final ValueChanged<int> onOccurrencesChanged;\n",
    "  final ValueChanged<CleaningRecurringPattern> onPatternChanged;\n"
    "  final ValueChanged<CleaningRecurringCalculationMode>? onCalculationModeChanged;\n"
    "  final ValueChanged<double>? onHoursPerVisitChanged;\n"
    "  final ValueChanged<int> onOccurrencesChanged;\n",
    'widget callback fields',
)
needle = """              const Divider(height: 22),
              DropdownButtonFormField<CleaningRecurringPattern>(
"""
replacement = """              const Divider(height: 22),
              DropdownButtonFormField<CleaningRecurringCalculationMode>(
                initialValue: calculationMode,
                decoration: const InputDecoration(
                  labelText: 'طريقة احتساب كل زيارة',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: CleaningRecurringCalculationMode.values
                    .map(
                      (item) => DropdownMenuItem<CleaningRecurringCalculationMode>(
                        value: item,
                        child: Text(item.labelAr),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) onCalculationModeChanged?.call(value);
                },
              ),
              const SizedBox(height: 6),
              Text(
                calculationMode.descriptionAr,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (calculationMode == CleaningRecurringCalculationMode.hours) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'الساعات لكل زيارة',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      tooltip: 'تقليل ساعات الزيارة',
                      onPressed: hoursPerVisit > 1
                          ? () => onHoursPerVisitChanged?.call(hoursPerVisit - 0.5)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Container(
                      constraints: const BoxConstraints(minWidth: 54),
                      alignment: Alignment.center,
                      child: Text(
                        '${hoursPerVisit.toStringAsFixed(hoursPerVisit % 1 == 0 ? 0 : 1)} ساعة',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      tooltip: 'زيادة ساعات الزيارة',
                      onPressed: hoursPerVisit < 24
                          ? () => onHoursPerVisitChanged?.call(hoursPerVisit + 0.5)
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              DropdownButtonFormField<CleaningRecurringPattern>(
"""
text = replace_once(text, needle, replacement, 'widget mode UI')
write(path, text)


# 5) Screen state + create/estimate wiring.
path = 'lib/features/cl_main/view/screens/cl_main_service_schedule_screen.dart'
text = read(path)
text = replace_once(
    text,
    "  CleaningRecurringPattern _recurringPattern = CleaningRecurringPattern.custom;\n  int _recurringOccurrences = 2;\n",
    "  CleaningRecurringPattern _recurringPattern = CleaningRecurringPattern.custom;\n"
    "  CleaningRecurringCalculationMode _recurringCalculationMode =\n"
    "      CleaningRecurringCalculationMode.task;\n"
    "  double _recurringHoursPerVisit = 2;\n"
    "  int _recurringOccurrences = 2;\n",
    'screen state',
)
text = replace_once(
    text,
    "                            pattern: _recurringPattern,\n                            occurrences: _recurringOccurrences,\n",
    "                            pattern: _recurringPattern,\n"
    "                            calculationMode: _recurringCalculationMode,\n"
    "                            hoursPerVisit: _recurringHoursPerVisit,\n"
    "                            occurrences: _recurringOccurrences,\n",
    'screen widget props',
)
text = replace_once(
    text,
    "                            onPatternChanged: (pattern) =>\n                                _setRecurringPattern(pattern, state),\n                            onOccurrencesChanged: (occurrences) =>\n",
    "                            onPatternChanged: (pattern) =>\n"
    "                                _setRecurringPattern(pattern, state),\n"
    "                            onCalculationModeChanged: (mode) =>\n"
    "                                _setRecurringCalculationMode(mode, state),\n"
    "                            onHoursPerVisitChanged: (hours) =>\n"
    "                                _setRecurringHoursPerVisit(hours, state),\n"
    "                            onOccurrencesChanged: (occurrences) =>\n",
    'screen widget callbacks',
)
text = replace_once(
    text,
    "      _recurringPattern = CleaningRecurringPattern.custom;\n      _recurringOccurrences = 2;\n",
    "      _recurringPattern = CleaningRecurringPattern.custom;\n"
    "      _recurringCalculationMode = CleaningRecurringCalculationMode.task;\n"
    "      _recurringHoursPerVisit = 2;\n"
    "      _recurringOccurrences = 2;\n",
    'screen enable reset',
)
insert_before = "  int get _recurringMaxOccurrences {\n"
if text.count(insert_before) != 1:
    raise RuntimeError('screen calculation callback anchor')
methods = """  void _setRecurringCalculationMode(
    CleaningRecurringCalculationMode mode,
    ClMainState state,
  ) {
    if (mode == _recurringCalculationMode) return;
    setState(() {
      _recurringCalculationMode = mode;
      _resetAppliedCoupon(
        message: 'تم تغيير طريقة احتساب الزيارات. أعد تطبيق الكوبون.',
      );
    });
    _requestUpdatedEstimate(state);
  }

  void _setRecurringHoursPerVisit(double hours, ClMainState state) {
    final normalized = normalizeCleaningRecurringHoursPerVisit(hours);
    if (normalized == null || normalized == _recurringHoursPerVisit) return;
    setState(() {
      _recurringHoursPerVisit = normalized;
      _resetAppliedCoupon(
        message: 'تم تغيير ساعات الزيارة. أعد تطبيق الكوبون.',
      );
    });
    _requestUpdatedEstimate(state);
  }

"""
text = text.replace(insert_before, methods + insert_before, 1)
text = replace_once(
    text,
    "          recurringSessions: _recurringSessionsForRequest,\n          cleaningServices: _selectedCleaningServicesPayload(),\n",
    "          recurringSessions: _recurringSessionsForRequest,\n"
    "          recurringCalculationMode: _recurringCalculationMode,\n"
    "          recurringHoursPerVisit:\n"
    "              _recurringCalculationMode == CleaningRecurringCalculationMode.hours\n"
    "              ? _recurringHoursPerVisit\n"
    "              : null,\n"
    "          cleaningServices: _selectedCleaningServicesPayload(),\n",
    'screen create params',
)
text = replace_once(
    text,
    "          recurringSessions: _recurringSessionsForRequest,\n          workerRoomAssignments: workerRoomAssignments.isEmpty\n",
    "          recurringSessions: _recurringSessionsForRequest,\n"
    "          recurringCalculationMode: _recurringCalculationMode,\n"
    "          recurringHoursPerVisit:\n"
    "              _recurringCalculationMode == CleaningRecurringCalculationMode.hours\n"
    "              ? _recurringHoursPerVisit\n"
    "              : null,\n"
    "          workerRoomAssignments: workerRoomAssignments.isEmpty\n",
    'screen estimate params',
)
write(path, text)


# 6) Model tests.
path = 'test/features/cl_main/domain/models/cleaning_recurring_session_test.dart'
text = read(path)
text = text.replace(
    "    expect(sessions.scheduleJson, <String, dynamic>{\n      'mode': 'recurring',\n",
    "    expect(sessions.scheduleJson, <String, dynamic>{\n      'mode': 'recurring',\n      'calculationMode': 'task',\n",
    1,
)
anchor = "  test('generates daily visits from the canonical first visit', () {\n"
if text.count(anchor) != 1:
    raise RuntimeError('model test anchor')
extra = """  test('serializes hour-based recurring schedule with half-hour normalization', () {
    final sessions = <CleaningRecurringSessionInput>[
      CleaningRecurringSessionInput(date: DateTime(2026, 9, 7), time: '09:00'),
      CleaningRecurringSessionInput(date: DateTime(2026, 9, 14), time: '09:00'),
    ];

    expect(
      sessions.scheduleJsonFor(
        calculationMode: CleaningRecurringCalculationMode.hours,
        hoursPerVisit: 2.25,
      ),
      <String, dynamic>{
        'mode': 'recurring',
        'calculationMode': 'hours',
        'hoursPerVisit': 2.5,
        'sessions': <Map<String, dynamic>>[
          <String, dynamic>{'date': '2026-09-07', 'time': '09:00'},
          <String, dynamic>{'date': '2026-09-14', 'time': '09:00'},
        ],
      },
    );
    expect(
      sessions.scheduleJsonFor(
        calculationMode: CleaningRecurringCalculationMode.hours,
        hoursPerVisit: 25,
      ),
      isNull,
    );
  });

"""
text = text.replace(anchor, extra + anchor, 1)
write(path, text)


# 7) Create/estimate serialization tests.
path = 'test/features/cl_main/domain/usecases/recurring_cleaning_request_serialization_test.dart'
text = read(path)
text = text.replace(
    "    expect(schedule['mode'], 'recurring');\n",
    "    expect(schedule['mode'], 'recurring');\n    expect(schedule['calculationMode'], 'task');\n",
    2,
)
end = "}\n"
extra = """
  test('create and estimate payloads serialize the same hour-based contract', () {
    final create = CreateCleaningOrderParams(
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
      recurringCalculationMode: CleaningRecurringCalculationMode.hours,
      recurringHoursPerVisit: 2.25,
    ).getBody()['schedule'] as Map<String, dynamic>;
    final estimate = EstimateCleaningPriceParams(
      propertyType: 'apartment',
      bedrooms: 1,
      rooms: 1,
      bathrooms: 1,
      livingRoomSize: 'small',
      addressLatitude: 36.2,
      addressLongitude: 37.1,
      recurringSessions: visits,
      recurringCalculationMode: CleaningRecurringCalculationMode.hours,
      recurringHoursPerVisit: 2.25,
    ).getBody()['schedule'] as Map<String, dynamic>;

    expect(create, estimate);
    expect(create['calculationMode'], 'hours');
    expect(create['hoursPerVisit'], 2.5);
  });
"""
if not text.rstrip().endswith('}'):
    raise RuntimeError('serialization test ending')
text = text.rstrip()[:-1] + extra + "}\n"
write(path, text)


# 8) Widget test for hour controls (existing call sites keep defaults).
path = 'test/features/cl_main/view/widgets/cl_recurring_schedule_section_widget_test.dart'
text = read(path)
extra = """
  testWidgets('forwards recurring calculation mode and hour changes', (tester) async {
    var mode = CleaningRecurringCalculationMode.task;
    var hours = 2.0;
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
            calculationMode: mode,
            hoursPerVisit: hours,
            occurrences: 2,
            maxOccurrences: 0,
            sessions: sessions,
            onEnabledChanged: (_) {},
            onPatternChanged: (_) {},
            onCalculationModeChanged: (value) => mode = value,
            onHoursPerVisitChanged: (value) => hours = value,
            onOccurrencesChanged: (_) {},
            onAddVisit: () {},
            onEditVisit: (_) {},
            onRemoveVisit: (_) {},
          ),
        ),
      ),
    );

    await pump();
    await tester.tap(find.text('حسب المهام'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حسب الساعات').last);
    expect(mode, CleaningRecurringCalculationMode.hours);

    mode = CleaningRecurringCalculationMode.hours;
    await pump();
    expect(find.text('الساعات لكل زيارة'), findsOneWidget);
    await tester.tap(find.byTooltip('زيادة ساعات الزيارة'));
    expect(hours, 2.5);
  });
"""
if not text.rstrip().endswith('}'):
    raise RuntimeError('widget test ending')
text = text.rstrip()[:-1] + extra + "}\n"
write(path, text)
